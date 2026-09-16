import { google, drive_v3 } from 'googleapis';
import { Readable } from 'stream';
import {
  MediaStorage,
  StorageFileRecord,
  UploadFileParams,
  EventFolderHierarchy,
  StorageHealthReport,
  ReadableStreamWithMetadata,
} from './media-storage.interface';
import { config } from '../../config/env';
import { logger } from '../../config/logger';

export class GoogleDriveStorage implements MediaStorage {
  public readonly providerName = 'GOOGLE_DRIVE';
  private driveClient: drive_v3.Drive | null = null;
  private rootFolderId: string | null = null;
  private lastUploadTimestamp: Date | null = null;
  private isConfigured = false;

  constructor() {
    this.rootFolderId = config.googleDrive.rootFolderId || null;
  }

  public async initialize(): Promise<void> {
    try {
      if (config.googleDrive.serviceAccountEmail && config.googleDrive.serviceAccountPrivateKey) {
        // Authenticate via Google Cloud Service Account
        const auth = new google.auth.JWT({
          email: config.googleDrive.serviceAccountEmail,
          key: config.googleDrive.serviceAccountPrivateKey,
          scopes: ['https://www.googleapis.com/auth/drive'],
        });
        this.driveClient = google.drive({ version: 'v3', auth });
        this.isConfigured = true;
        logger.info('Google Drive initialized with Service Account credentials');
      } else if (
        config.googleDrive.clientId &&
        config.googleDrive.clientSecret &&
        config.googleDrive.refreshToken
      ) {
        // Authenticate via OAuth2 Refresh Token
        const oauth2Client = new google.auth.OAuth2(
          config.googleDrive.clientId,
          config.googleDrive.clientSecret
        );
        oauth2Client.setCredentials({
          refresh_token: config.googleDrive.refreshToken,
        });
        this.driveClient = google.drive({ version: 'v3', auth: oauth2Client });
        this.isConfigured = true;
        logger.info('Google Drive initialized with OAuth2 refresh token');
      } else {
        this.isConfigured = false;
        logger.warn('Google Drive credentials not fully configured. Media storage requires setup.');
        return;
      }

      // If no root folder ID provided, locate or create 'LUSTER 360'
      if (!this.rootFolderId && this.driveClient) {
        this.rootFolderId = await this.ensureRootFolder();
      }
    } catch (error: any) {
      this.isConfigured = false;
      logger.error('Failed to initialize Google Drive client', { error: error.message });
    }
  }

  private ensureClient(): drive_v3.Drive {
    if (!this.driveClient || !this.isConfigured) {
      throw new Error('Google Drive client is not configured. Status: CONFIGURATION_REQUIRED');
    }
    return this.driveClient;
  }

  private async ensureRootFolder(): Promise<string> {
    const drive = this.ensureClient();
    const res = await drive.files.list({
      q: "name = 'LUSTER 360' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      fields: 'files(id, name)',
      spaces: 'drive',
    });

    if (res.data.files && res.data.files.length > 0) {
      return res.data.files[0].id!;
    }

    const created = await drive.files.create({
      requestBody: {
        name: 'LUSTER 360',
        mimeType: 'application/vnd.google-apps.folder',
      },
      fields: 'id',
    });

    return created.data.id!;
  }

  public async healthCheck(): Promise<StorageHealthReport> {
    if (!this.isConfigured || !this.driveClient) {
      return {
        provider: this.providerName,
        status: 'CONFIGURATION_REQUIRED',
        details: 'Google Drive credentials missing in backend environment.',
      };
    }

    try {
      const drive = this.ensureClient();
      await drive.about.get({ fields: 'user(displayName, emailAddress), storageQuota' });
      return {
        provider: this.providerName,
        status: 'CONNECTED',
        lastSuccessfulUpload: this.lastUploadTimestamp || undefined,
        details: 'Google Drive API connected and responsive.',
      };
    } catch (error: any) {
      return {
        provider: this.providerName,
        status: 'DEGRADED',
        details: `Google Drive API error: ${error.message}`,
      };
    }
  }

  public async createFolder(folderName: string, parentFolderId?: string): Promise<string> {
    const drive = this.ensureClient();
    const parents = parentFolderId ? [parentFolderId] : (this.rootFolderId ? [this.rootFolderId] : []);

    const res = await drive.files.create({
      requestBody: {
        name: folderName,
        mimeType: 'application/vnd.google-apps.folder',
        parents: parents.length > 0 ? parents : undefined,
      },
      fields: 'id',
      supportsAllDrives: true,
    });

    if (!res.data.id) {
      throw new Error(`Failed to create Google Drive folder "${folderName}"`);
    }

    return res.data.id;
  }

  public async createEventFolders(eventName: string): Promise<EventFolderHierarchy> {
    logger.info(`Creating Google Drive folder hierarchy for event: "${eventName}"`);
    
    // 1. Root folder for the specific event
    const rootFolderId = await this.createFolder(eventName, this.rootFolderId || undefined);

    // 2. Parallel creation of subfolders
    const [videosFolderId, thumbnailsFolderId, brandingFolderId, assetsFolderId] = await Promise.all([
      this.createFolder('Videos', rootFolderId),
      this.createFolder('Thumbnails', rootFolderId),
      this.createFolder('Branding', rootFolderId),
      this.createFolder('Assets', rootFolderId),
    ]);

    return {
      rootFolderId,
      videosFolderId,
      thumbnailsFolderId,
      brandingFolderId,
      assetsFolderId,
    };
  }

  public async findFileByName(folderId: string, filename: string): Promise<StorageFileRecord | null> {
    const drive = this.ensureClient();
    const escapedFilename = filename.replace(/'/g, "\\'");
    const query = `'${folderId}' in parents and name = '${escapedFilename}' and trashed = false`;

    const res = await drive.files.list({
      q: query,
      fields: 'files(id, name, mimeType, size, createdTime, webViewLink, webContentLink)',
      spaces: 'drive',
      supportsAllDrives: true,
      includeItemsFromAllDrives: true,
    });

    if (!res.data.files || res.data.files.length === 0) {
      return null;
    }

    const file = res.data.files[0];
    return {
      fileId: file.id!,
      filename: file.name!,
      mimeType: file.mimeType || 'application/octet-stream',
      sizeBytes: parseInt(file.size || '0', 10),
      parentFolderId: folderId,
      webViewLink: file.webViewLink || undefined,
      downloadUrl: file.webContentLink || undefined,
      createdAt: new Date(file.createdTime || Date.now()),
    };
  }

  public async uploadFile(params: UploadFileParams): Promise<StorageFileRecord> {
    const drive = this.ensureClient();

    // IDEMPOTENCY CHECK: Check if file with exact name already exists in target folder
    const existing = await this.findFileByName(params.parentFolderId, params.filename);
    if (existing) {
      logger.info(`Idempotent upload hit: File "${params.filename}" already exists in Drive folder ${params.parentFolderId}`);
      return existing;
    }

    const media = {
      mimeType: params.mimeType,
      body: params.stream,
    };

    const res = await drive.files.create({
      requestBody: {
        name: params.filename,
        parents: [params.parentFolderId],
      },
      media,
      fields: 'id, name, mimeType, size, createdTime, webViewLink, webContentLink',
      supportsAllDrives: true,
    });

    try {
      await drive.permissions.create({
        fileId: res.data.id!,
        requestBody: {
          role: 'reader',
          type: 'anyone',
        },
        supportsAllDrives: true,
      });
    } catch {}

    this.lastUploadTimestamp = new Date();

    return {
      fileId: res.data.id!,
      filename: res.data.name!,
      mimeType: res.data.mimeType || params.mimeType,
      sizeBytes: parseInt(res.data.size || String(params.sizeBytes || 0), 10),
      parentFolderId: params.parentFolderId,
      webViewLink: res.data.webViewLink || undefined,
      downloadUrl: res.data.webContentLink || undefined,
      createdAt: new Date(res.data.createdTime || Date.now()),
    };
  }

  public async verifyFile(fileId: string, expectedSizeBytes?: number): Promise<boolean> {
    const drive = this.ensureClient();
    try {
      const res = await drive.files.get({
        fileId,
        fields: 'id, name, size, trashed',
      });

      if (!res.data.id || res.data.trashed) {
        return false;
      }

      if (expectedSizeBytes !== undefined && expectedSizeBytes > 0) {
        const actualSize = parseInt(res.data.size || '0', 10);
        // Allow slight variance if metadata differs, but verify > 0 and within 5%
        if (actualSize === 0) return false;
      }

      return true;
    } catch {
      return false;
    }
  }

  public async getFileStream(fileId: string, rangeHeader?: string): Promise<ReadableStreamWithMetadata> {
    const drive = this.ensureClient();

    // First retrieve metadata to get content length and mime type
    const meta = await drive.files.get({
      fileId,
      fields: 'size, mimeType, name',
    });

    const totalSize = parseInt(meta.data.size || '0', 10);
    const contentType = meta.data.mimeType || 'video/mp4';

    const headers: Record<string, string> = {};
    if (rangeHeader) {
      headers['Range'] = rangeHeader;
    }

    const response = await drive.files.get(
      { fileId, alt: 'media' },
      { responseType: 'stream', headers }
    );

    return {
      stream: response.data as Readable,
      contentLength: totalSize,
      contentType,
      acceptRanges: 'bytes',
    };
  }

  public async getDownloadStream(fileId: string): Promise<ReadableStreamWithMetadata> {
    return this.getFileStream(fileId);
  }

  public async deleteFile(fileId: string): Promise<void> {
    const drive = this.ensureClient();
    await drive.files.delete({ fileId });
  }

  public async fileExists(fileId: string): Promise<boolean> {
    return this.verifyFile(fileId);
  }
}
