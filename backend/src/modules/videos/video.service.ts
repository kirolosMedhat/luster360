import { Readable } from 'stream';
import fs from 'fs';
import path from 'path';
import { db } from '../database/db';
import { getStorageProvider } from '../storage/storage-factory';
import { logger } from '../../config/logger';
import { config } from '../../config/env';

const LOCAL_STORAGE_DIR = path.resolve(process.cwd(), 'storage', 'videos');
if (!fs.existsSync(LOCAL_STORAGE_DIR)) {
  fs.mkdirSync(LOCAL_STORAGE_DIR, { recursive: true });
}

export class VideoService {
  async getVideoByShortCode(shortCode: string) {
    const video = await db.getVideoByShortCode(shortCode);
    if (!video) return null;

    const event = await db.getEventById(video.event_id);
    return {
      ...video,
      event: event
        ? {
            id: event.id,
            name: event.name,
            eventDate: event.event_date,
            gallerySlug: event.gallery_slug,
            venue: event.venue,
            clientName: event.client_name,
            brandPrimaryColor: event.brand_primary_color,
            brandSecondaryColor: event.brand_secondary_color,
            isDownloadEnabled: event.is_download_enabled,
            isSharingEnabled: event.is_sharing_enabled,
          }
        : null,
    };
  }

  async getStreamForVideo(shortCode: string, rangeHeader?: string) {
    const video = await db.getVideoByShortCode(shortCode);
    if (!video) {
      throw new Error(`Video not found with code ${shortCode}`);
    }

    // 1. Check if video exists in local disk storage
    const localPath = path.join(LOCAL_STORAGE_DIR, video.filename);
    if (fs.existsSync(localPath)) {
      const stat = fs.statSync(localPath);
      const fileSize = stat.size;

      // Increment view count asynchronously
      db.upsertVideo({
        id: video.id,
        view_count: (video.view_count || 0) + 1,
      }).catch(() => {});

      if (rangeHeader) {
        const parts = rangeHeader.replace(/bytes=/, '').split('-');
        const start = parseInt(parts[0], 10);
        const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
        const chunksize = end - start + 1;
        const fileStream = fs.createReadStream(localPath, { start, end });

        return {
          stream: fileStream,
          contentType: 'video/mp4',
          contentLength: chunksize,
          contentRange: `bytes ${start}-${end}/${fileSize}`,
          acceptRanges: 'bytes',
          filename: video.filename,
        };
      } else {
        return {
          stream: fs.createReadStream(localPath),
          contentType: 'video/mp4',
          contentLength: fileSize,
          acceptRanges: 'bytes',
          filename: video.filename,
        };
      }
    }

    if (!video.drive_file_id) {
      throw new Error(`Video ${shortCode} missing media storage ID`);
    }

    const storage = await getStorageProvider();
    const mediaStream = await storage.getFileStream(video.drive_file_id, rangeHeader);

    // Increment view count asynchronously
    db.upsertVideo({
      id: video.id,
      view_count: (video.view_count || 0) + 1,
    }).catch((err: any) => logger.warn('Failed to increment view count', { error: err.message }));

    return {
      ...mediaStream,
      filename: video.filename,
    };
  }

  async getDownloadForVideo(shortCode: string) {
    const video = await db.getVideoByShortCode(shortCode);
    if (!video) throw new Error(`Video not found with code ${shortCode}`);

    const event = await db.getEventById(video.event_id);
    if (event && event.is_download_enabled === false) {
      throw new Error('Downloads are disabled for this event');
    }

    // 1. Check if video exists in local disk storage
    const localPath = path.join(LOCAL_STORAGE_DIR, video.filename);
    if (fs.existsSync(localPath)) {
      const stat = fs.statSync(localPath);
      db.upsertVideo({
        id: video.id,
        download_count: (video.download_count || 0) + 1,
      }).catch(() => {});

      return {
        stream: fs.createReadStream(localPath),
        contentType: 'video/mp4',
        contentLength: stat.size,
        filename: video.filename,
      };
    }

    if (!video.drive_file_id) {
      throw new Error(`Video ${shortCode} missing media storage ID`);
    }

    const storage = await getStorageProvider();
    const mediaStream = await storage.getDownloadStream(video.drive_file_id);

    // Increment download count asynchronously
    db.upsertVideo({
      id: video.id,
      download_count: (video.download_count || 0) + 1,
    }).catch((err: any) => logger.warn('Failed to increment download count', { error: err.message }));

    const cleanSlug = event ? event.gallery_slug : 'event';
    const downloadFilename = `luster360_${cleanSlug}_${video.short_code}.mp4`;

    return {
      ...mediaStream,
      filename: downloadFilename,
    };
  }

  async getThumbnailForVideo(shortCode: string) {
    const video = await db.getVideoByShortCode(shortCode);
    if (!video) throw new Error(`Video not found with code ${shortCode}`);

    const fileId = video.drive_thumbnail_file_id || video.drive_file_id;
    if (!fileId) throw new Error('Thumbnail not available');

    const storage = await getStorageProvider();
    return storage.getFileStream(fileId);
  }

  async listRecentVideos(limit = 20) {
    const list = await db.listRecentVideos(limit);
    // Enrich with event info
    const enriched = await Promise.all(
      list.map(async (v: any) => {
        const ev = v.event_id ? await db.getEventById(v.event_id) : null;
        return {
          ...v,
          eventName: ev ? ev.name : 'Commercial 360 Event',
        };
      })
    );
    return enriched;
  }

  async registerCapture(payload: any) {
    const id = payload.id || `vid-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    const shortCode = payload.shortCode || payload.short_code || `L360-${Math.floor(1000 + Math.random() * 9000)}`;
    const record = {
      id,
      event_id: payload.eventId || payload.event_id || null,
      device_id: payload.deviceId || payload.device_id || 'LUSTER-BOOTH-01',
      short_code: shortCode,
      filename: payload.filename || `360_${Date.now()}.mp4`,
      duration_seconds: payload.duration || payload.duration_seconds || 5,
      guest_contact: payload.guestContact || payload.guest_contact || null,
      storage_status: payload.storageStatus || payload.storage_status || 'READY',
      publication_status: 'READY',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };
    await db.upsertVideo(record);
    return record;
  }

  async uploadAndRegisterCapture(payload: any, file?: Express.Multer.File) {
    const id = payload.id || `vid-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    const shortCode = payload.shortCode || payload.short_code || `L360-${Math.floor(1000 + Math.random() * 9000)}`;
    const eventId = payload.eventId || payload.event_id || null;
    const filename = file?.originalname || payload.filename || `360_${Date.now()}.mp4`;

    let driveFileId: string | null = null;
    let driveWebViewLink: string | null = null;
    let storageStatus = 'READY';

    if (file && file.buffer && file.buffer.length > 0) {
      // 1. Always save to local server disk for instant, zero-latency streaming & download
      try {
        const localPath = path.join(LOCAL_STORAGE_DIR, filename);
        fs.writeFileSync(localPath, file.buffer);
        logger.info(`Persisted 360 video to local server disk: ${localPath} (${file.size} bytes)`);
      } catch (e: any) {
        logger.warn(`Could not save local disk copy: ${e.message}`);
      }

      try {
        const storage = await getStorageProvider();
        let targetFolderId: string | undefined = undefined;

        if (eventId) {
          const event = await db.getEventById(eventId);
          if (event) {
            targetFolderId = event.drive_videos_folder_id || event.drive_root_folder_id;
          }
        }

        if (!targetFolderId) {
          targetFolderId = config.googleDrive.rootFolderId;
        }

        if (targetFolderId) {
          logger.info(`Uploading captured 360 video "${filename}" (${file.size} bytes) to Google Drive folder: ${targetFolderId}`);
          const uploadRecord = await storage.uploadFile({
            filename,
            mimeType: file.mimetype || 'video/mp4',
            stream: Readable.from(file.buffer),
            parentFolderId: targetFolderId,
            sizeBytes: file.size,
          });

          driveFileId = uploadRecord.fileId;
          driveWebViewLink = uploadRecord.webViewLink || null;
          logger.info(`Successfully uploaded video to Google Drive: ${driveFileId}`);
        }
      } catch (err: any) {
        logger.error(`Failed to stream video to Google Drive: ${err.message}`);
        storageStatus = 'LOCAL_SAVED';
      }
    }

    const record = {
      id,
      event_id: eventId,
      device_id: payload.deviceId || payload.device_id || 'LUSTER-BOOTH-01',
      short_code: shortCode,
      filename,
      duration_seconds: Number(payload.duration || payload.duration_seconds || 5),
      guest_contact: payload.guestContact || payload.guest_contact || null,
      storage_status: storageStatus,
      publication_status: 'READY',
      drive_file_id: driveFileId,
      drive_web_view_link: driveWebViewLink,
      file_size: file ? file.size : 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    await db.upsertVideo(record);
    return record;
  }
}

export const videoService = new VideoService();
