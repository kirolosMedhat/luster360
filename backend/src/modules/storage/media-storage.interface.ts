import { Readable } from 'stream';

export interface StorageFileRecord {
  fileId: string;
  filename: string;
  mimeType: string;
  sizeBytes: number;
  parentFolderId?: string;
  webViewLink?: string;
  downloadUrl?: string;
  createdAt: Date;
}

export interface UploadFileParams {
  filename: string;
  mimeType: string;
  stream: Readable;
  parentFolderId: string;
  sizeBytes?: number;
}

export interface EventFolderHierarchy {
  rootFolderId: string;
  videosFolderId: string;
  thumbnailsFolderId: string;
  brandingFolderId: string;
  assetsFolderId: string;
}

export interface StorageHealthReport {
  provider: string;
  status: 'CONNECTED' | 'DEGRADED' | 'DISCONNECTED' | 'CONFIGURATION_REQUIRED';
  lastSuccessfulUpload?: Date;
  details?: string;
}

export interface ReadableStreamWithMetadata {
  stream: Readable;
  contentLength?: number;
  contentType: string;
  contentRange?: string;
  acceptRanges?: string;
}

export interface MediaStorage {
  readonly providerName: string;

  /**
   * Initializes connections, tokens, and root directories.
   */
  initialize(): Promise<void>;

  /**
   * Health-check reporting current provider connection state.
   */
  healthCheck(): Promise<StorageHealthReport>;

  /**
   * Creates a single directory/folder within a parent.
   */
  createFolder(folderName: string, parentFolderId?: string): Promise<string>;

  /**
   * Automatically provisions the structured event hierarchy in storage:
   * Event Name -> Videos, Thumbnails, Branding, Assets
   */
  createEventFolders(eventName: string): Promise<EventFolderHierarchy>;

  /**
   * Uploads a file stream to the target folder.
   */
  uploadFile(params: UploadFileParams): Promise<StorageFileRecord>;

  /**
   * Verifies that the file exists and optionally validates size.
   */
  verifyFile(fileId: string, expectedSizeBytes?: number): Promise<boolean>;

  /**
   * Retrieves a readable stream for streaming playback (supports byte-range headers).
   */
  getFileStream(fileId: string, rangeHeader?: string): Promise<ReadableStreamWithMetadata>;

  /**
   * Retrieves a readable stream for full file download.
   */
  getDownloadStream(fileId: string): Promise<ReadableStreamWithMetadata>;

  /**
   * Deletes a file from storage.
   */
  deleteFile(fileId: string): Promise<void>;

  /**
   * Checks if a file exists.
   */
  fileExists(fileId: string): Promise<boolean>;

  /**
   * Finds an existing file by filename in a specific folder (for upload idempotency).
   */
  findFileByName(folderId: string, filename: string): Promise<StorageFileRecord | null>;
}
