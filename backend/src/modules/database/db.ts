import { getSupabaseClient } from '../../config/supabase';
import { config } from '../../config/env';
import { logger } from '../../config/logger';

// In-memory cache/store for development mode or when database is bootstrapping
export const memoryDb = {
  events: new Map<string, any>(),
  devices: new Map<string, any>(),
  videos: new Map<string, any>(),
  heartbeats: [] as any[],
  uploadQueue: new Map<string, any>(),
};

export class DatabaseService {
  private supabase = getSupabaseClient();
  private isSupabaseLive = Boolean(config.supabaseServiceRoleKey && !config.supabaseUrl.includes('mock-supabase'));

  // EVENTS
  async getEventById(eventId: string) {
    if (this.isSupabaseLive) {
      try {
        const { data, error } = await this.supabase
          .from('events')
          .select('*')
          .eq('id', eventId)
          .single();

        if (!error && data) return data;
      } catch {
        // Fallback
      }
    }
    return memoryDb.events.get(eventId) || null;
  }

  async getEventBySlug(slug: string) {
    if (this.isSupabaseLive) {
      try {
        const { data, error } = await this.supabase
          .from('events')
          .select('*')
          .eq('gallery_slug', slug)
          .single();

        if (!error && data) return data;
      } catch {
        // Fallback
      }
    }
    for (const event of memoryDb.events.values()) {
      if (event.gallery_slug === slug) return event;
    }
    return null;
  }

  async createEvent(eventData: any) {
    if (this.isSupabaseLive) {
      try {
        const { data, error } = await this.supabase
          .from('events')
          .insert(eventData)
          .select()
          .single();

        if (!error && data) {
          memoryDb.events.set(data.id, data);
          return data;
        }
      } catch (e: any) {
        logger.warn('Supabase createEvent failed, saving to memoryDb', { error: e.message });
      }
    }

    const id = eventData.id || `event-${Date.now()}`;
    const record = { ...eventData, id, created_at: new Date().toISOString() };
    memoryDb.events.set(id, record);
    return record;
  }

  async updateEvent(eventId: string, updates: any) {
    if (this.isSupabaseLive) {
      try {
        const { data, error } = await this.supabase
          .from('events')
          .update(updates)
          .eq('id', eventId)
          .select()
          .single();

        if (!error && data) {
          memoryDb.events.set(eventId, data);
          return data;
        }
      } catch {
        // Fallback
      }
    }

    const existing = memoryDb.events.get(eventId) || {};
    const updated = { ...existing, ...updates, updated_at: new Date().toISOString() };
    memoryDb.events.set(eventId, updated);
    return updated;
  }

  async listEvents() {
    if (this.isSupabaseLive) {
      try {
        const { data, error } = await this.supabase
          .from('events')
          .select('*')
          .order('created_at', { ascending: false });

        if (!error && data && data.length > 0) return data;
      } catch {
        // Fallback
      }
    }
    return Array.from(memoryDb.events.values());
  }

  // VIDEOS
  async getVideoById(videoId: string) {
    if (this.isSupabaseLive) {
      try {
        const { data, error } = await this.supabase
          .from('videos')
          .select('*')
          .eq('id', videoId)
          .single();

        if (!error && data) return data;
      } catch {
        // Fallback
      }
    }
    return memoryDb.videos.get(videoId) || null;
  }

  async getVideoByShortCode(shortCode: string) {
    if (this.isSupabaseLive) {
      try {
        const { data, error } = await this.supabase
          .from('videos')
          .select('*')
          .eq('short_code', shortCode)
          .single();

        if (!error && data) return data;
      } catch {
        // Fallback
      }
    }
    for (const vid of memoryDb.videos.values()) {
      if (vid.short_code === shortCode) return vid;
    }
    return null;
  }

  async listVideosForEvent(eventId: string, readyOnly = true) {
    if (this.isSupabaseLive) {
      try {
        let query = this.supabase
          .from('videos')
          .select('*')
          .eq('event_id', eventId);

        if (readyOnly) {
          query = query.eq('publication_status', 'READY');
        }

        const { data, error } = await query.order('created_at', { ascending: false });
        if (!error && data) return data;
      } catch {
        // Fallback
      }
    }

    const list: any[] = [];
    for (const vid of memoryDb.videos.values()) {
      if (vid.event_id === eventId) {
        if (!readyOnly || vid.publication_status === 'READY') {
          list.push(vid);
        }
      }
    }
    return list;
  }

  async upsertVideo(videoData: any) {
    if (this.isSupabaseLive) {
      try {
        const { data, error } = await this.supabase
          .from('videos')
          .upsert(videoData)
          .select()
          .single();

        if (!error && data) {
          memoryDb.videos.set(data.id, data);
          return data;
        }
      } catch {
        // Fallback
      }
    }
    const id = videoData.id || `vid-${Date.now()}`;
    const existing = memoryDb.videos.get(id) || {};
    const record = { ...existing, ...videoData, id, updated_at: new Date().toISOString() };
    memoryDb.videos.set(id, record);
    return record;
  }

  // DEVICES
  async getDeviceByIdentifier(identifier: string) {
    if (this.isSupabaseLive) {
      try {
        const { data, error } = await this.supabase
          .from('devices')
          .select('*')
          .eq('device_identifier', identifier)
          .single();

        if (!error && data) return data;
      } catch {
        // Fallback
      }
    }
    for (const dev of memoryDb.devices.values()) {
      if (dev.device_identifier === identifier) return dev;
    }
    return null;
  }

  async upsertDevice(deviceData: any) {
    const devId = deviceData.device_identifier || deviceData.id;
    if (!devId || devId === 'undefined' || devId.startsWith('dev-')) {
      return null;
    }

    const cleanRecord = {
      ...deviceData,
      id: devId,
      device_identifier: devId,
      updated_at: new Date().toISOString(),
    };

    if (this.isSupabaseLive) {
      try {
        const { data, error } = await this.supabase
          .from('devices')
          .upsert(cleanRecord, { onConflict: 'device_identifier' })
          .select()
          .single();

        if (!error && data) {
          memoryDb.devices.set(devId, data);
          return data;
        }
      } catch {
        // Fallback
      }
    }
    const existing = memoryDb.devices.get(devId) || {};
    const record = { ...existing, ...cleanRecord };
    memoryDb.devices.set(devId, record);
    return record;
  }

  async recordHeartbeat(heartbeat: any) {
    if (this.isSupabaseLive) {
      try {
        await this.supabase.from('device_heartbeats').insert(heartbeat);
      } catch {
        // Fallback
      }
    }
    memoryDb.heartbeats.push(heartbeat);
    if (memoryDb.heartbeats.length > 500) memoryDb.heartbeats.shift();
  }

  async listDevices() {
    if (this.isSupabaseLive) {
      try {
        const { data, error } = await this.supabase
          .from('devices')
          .select('*')
          .order('device_identifier');

        if (!error && data && data.length > 0) return data;
      } catch {
        // Fallback
      }
    }
    return Array.from(memoryDb.devices.values());
  }

  async cleanPhantomDevices() {
    for (const [key] of memoryDb.devices.entries()) {
      if (key.startsWith('dev-') || key === 'undefined') {
        memoryDb.devices.delete(key);
      }
    }
    if (this.isSupabaseLive) {
      try {
        await this.supabase.from('devices').delete().like('device_identifier', 'dev-%');
      } catch {}
    }
  }
}

export const db = new DatabaseService();
