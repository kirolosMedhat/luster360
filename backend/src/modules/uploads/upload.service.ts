import { Readable } from 'stream';
import { db } from '../database/db';
import { getStorageProvider } from '../storage/storage-factory';
import { logger } from '../../config/logger';
import { config } from '../../config/env';

export interface InitiateUploadDTO {
  videoId: string;
  eventId: string;
  deviceId: string;
  filename: string;
  fileSizeBytes: number;
  duration?: number;
  width?: number;
  height?: number;
  fps?: number;
}

export class UploadService {
  /**
   * Generates a collision-resistant 6-character alphanumeric code for public sharing
   * with collision retry loop against database (up to 5 attempts).
   * Alphanumeric excluding ambiguous chars: 0, O, I, 1, l.
   */
  public async generateUniqueShortCode(): Promise<string> {
    const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    for (let attempt = 0; attempt < 5; attempt++) {
      let code = '';
      for (let i = 0; i < 6; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
      }
      const existing = await db.getVideoByShortCode(code);
      if (!existing) {
        return code;
      }
      logger.warn(`Shortcode collision detected on attempt ${attempt + 1}: ${code}. Retrying...`);
    }

    // Extended 8-char fallback if 5 consecutive collisions
    let fallbackCode = '';
    for (let i = 0; i < 8; i++) {
      fallbackCode += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return fallbackCode;
  }

  public generateShortCode(): string {
    const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }

  /**
   * Idempotent upload initiation.
   * Prevents creating duplicate videos across network retries.
   */
  public async initiateUpload(dto: InitiateUploadDTO) {
    logger.info(`Initiating upload check for video "${dto.filename}" (${dto.videoId})`);

    const event = await db.getEventById(dto.eventId);
    if (!event) {
      throw new Error(`Event ${dto.eventId} not found`);
    }

    const storage = await getStorageProvider();
    const targetFolderId = event.drive_videos_folder_id || event.drive_root_folder_id;

    // Check if video is already registered in DB
    const existingDbVideo = await db.getVideoById(dto.videoId);
    if (existingDbVideo && existingDbVideo.storage_status === 'READY') {
      logger.info(`Idempotency check: Video ${dto.videoId} is already verified READY.`);
      return {
        isAlreadyUploaded: true,
        video: existingDbVideo,
        publicUrl: `${config.publicGalleryUrl}/v/${existingDbVideo.short_code}`,
      };
    }

    // Check if file already exists in Google Drive folder
    if (targetFolderId && targetFolderId !== 'pending') {
      const existingDriveFile = await storage.findFileByName(targetFolderId, dto.filename);
      if (existingDriveFile) {
        logger.info(`Idempotency check: File ${dto.filename} already found in Drive folder ${targetFolderId}`);
        const shortCode = existingDbVideo?.short_code || await this.generateUniqueShortCode();
        
        const verified = await db.upsertVideo({
          id: dto.videoId,
          event_id: dto.eventId,
          device_id: dto.deviceId,
          short_code: shortCode,
          filename: dto.filename,
          storage_provider: storage.providerName,
          storage_status: 'READY',
          publication_status: 'READY',
          drive_file_id: existingDriveFile.fileId,
          file_size: existingDriveFile.sizeBytes || dto.fileSizeBytes,
          duration: dto.duration || 15.0,
          width: dto.width || 1080,
          height: dto.height || 1920,
          fps: dto.fps || 30,
          uploaded_at: new Date().toISOString(),
          verified_at: new Date().toISOString(),
        });

        return {
          isAlreadyUploaded: true,
          video: verified,
          publicUrl: `${config.publicGalleryUrl}/v/${shortCode}`,
        };
      }
    }

    // New upload: mark as QUEUED -> UPLOADING
    const shortCode = existingDbVideo?.short_code || await this.generateUniqueShortCode();
    await db.upsertVideo({
      id: dto.videoId,
      event_id: dto.eventId,
      device_id: dto.deviceId,
      short_code: shortCode,
      filename: dto.filename,
      storage_provider: storage.providerName,
      storage_status: 'UPLOADING',
      publication_status: 'DRAFT',
      file_size: dto.fileSizeBytes,
      duration: dto.duration || 15.0,
      width: dto.width || 1080,
      height: dto.height || 1920,
      fps: dto.fps || 30,
      upload_started_at: new Date().toISOString(),
    });

    return {
      isAlreadyUploaded: false,
      targetFolderId,
      shortCode,
      targetThumbnailFolderId: event.drive_thumbnails_folder_id,
    };
  }

  /**
   * Pipes incoming MP4 stream into Google Drive
   */
  public async uploadVideoFile(
    videoId: string,
    stream: Readable,
    filename: string,
    sizeBytes: number
  ) {
    const video = await db.getVideoById(videoId);
    if (!video) throw new Error(`Video ${videoId} not found`);

    const event = await db.getEventById(video.event_id);
    if (!event) throw new Error(`Event ${video.event_id} not found`);

    const storage = await getStorageProvider();
    const folderId = event.drive_videos_folder_id || event.drive_root_folder_id;

    logger.info(`Streaming MP4 "${filename}" to Google Drive folder: ${folderId}`);
    const record = await storage.uploadFile({
      filename,
      mimeType: 'video/mp4',
      stream,
      parentFolderId: folderId,
      sizeBytes,
    });

    await db.upsertVideo({
      id: videoId,
      drive_file_id: record.fileId,
      storage_status: 'UPLOADED',
      uploaded_at: new Date().toISOString(),
      file_size: record.sizeBytes || sizeBytes,
    });

    return record;
  }

  /**
   * Pipes incoming Thumbnail stream into Google Drive
   */
  public async uploadThumbnailFile(
    videoId: string,
    stream: Readable,
    filename: string,
    sizeBytes: number
  ) {
    const video = await db.getVideoById(videoId);
    if (!video) throw new Error(`Video ${videoId} not found`);

    const event = await db.getEventById(video.event_id);
    if (!event) throw new Error(`Event ${video.event_id} not found`);

    const storage = await getStorageProvider();
    const folderId = event.drive_thumbnails_folder_id || event.drive_root_folder_id;

    logger.info(`Streaming Thumbnail "${filename}" to Google Drive folder: ${folderId}`);
    const record = await storage.uploadFile({
      filename,
      mimeType: filename.endsWith('.webp') ? 'image/webp' : 'image/jpeg',
      stream,
      parentFolderId: folderId,
      sizeBytes,
    });

    await db.upsertVideo({
      id: videoId,
      drive_thumbnail_file_id: record.fileId,
    });

    return record;
  }

  /**
   * Verification Engine: Confirms Drive file exists and is valid before publishing to gallery
   */
  public async verifyAndPublish(videoId: string) {
    const video = await db.getVideoById(videoId);
    if (!video) throw new Error(`Video ${videoId} not found`);

    if (!video.drive_file_id) {
      throw new Error(`Cannot verify video ${videoId}: No Drive file ID registered`);
    }

    // Set state to VERIFYING
    await db.upsertVideo({
      id: videoId,
      storage_status: 'VERIFYING',
    });

    const storage = await getStorageProvider();
    const isValid = await storage.verifyFile(video.drive_file_id, video.file_size);

    if (!isValid) {
      logger.error(`Upload verification FAILED for video ${videoId} (Drive file ${video.drive_file_id})`);
      await db.upsertVideo({
        id: videoId,
        storage_status: 'FAILED',
        publication_status: 'DRAFT',
      });
      throw new Error(`Google Drive file verification failed for video ${videoId}`);
    }

    // Mark READY
    const nowUtc = new Date().toISOString();
    const readyVideo = await db.upsertVideo({
      id: videoId,
      storage_status: 'READY',
      publication_status: 'READY',
      verified_at: nowUtc,
    });

    logger.info(`Video ${videoId} verified successfully. Marked READY in gallery.`);

    return {
      success: true,
      video: readyVideo,
      publicUrl: `${config.publicGalleryUrl}/v/${readyVideo.short_code}`,
      qrCodeUrl: `${config.publicGalleryUrl}/v/${readyVideo.short_code}`,
    };
  }
}

export const uploadService = new UploadService();
