import { Readable, PassThrough } from 'stream';
import {
  MediaStorage,
  StorageFileRecord,
  UploadFileParams,
  EventFolderHierarchy,
  StorageHealthReport,
  ReadableStreamWithMetadata,
} from './media-storage.interface';
import { logger } from '../../config/logger';

export class MockStorage implements MediaStorage {
  public readonly providerName = 'MOCK_STORAGE';
  private files: Map<string, { record: StorageFileRecord; data: Buffer }> = new Map();
  private folders: Map<string, { id: string; name: string; parentId?: string }> = new Map();
  private lastUploadTimestamp: Date | null = null;

  public async initialize(): Promise<void> {
    logger.info('MockStorage initialized for development/testing environment.');
    // Seed default root folder
    this.folders.set('mock-root-luster360', {
      id: 'mock-root-luster360',
      name: 'LUSTER 360',
    });
  }

  public async healthCheck(): Promise<StorageHealthReport> {
    return {
      provider: this.providerName,
      status: 'CONNECTED',
      lastSuccessfulUpload: this.lastUploadTimestamp || undefined,
      details: 'Mock storage is running in local memory for dev/testing.',
    };
  }

  public async createFolder(folderName: string, parentFolderId?: string): Promise<string> {
    const id = `mock-folder-${Date.now()}-${Math.random().toString(36).substring(7)}`;
    this.folders.set(id, { id, name: folderName, parentId: parentFolderId });
    return id;
  }

  public async createEventFolders(eventName: string): Promise<EventFolderHierarchy> {
    const rootFolderId = await this.createFolder(eventName, 'mock-root-luster360');
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
    for (const item of this.files.values()) {
      if (item.record.parentFolderId === folderId && item.record.filename === filename) {
        return item.record;
      }
    }
    return null;
  }

  public async uploadFile(params: UploadFileParams): Promise<StorageFileRecord> {
    // Check idempotency
    const existing = await this.findFileByName(params.parentFolderId, params.filename);
    if (existing) {
      return existing;
    }

    const chunks: Buffer[] = [];
    for await (const chunk of params.stream) {
      chunks.push(Buffer.from(chunk));
    }
    const data = Buffer.concat(chunks);
    const fileId = `mock-file-${Date.now()}-${Math.random().toString(36).substring(7)}`;

    const record: StorageFileRecord = {
      fileId,
      filename: params.filename,
      mimeType: params.mimeType,
      sizeBytes: data.length,
      parentFolderId: params.parentFolderId,
      webViewLink: `https://mock-drive.luster-photobooth.com/view/${fileId}`,
      downloadUrl: `https://mock-drive.luster-photobooth.com/download/${fileId}`,
      createdAt: new Date(),
    };

    this.files.set(fileId, { record, data });
    this.lastUploadTimestamp = new Date();
    return record;
  }

  public async verifyFile(fileId: string, expectedSizeBytes?: number): Promise<boolean> {
    const item = this.files.get(fileId);
    if (!item) return false;
    if (expectedSizeBytes !== undefined && expectedSizeBytes > 0) {
      return item.data.length > 0;
    }
    return true;
  }

  public async getFileStream(fileId: string, rangeHeader?: string): Promise<ReadableStreamWithMetadata> {
    const item = this.files.get(fileId);
    const data = item ? item.data : Buffer.from('MOCK_VIDEO_DATA');
    const contentType = item ? item.record.mimeType : 'video/mp4';

    const pass = new PassThrough();
    pass.end(data);

    return {
      stream: pass,
      contentLength: data.length,
      contentType,
      acceptRanges: 'bytes',
    };
  }

  public async getDownloadStream(fileId: string): Promise<ReadableStreamWithMetadata> {
    return this.getFileStream(fileId);
  }

  public async deleteFile(fileId: string): Promise<void> {
    this.files.delete(fileId);
  }

  public async fileExists(fileId: string): Promise<boolean> {
    return this.files.has(fileId);
  }
}
