import { db } from '../database/db';
import { getStorageProvider } from '../storage/storage-factory';
import { logger } from '../../config/logger';

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

    if (video.publication_status !== 'READY') {
      throw new Error(`Video ${shortCode} is not yet published (status: ${video.publication_status})`);
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
}

export const videoService = new VideoService();
