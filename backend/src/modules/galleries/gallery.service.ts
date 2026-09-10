import bcrypt from 'bcryptjs';
import { db } from '../database/db';
import { config } from '../../config/env';

export class GalleryService {
  public async getPublicGallery(slug: string, passwordAttempt?: string) {
    const event = await db.getEventBySlug(slug);
    if (!event) {
      return { found: false, error: 'Gallery not found' };
    }

    // 1. Check expiration
    if (event.gallery_expiration_at) {
      const expirationDate = new Date(event.gallery_expiration_at).getTime();
      if (Date.now() > expirationDate) {
        return {
          found: true,
          isExpired: true,
          event: {
            name: event.name,
            eventDate: event.event_date,
            brandPrimaryColor: event.brand_primary_color,
          },
          error: 'This event gallery has expired.',
        };
      }
    }

    // 2. Check password protection
    if (event.gallery_visibility === 'PASSWORD_PROTECTED' && event.gallery_password_hash) {
      if (!passwordAttempt) {
        return {
          found: true,
          requiresPassword: true,
          event: {
            name: event.name,
            eventDate: event.event_date,
            brandPrimaryColor: event.brand_primary_color,
            coverImageUrl: event.cover_image_url,
          },
        };
      }

      const isValidPassword = await bcrypt.compare(passwordAttempt, event.gallery_password_hash);
      if (!isValidPassword) {
        return {
          found: true,
          requiresPassword: true,
          error: 'Incorrect password',
          event: {
            name: event.name,
            eventDate: event.event_date,
            brandPrimaryColor: event.brand_primary_color,
          },
        };
      }
    }

    // 3. Fetch only READY videos
    const rawVideos = await db.listVideosForEvent(event.id, true);

    const formattedVideos = rawVideos.map((v: any) => ({
      id: v.id,
      shortCode: v.short_code,
      duration: v.duration,
      width: v.width,
      height: v.height,
      viewCount: v.view_count || 0,
      createdAt: v.created_at,
      thumbnailUrl: `/api/v1/media/thumbnail/${v.short_code}`,
      streamUrl: `/api/v1/media/stream/${v.short_code}`,
      downloadUrl: `/api/v1/media/download/${v.short_code}`,
      shareUrl: `${config.publicGalleryUrl}/v/${v.short_code}`,
    }));

    return {
      found: true,
      requiresPassword: false,
      isExpired: false,
      event: {
        id: event.id,
        name: event.name,
        slug: event.gallery_slug,
        eventDate: event.event_date,
        venue: event.venue,
        clientName: event.client_name,
        coverImageUrl: event.cover_image_url,
        logoUrl: event.event_logo_url,
        brandPrimaryColor: event.brand_primary_color,
        brandSecondaryColor: event.brand_secondary_color,
        isDownloadEnabled: event.is_download_enabled,
        isSharingEnabled: event.is_sharing_enabled,
        customTitle: event.custom_title,
        customFooterMessage: event.custom_footer_message || 'KEEP YOUR MEMORIES SHINE FOREVER.',
      },
      galleryQrUrl: `${config.publicGalleryUrl}/event/${event.gallery_slug}`,
      videos: formattedVideos,
      totalCount: formattedVideos.length,
    };
  }
}

export const galleryService = new GalleryService();
