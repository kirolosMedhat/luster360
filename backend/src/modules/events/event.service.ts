import { db } from '../database/db';
import { getStorageProvider } from '../storage/storage-factory';
import { logger } from '../../config/logger';

export interface CreateEventDTO {
  name: string;
  eventDate: string;
  startTime?: string;
  endTime?: string;
  timezone?: string;
  venue?: string;
  clientName: string;
  clientContact?: string;
  clientEmail?: string;
  brandPrimaryColor?: string;
  brandSecondaryColor?: string;
  gallerySlug?: string;
  galleryPassword?: string;
  isDownloadEnabled?: boolean;
  isSharingEnabled?: boolean;
}

export class EventService {
  /**
   * Helper: Formats elapsed seconds into human readable format: e.g. "04h 42m"
   */
  public formatDuration(seconds: number): string {
    if (seconds < 0) seconds = 0;
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);

    const pad = (n: number) => n.toString().padStart(2, '0');
    if (hours > 0) {
      return `${pad(hours)}h ${pad(minutes)}m`;
    }
    return `${pad(minutes)}m ${pad(secs)}s`;
  }

  /**
   * Calculates deterministic server-independent duration based on UTC timestamps
   */
  public calculateEventDuration(startedAt?: string | Date | null, endedAt?: string | Date | null): {
    durationSeconds: number;
    formatted: string;
  } {
    if (!startedAt) {
      return { durationSeconds: 0, formatted: '00h 00m' };
    }

    const start = new Date(startedAt).getTime();
    const end = endedAt ? new Date(endedAt).getTime() : Date.now();
    const diffSeconds = Math.max(0, Math.floor((end - start) / 1000));

    return {
      durationSeconds: diffSeconds,
      formatted: this.formatDuration(diffSeconds),
    };
  }

  /**
   * Creates a new event and provisions its folder hierarchy in Google Drive
   */
  public async createEvent(dto: CreateEventDTO) {
    const slug = dto.gallerySlug || dto.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
    
    // 1. Provision folder hierarchy in Google Drive (or configured MediaStorage)
    const storage = await getStorageProvider();
    let driveFolders = {
      rootFolderId: 'pending',
      videosFolderId: 'pending',
      thumbnailsFolderId: 'pending',
      brandingFolderId: 'pending',
      assetsFolderId: 'pending',
    };

    try {
      driveFolders = await storage.createEventFolders(dto.name);
      logger.info(`Provisioned Google Drive folders for "${dto.name}"`, { folders: driveFolders });
    } catch (err: any) {
      logger.warn(`Could not provision Drive folders immediately: ${err.message}. Storage will retry.`);
    }

    const eventRecord = {
      name: dto.name,
      event_date: dto.eventDate,
      start_time: dto.startTime || null,
      end_time: dto.endTime || null,
      timezone: dto.timezone || 'Africa/Cairo',
      venue: dto.venue || null,
      client_name: dto.clientName,
      client_contact: dto.clientContact || null,
      client_email: dto.clientEmail || null,
      status: 'DRAFT',
      gallery_slug: slug,
      gallery_visibility: dto.galleryPassword ? 'PASSWORD_PROTECTED' : 'PUBLIC',
      brand_primary_color: dto.brandPrimaryColor || '#86CFFF',
      brand_secondary_color: dto.brandSecondaryColor || '#18283F',
      is_download_enabled: dto.isDownloadEnabled !== false,
      is_sharing_enabled: dto.isSharingEnabled !== false,
      
      // Google Drive folder IDs
      drive_root_folder_id: driveFolders.rootFolderId,
      drive_videos_folder_id: driveFolders.videosFolderId,
      drive_thumbnails_folder_id: driveFolders.thumbnailsFolderId,
      drive_branding_folder_id: driveFolders.brandingFolderId,
      drive_assets_folder_id: driveFolders.assetsFolderId,
    };

    const created = await db.createEvent(eventRecord);
    return created;
  }

  public async startEvent(eventId: string) {
    const nowUtc = new Date().toISOString();
    return db.updateEvent(eventId, {
      status: 'ACTIVE',
      started_at: nowUtc,
      ended_at: null,
    });
  }

  public async pauseEvent(eventId: string) {
    return db.updateEvent(eventId, { status: 'PAUSED' });
  }

  public async resumeEvent(eventId: string) {
    return db.updateEvent(eventId, { status: 'ACTIVE' });
  }

  public async endEvent(eventId: string) {
    const nowUtc = new Date().toISOString();
    return db.updateEvent(eventId, {
      status: 'COMPLETED',
      ended_at: nowUtc,
    });
  }

  public async getEventWithStats(eventId: string) {
    const event = await db.getEventById(eventId);
    if (!event) return null;

    const duration = this.calculateEventDuration(event.started_at, event.ended_at);
    const videos = await db.listVideosForEvent(eventId, false);

    const uploaded = videos.filter((v: any) => v.storage_status === 'READY' || v.storage_status === 'UPLOADED').length;
    const pending = videos.filter((v: any) => v.storage_status === 'QUEUED' || v.storage_status === 'UPLOADING').length;
    const failed = videos.filter((v: any) => v.storage_status === 'FAILED').length;

    return {
      ...event,
      duration: duration.formatted,
      durationSeconds: duration.durationSeconds,
      videoStats: {
        total: videos.length,
        uploaded,
        pending,
        failed,
      },
    };
  }

  public async listEvents() {
    const events = await db.listEvents();
    return events.map((event: any) => {
      const dur = this.calculateEventDuration(event.started_at, event.ended_at);
      return {
        ...event,
        duration: dur.formatted,
        durationSeconds: dur.durationSeconds,
      };
    });
  }
}

export const eventService = new EventService();
