-- ==============================================================================
-- LUSTER 360 PLATFORM — INITIAL DATABASE SCHEMA MIGRATION
-- Migration: 20260910000001_initial_schema.sql
-- Description: Complete production schema including devices, events with Google Drive
--              folder mappings, video storage state machine, heartbeat telemetry,
--              Row Level Security (RLS) policies, and performance indexes.
-- ==============================================================================

-- Enable required PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 1. ENUMS & DOMAINS
-- ==============================================================================

CREATE TYPE user_role AS ENUM (
    'OWNER',
    'ADMIN',
    'OPERATOR',
    'DEVICE'
);

CREATE TYPE device_status AS ENUM (
    'REGISTERED',
    'ONLINE',
    'OFFLINE',
    'DECOMMISSIONED'
);

CREATE TYPE device_operational_state AS ENUM (
    'IDLE',
    'READY',
    'COUNTDOWN',
    'RECORDING',
    'PROCESSING',
    'RENDERING',
    'UPLOADING',
    'ERROR',
    'OFFLINE'
);

CREATE TYPE event_status AS ENUM (
    'DRAFT',
    'UPCOMING',
    'ACTIVE',
    'PAUSED',
    'COMPLETED',
    'ARCHIVED'
);

CREATE TYPE gallery_visibility AS ENUM (
    'PUBLIC',
    'PRIVATE',
    'PASSWORD_PROTECTED',
    'EXPIRED',
    'DISABLED'
);

CREATE TYPE storage_provider_type AS ENUM (
    'GOOGLE_DRIVE',
    'SUPABASE_STORAGE',
    'S3',
    'CLOUDFLARE_R2',
    'LOCAL_ONLY'
);

CREATE TYPE video_storage_status AS ENUM (
    'LOCAL_ONLY',
    'QUEUED',
    'UPLOADING',
    'UPLOADED',
    'VERIFYING',
    'READY',
    'FAILED'
);

CREATE TYPE video_publication_status AS ENUM (
    'DRAFT',
    'PROCESSING',
    'UPLOADING',
    'READY',
    'HIDDEN',
    'EXPIRED'
);

CREATE TYPE render_status AS ENUM (
    'QUEUED',
    'PROCESSING',
    'COMPLETED',
    'FAILED',
    'CANCELLED'
);

-- ==============================================================================
-- 2. CORE USERS & PROFILES
-- ==============================================================================

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role user_role NOT NULL DEFAULT 'OPERATOR',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ==============================================================================
-- 3. HARDWARE DEVICES & FLEET MANAGEMENT
-- ==============================================================================

CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_identifier TEXT UNIQUE NOT NULL, -- e.g. "LUSTER-360-001"
    device_name TEXT NOT NULL,              -- Friendly name e.g. "Main Booth Cairo"
    device_token_hash TEXT NOT NULL,        -- SHA-256 hash of device authentication token
    platform TEXT NOT NULL,                 -- "android", "ios", "windows"
    os_version TEXT,
    app_version TEXT NOT NULL,
    status device_status NOT NULL DEFAULT 'REGISTERED',
    current_state device_operational_state NOT NULL DEFAULT 'IDLE',
    current_event_id UUID,                  -- References events(id) set later
    current_session_id UUID,                -- References sessions(id) set later
    battery_level INTEGER,                  -- Percentage 0-100
    is_charging BOOLEAN DEFAULT false,
    storage_free_bytes BIGINT,
    storage_total_bytes BIGINT,
    last_heartbeat TIMESTAMPTZ,
    paired_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ==============================================================================
-- 4. EVENTS & GOOGLE DRIVE EVENT FOLDER MAPPINGS
-- ==============================================================================

CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,                     -- e.g. "Ahmed & Mariam Wedding"
    event_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    timezone TEXT NOT NULL DEFAULT 'Africa/Cairo',
    venue TEXT,
    client_name TEXT NOT NULL,
    client_contact TEXT,
    client_email TEXT,
    status event_status NOT NULL DEFAULT 'DRAFT',
    
    -- Server-independent event duration tracking (UTC timestamps)
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,

    -- Branding and design
    event_logo_url TEXT,
    cover_image_url TEXT,
    brand_primary_color TEXT NOT NULL DEFAULT '#86CFFF',
    brand_secondary_color TEXT NOT NULL DEFAULT '#18283F',
    
    -- Customer Gallery Configuration
    gallery_slug TEXT UNIQUE NOT NULL,       -- URL slug e.g. "ahmed-mariam"
    gallery_visibility gallery_visibility NOT NULL DEFAULT 'PUBLIC',
    gallery_password_hash TEXT,             -- Bcrypt/argon2 hash if password-protected
    gallery_expiration_at TIMESTAMPTZ,      -- Expiration deadline
    is_download_enabled BOOLEAN NOT NULL DEFAULT true,
    is_sharing_enabled BOOLEAN NOT NULL DEFAULT true,
    custom_title TEXT,
    custom_footer_message TEXT DEFAULT 'KEEP YOUR MEMORIES SHINE FOREVER.',

    -- Google Drive V1 Storage Architecture Mapping
    drive_root_folder_id TEXT,               -- ID of event folder in Google Drive
    drive_videos_folder_id TEXT,             -- ID of "Videos" subfolder in Drive
    drive_thumbnails_folder_id TEXT,         -- ID of "Thumbnails" subfolder in Drive
    drive_branding_folder_id TEXT,           -- ID of "Branding" subfolder in Drive
    drive_assets_folder_id TEXT,             -- ID of "Assets" subfolder in Drive
    
    -- Assigned Primary Device
    primary_device_id UUID REFERENCES devices(id) ON DELETE SET NULL,
    
    created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- Add foreign key back to events from devices
ALTER TABLE devices 
    ADD CONSTRAINT fk_devices_current_event 
    FOREIGN KEY (current_event_id) REFERENCES events(id) ON DELETE SET NULL;

-- Event operator assignments
CREATE TABLE event_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role user_role NOT NULL DEFAULT 'OPERATOR',
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    UNIQUE(event_id, profile_id)
);

-- ==============================================================================
-- 5. CAPTURE SESSIONS & 360 VIDEOS
-- ==============================================================================

CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE RESTRICT,
    session_code TEXT NOT NULL,              -- Human readable session code e.g. "SES-0102"
    guest_name TEXT,
    guest_email TEXT,
    guest_phone TEXT,
    started_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    completed_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'COMPLETED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE TABLE videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    session_id UUID REFERENCES sessions(id) ON DELETE SET NULL,
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE RESTRICT,
    
    -- Public short identifier for instant QR and web links (e.g. "8F3K2A")
    short_code VARCHAR(12) UNIQUE NOT NULL,
    filename TEXT NOT NULL,

    -- Storage state machine and Provider-Agnostic metadata
    storage_provider storage_provider_type NOT NULL DEFAULT 'GOOGLE_DRIVE',
    storage_status video_storage_status NOT NULL DEFAULT 'LOCAL_ONLY',
    publication_status video_publication_status NOT NULL DEFAULT 'DRAFT',

    -- Google Drive Identifiers (V1 Primary Media Storage)
    drive_file_id TEXT,                      -- Google Drive File ID for final MP4
    drive_thumbnail_file_id TEXT,            -- Google Drive File ID for thumbnail image
    
    -- Local and Internal Storage Paths
    local_file_path TEXT,                    -- Path on mobile device filesystem
    local_thumbnail_path TEXT,               -- Path to thumbnail on mobile device
    storage_path TEXT,                       -- Abstract storage reference path
    thumbnail_path TEXT,                     -- Abstract thumbnail reference path
    
    -- Media Technical Specifications
    duration NUMERIC(6, 2),                  -- Duration in seconds (e.g. 15.40)
    width INTEGER NOT NULL DEFAULT 1080,
    height INTEGER NOT NULL DEFAULT 1920,
    fps INTEGER NOT NULL DEFAULT 30,
    codec TEXT NOT NULL DEFAULT 'h264',
    file_size BIGINT,                        -- Size in bytes
    view_count INTEGER NOT NULL DEFAULT 0,
    download_count INTEGER NOT NULL DEFAULT 0,

    -- Upload timestamps & tracking
    upload_started_at TIMESTAMPTZ,
    uploaded_at TIMESTAMPTZ,
    verified_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- Add foreign key back to sessions from devices
ALTER TABLE devices 
    ADD CONSTRAINT fk_devices_current_session 
    FOREIGN KEY (current_session_id) REFERENCES sessions(id) ON DELETE SET NULL;

-- ==============================================================================
-- 6. VIDEO RENDERS & PROCESSING PIPELINE
-- ==============================================================================

CREATE TABLE video_renders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    video_id UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE RESTRICT,
    source_file_path TEXT NOT NULL,
    output_file_path TEXT NOT NULL,
    
    -- Render Settings & Filter Graph Configurations
    speed_ramp_config JSONB,                 -- Segments e.g. [{"start": 0, "end": 3, "speed": 0.5}]
    is_reversed BOOLEAN DEFAULT false,
    boomerang_count INTEGER DEFAULT 0,
    filter_name TEXT DEFAULT 'normal',
    applied_overlays JSONB,                  -- Layer array [{id, type, x, y, scale, opacity}]
    audio_track_id UUID,
    audio_volume NUMERIC(3, 2) DEFAULT 1.0,
    audio_fade_in_sec NUMERIC(3, 1) DEFAULT 0.5,
    audio_fade_out_sec NUMERIC(3, 1) DEFAULT 0.5,
    intro_video_path TEXT,
    outro_video_path TEXT,
    
    status render_status NOT NULL DEFAULT 'QUEUED',
    progress NUMERIC(5, 2) NOT NULL DEFAULT 0.0, -- 0.00 to 100.00 %
    render_duration_ms INTEGER,
    error_message TEXT,
    ffmpeg_log TEXT,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ==============================================================================
-- 7. GALLERIES & PUBLIC ACCESS
-- ==============================================================================

CREATE TABLE galleries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID UNIQUE NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    hero_cover_url TEXT,
    visibility gallery_visibility NOT NULL DEFAULT 'PUBLIC',
    password_hash TEXT,
    is_download_enabled BOOLEAN NOT NULL DEFAULT true,
    is_sharing_enabled BOOLEAN NOT NULL DEFAULT true,
    expires_at TIMESTAMPTZ,
    total_views INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE TABLE gallery_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gallery_id UUID UNIQUE NOT NULL REFERENCES galleries(id) ON DELETE CASCADE,
    show_luster_branding BOOLEAN NOT NULL DEFAULT true,
    primary_color TEXT NOT NULL DEFAULT '#86CFFF',
    accent_color TEXT NOT NULL DEFAULT '#18283F',
    custom_css TEXT,
    google_analytics_id TEXT,
    meta_title TEXT,
    meta_description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ==============================================================================
-- 8. MEDIA ASSETS & BOOTH TEMPLATES
-- ==============================================================================

CREATE TABLE media_assets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    asset_type TEXT NOT NULL,                -- "OVERLAY_PNG", "LOGO", "AUDIO", "INTRO", "OUTRO"
    name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    storage_provider storage_provider_type NOT NULL DEFAULT 'GOOGLE_DRIVE',
    drive_file_id TEXT,
    file_size BIGINT,
    mime_type TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    is_global BOOLEAN NOT NULL DEFAULT false,
    created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE TABLE templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,                      -- e.g. "Wedding Blue", "Corporate Gold", "Luster Default"
    category TEXT NOT NULL DEFAULT 'WEDDING',
    description TEXT,
    thumbnail_url TEXT,
    config JSONB NOT NULL,                   -- Full speed ramp, overlays, filter, audio presets
    is_system_preset BOOLEAN NOT NULL DEFAULT false,
    created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ==============================================================================
-- 9. OFFLINE UPLOAD QUEUE & RETRY ENGINE
-- ==============================================================================

CREATE TABLE upload_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    video_id UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE RESTRICT,
    local_video_path TEXT NOT NULL,
    local_thumbnail_path TEXT,
    target_drive_folder_id TEXT NOT NULL,
    target_thumbnail_folder_id TEXT NOT NULL,
    status video_storage_status NOT NULL DEFAULT 'QUEUED',
    progress NUMERIC(5, 2) NOT NULL DEFAULT 0.0,
    retry_count INTEGER NOT NULL DEFAULT 0,
    max_retries INTEGER NOT NULL DEFAULT 10,
    backoff_until TIMESTAMPTZ,
    last_error TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ==============================================================================
-- 10. REALTIME DEVICE HEARTBEATS & TELEMETRY
-- ==============================================================================

CREATE TABLE device_heartbeats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
    current_event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    operational_state device_operational_state NOT NULL,
    battery_level INTEGER,
    is_charging BOOLEAN,
    storage_free_bytes BIGINT,
    network_type TEXT,                      -- "WIFI", "CELLULAR", "NONE"
    network_strength_dbm INTEGER,
    app_version TEXT NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ==============================================================================
-- 11. SUBSCRIPTIONS & AUDIT LOGS (SaaS Ready)
-- ==============================================================================

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    plan_tier TEXT NOT NULL DEFAULT 'PRO',   -- "FREE", "PRO", "BUSINESS", "ENTERPRISE"
    status TEXT NOT NULL DEFAULT 'ACTIVE',
    max_devices INTEGER NOT NULL DEFAULT 5,
    max_events_per_month INTEGER NOT NULL DEFAULT 50,
    cloud_storage_limit_bytes BIGINT DEFAULT 107374182400, -- 100 GB
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    device_id UUID REFERENCES devices(id) ON DELETE SET NULL,
    action TEXT NOT NULL,                    -- e.g. "EVENT_CREATED", "VIDEO_DELETED", "DEVICE_PAIRED"
    resource_type TEXT NOT NULL,             -- "EVENT", "VIDEO", "DEVICE", "GALLERY"
    resource_id TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    ip_address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ==============================================================================
-- 12. PERFORMANCE INDEXES
-- ==============================================================================

CREATE INDEX idx_devices_device_identifier ON devices(device_identifier);
CREATE INDEX idx_devices_status ON devices(status);
CREATE INDEX idx_devices_last_heartbeat ON devices(last_heartbeat);

CREATE INDEX idx_events_gallery_slug ON events(gallery_slug);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_event_date ON events(event_date);
CREATE INDEX idx_events_started_at ON events(started_at);

CREATE INDEX idx_videos_short_code ON videos(short_code);
CREATE INDEX idx_videos_event_id ON videos(event_id);
CREATE INDEX idx_videos_device_id ON videos(device_id);
CREATE INDEX idx_videos_storage_status ON videos(storage_status);
CREATE INDEX idx_videos_publication_status ON videos(publication_status);
CREATE INDEX idx_videos_created_at ON videos(created_at DESC);

CREATE INDEX idx_upload_queue_status ON upload_queue(status);
CREATE INDEX idx_upload_queue_device_id ON upload_queue(device_id);
CREATE INDEX idx_upload_queue_backoff ON upload_queue(backoff_until);

CREATE INDEX idx_device_heartbeats_device_id_timestamp ON device_heartbeats(device_id, timestamp DESC);

-- ==============================================================================
-- 13. TRIGGERS & AUTOMATION
-- ==============================================================================

-- Update timestamp helper function
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = timezone('utc', now());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER set_profiles_timestamp BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_devices_timestamp BEFORE UPDATE ON devices FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_events_timestamp BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_videos_timestamp BEFORE UPDATE ON videos FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_galleries_timestamp BEFORE UPDATE ON galleries FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_upload_queue_timestamp BEFORE UPDATE ON upload_queue FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

-- Sync device state from heartbeats automatically
CREATE OR REPLACE FUNCTION trigger_update_device_from_heartbeat()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE devices
    SET 
        last_heartbeat = NEW.timestamp,
        current_state = NEW.operational_state,
        battery_level = NEW.battery_level,
        is_charging = NEW.is_charging,
        storage_free_bytes = NEW.storage_free_bytes,
        current_event_id = COALESCE(NEW.current_event_id, devices.current_event_id),
        status = 'ONLINE',
        updated_at = timezone('utc', now())
    WHERE id = NEW.device_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_device_heartbeat_received
AFTER INSERT ON device_heartbeats
FOR EACH ROW EXECUTE FUNCTION trigger_update_device_from_heartbeat();

-- Automatically create a gallery entry when an event is inserted
CREATE OR REPLACE FUNCTION trigger_auto_create_gallery()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO galleries (event_id, slug, title, hero_cover_url, visibility, expires_at)
    VALUES (
        NEW.id,
        NEW.gallery_slug,
        NEW.name,
        NEW.cover_image_url,
        NEW.gallery_visibility,
        NEW.gallery_expiration_at
    )
    ON CONFLICT (event_id) DO NOTHING;

    INSERT INTO gallery_settings (gallery_id, primary_color, accent_color)
    SELECT g.id, NEW.brand_primary_color, NEW.brand_secondary_color
    FROM galleries g
    WHERE g.event_id = NEW.id
    ON CONFLICT (gallery_id) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_event_created_create_gallery
AFTER INSERT ON events
FOR EACH ROW EXECUTE FUNCTION trigger_auto_create_gallery();

-- ==============================================================================
-- 14. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_renders ENABLE ROW LEVEL SECURITY;
ALTER TABLE galleries ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE media_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE upload_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_heartbeats ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Helper function: Is user an admin or owner?
CREATE OR REPLACE FUNCTION auth_is_admin_or_owner()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid() AND role IN ('OWNER', 'ADMIN') AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function: Does user have access to the event?
CREATE OR REPLACE FUNCTION auth_can_access_event(target_event_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    IF auth_is_admin_or_owner() THEN
        RETURN true;
    END IF;
    RETURN EXISTS (
        SELECT 1 FROM event_members
        WHERE event_id = target_event_id AND profile_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- PROFILES: Users can read own profile; Admins can read/write all
CREATE POLICY "Users view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id OR auth_is_admin_or_owner());

CREATE POLICY "Admins manage profiles" ON profiles
    FOR ALL USING (auth_is_admin_or_owner());

-- DEVICES: Devices and operators can access
CREATE POLICY "Admins manage devices" ON devices
    FOR ALL USING (auth_is_admin_or_owner());

CREATE POLICY "Devices can read own record" ON devices
    FOR SELECT USING (true);

-- EVENTS: Operators view assigned events; Admins manage all; Public can view basic info via slug
CREATE POLICY "Public can view published events" ON events
    FOR SELECT USING (gallery_visibility IN ('PUBLIC', 'PASSWORD_PROTECTED'));

CREATE POLICY "Admins manage events" ON events
    FOR ALL USING (auth_is_admin_or_owner());

CREATE POLICY "Operators view assigned events" ON events
    FOR SELECT USING (auth_can_access_event(id));

-- VIDEOS: Crucial public access policy for customer gallery
CREATE POLICY "Public can view READY videos from public events" ON videos
    FOR SELECT USING (
        publication_status = 'READY'
        AND EXISTS (
            SELECT 1 FROM events
            WHERE events.id = videos.event_id 
              AND events.gallery_visibility IN ('PUBLIC', 'PASSWORD_PROTECTED')
        )
    );

CREATE POLICY "Admins and operators manage videos" ON videos
    FOR ALL USING (auth_can_access_event(event_id));

-- GALLERIES: Public can view active galleries
CREATE POLICY "Public can view galleries" ON galleries
    FOR SELECT USING (visibility IN ('PUBLIC', 'PASSWORD_PROTECTED'));

CREATE POLICY "Public can view gallery settings" ON gallery_settings
    FOR SELECT USING (true);

CREATE POLICY "Admins manage galleries" ON galleries
    FOR ALL USING (auth_is_admin_or_owner());

-- HEARTBEATS: Realtime publication for Command Center
CREATE POLICY "Heartbeats select for authenticated operators" ON device_heartbeats
    FOR SELECT USING (auth_is_admin_or_owner());

CREATE POLICY "Heartbeats insert allowed" ON device_heartbeats
    FOR INSERT WITH CHECK (true);

-- UPLOAD QUEUE: Device & Admin access
CREATE POLICY "Upload queue access" ON upload_queue
    FOR ALL USING (auth_is_admin_or_owner() OR auth_can_access_event(event_id));

-- Enable Supabase Realtime on critical tables for Command Center
ALTER PUBLICATION supabase_realtime ADD TABLE devices;
ALTER PUBLICATION supabase_realtime ADD TABLE device_heartbeats;
ALTER PUBLICATION supabase_realtime ADD TABLE events;
ALTER PUBLICATION supabase_realtime ADD TABLE videos;
ALTER PUBLICATION supabase_realtime ADD TABLE upload_queue;
