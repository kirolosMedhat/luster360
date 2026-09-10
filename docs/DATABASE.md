# LUSTER 360 — DATABASE ARCHITECTURE & SCHEMA REFERENCE

## 1. Overview & PostgreSQL Architecture

LUSTER 360 utilizes Supabase PostgreSQL as its authoritative relational database and real-time state synchronization backbone. The database enforces:
- **Strict Referential Integrity**: Foreign keys with appropriate `ON DELETE CASCADE` or `ON DELETE RESTRICT` semantics to prevent orphan media assets or corrupt audit trails.
- **Provider-Agnostic Storage Mapping**: Abstract storage tracking with dedicated columns for Google Drive V1 file and folder identifiers.
- **Row-Level Security (RLS)**: Enforced directly at the database engine level, restricting public access exclusively to verified `short_code` entries while isolating multi-tenant operator data.
- **Dynamic Telemetry & Durations**: Realtime heartbeats and UTC timestamp anchors for drift-free operational tracking.

---

## 2. Enumerated Types (Enums)

| Enum Name | Allowed Values | Usage |
|---|---|---|
| `user_role` | `OWNER`, `ADMIN`, `OPERATOR`, `DEVICE` | Role-based authorization |
| `device_status` | `REGISTERED`, `ONLINE`, `OFFLINE`, `DECOMMISSIONED` | Hardware fleet provisioning status |
| `device_operational_state` | `IDLE`, `READY`, `COUNTDOWN`, `RECORDING`, `PROCESSING`, `RENDERING`, `UPLOADING`, `ERROR`, `OFFLINE` | Live booth state |
| `event_status` | `DRAFT`, `UPCOMING`, `ACTIVE`, `PAUSED`, `COMPLETED`, `ARCHIVED` | Event lifecycle state |
| `gallery_visibility` | `PUBLIC`, `PRIVATE`, `PASSWORD_PROTECTED`, `EXPIRED`, `DISABLED` | Public customer gallery exposure |
| `storage_provider_type` | `GOOGLE_DRIVE`, `SUPABASE_STORAGE`, `S3`, `CLOUDFLARE_R2`, `LOCAL_ONLY` | Target storage provider |
| `video_storage_status` | `LOCAL_ONLY`, `QUEUED`, `UPLOADING`, `UPLOADED`, `VERIFYING`, `READY`, `FAILED` | Video upload state machine |
| `video_publication_status` | `DRAFT`, `PROCESSING`, `UPLOADING`, `READY`, `HIDDEN`, `EXPIRED` | Guest gallery display visibility |
| `render_status` | `QUEUED`, `PROCESSING`, `COMPLETED`, `FAILED`, `CANCELLED` | FFmpeg rendering pipeline status |

---

## 3. Complete Table Specifications

### 3.1 `profiles`
User accounts and operational staff profiles extending Supabase `auth.users`.
- `id` (UUID, PK, FK `auth.users(id)` ON DELETE CASCADE)
- `email` (TEXT, UNIQUE, NOT NULL)
- `full_name` (TEXT, NOT NULL)
- `phone` (TEXT)
- `avatar_url` (TEXT)
- `role` (`user_role`, DEFAULT `'OPERATOR'`)
- `is_active` (BOOLEAN, DEFAULT `true`)
- `created_at` / `updated_at` (TIMESTAMPTZ)

### 3.2 `devices`
Physical photobooth hardware units (tablets, phones, dedicated booths).
- `id` (UUID, PK, DEFAULT `uuid_generate_v4()`)
- `device_identifier` (TEXT, UNIQUE, NOT NULL) — e.g., `LUSTER-360-001`
- `device_name` (TEXT, NOT NULL) — Friendly name, e.g., `Main Booth Cairo`
- `device_token_hash` (TEXT, NOT NULL) — SHA-256 hash of device authentication secret
- `platform` (TEXT, NOT NULL) — `android`, `ios`, `windows`
- `os_version` (TEXT)
- `app_version` (TEXT, NOT NULL)
- `status` (`device_status`, DEFAULT `'REGISTERED'`)
- `current_state` (`device_operational_state`, DEFAULT `'IDLE'`)
- `current_event_id` (UUID, FK `events(id)` ON DELETE SET NULL)
- `current_session_id` (UUID, FK `sessions(id)` ON DELETE SET NULL)
- `battery_level` (INTEGER) — 0 to 100
- `is_charging` (BOOLEAN, DEFAULT `false`)
- `storage_free_bytes` (BIGINT)
- `storage_total_bytes` (BIGINT)
- `last_heartbeat` (TIMESTAMPTZ)
- `paired_by` (UUID, FK `profiles(id)` ON DELETE SET NULL)
- `created_at` / `updated_at` (TIMESTAMPTZ)

### 3.3 `events`
Event bookings, timing anchors, and Google Drive folder mappings.
- `id` (UUID, PK, DEFAULT `uuid_generate_v4()`)
- `name` (TEXT, NOT NULL) — e.g., `Ahmed & Mariam Wedding`
- `event_date` (DATE, NOT NULL)
- `start_time` / `end_time` (TIME)
- `timezone` (TEXT, DEFAULT `'Africa/Cairo'`)
- `venue` (TEXT)
- `client_name` (TEXT, NOT NULL)
- `client_contact` / `client_email` (TEXT)
- `status` (`event_status`, DEFAULT `'DRAFT'`)
- **Server-Independent Duration Anchors**:
  - `started_at` (TIMESTAMPTZ) — Authoritative live session activation timestamp
  - `ended_at` (TIMESTAMPTZ) — Authoritative session conclusion timestamp
- **Branding**:
  - `event_logo_url` (TEXT)
  - `cover_image_url` (TEXT)
  - `brand_primary_color` (TEXT, DEFAULT `'#86CFFF'`)
  - `brand_secondary_color` (TEXT, DEFAULT `'#18283F'`)
- **Gallery Configuration**:
  - `gallery_slug` (TEXT, UNIQUE, NOT NULL)
  - `gallery_visibility` (`gallery_visibility`, DEFAULT `'PUBLIC'`)
  - `gallery_password_hash` (TEXT)
  - `gallery_expiration_at` (TIMESTAMPTZ)
  - `is_download_enabled` / `is_sharing_enabled` (BOOLEAN, DEFAULT `true`)
  - `custom_title` / `custom_footer_message` (TEXT)
- **Google Drive Storage Hierarchy**:
  - `drive_root_folder_id` (TEXT) — Event root folder ID in Google Drive
  - `drive_videos_folder_id` (TEXT) — Subfolder for rendered MP4s
  - `drive_thumbnails_folder_id` (TEXT) — Subfolder for poster images
  - `drive_branding_folder_id` (TEXT) — Subfolder for event logos & templates
  - `drive_assets_folder_id` (TEXT) — Subfolder for audio & raw overlays
- `primary_device_id` (UUID, FK `devices(id)` ON DELETE SET NULL)
- `created_by` (UUID, FK `profiles(id)` ON DELETE SET NULL)
- `created_at` / `updated_at` (TIMESTAMPTZ)

### 3.4 `event_members`
Operator assignments to specific events.
- `id` (UUID, PK)
- `event_id` (UUID, FK `events(id)` ON DELETE CASCADE)
- `profile_id` (UUID, FK `profiles(id)` ON DELETE CASCADE)
- `role` (`user_role`, DEFAULT `'OPERATOR'`)
- `assigned_at` (TIMESTAMPTZ)
- *Constraint*: `UNIQUE(event_id, profile_id)`

### 3.5 `sessions`
Individual booth guest sessions (each spin of the 360 arm).
- `id` (UUID, PK)
- `event_id` (UUID, FK `events(id)` ON DELETE CASCADE)
- `device_id` (UUID, FK `devices(id)` ON DELETE RESTRICT)
- `session_code` (TEXT, NOT NULL) — e.g., `SES-0102`
- `guest_name`, `guest_email`, `guest_phone` (TEXT)
- `started_at` / `completed_at` (TIMESTAMPTZ)
- `status` (TEXT, DEFAULT `'COMPLETED'`)

### 3.6 `videos`
Master records for all captured and rendered videos.
- `id` (UUID, PK)
- `event_id` (UUID, FK `events(id)` ON DELETE CASCADE)
- `session_id` (UUID, FK `sessions(id)` ON DELETE SET NULL)
- `device_id` (UUID, FK `devices(id)` ON DELETE RESTRICT)
- `short_code` (VARCHAR(12), UNIQUE, NOT NULL) — e.g., `8F3K2A` for `https://gallery.luster360.com/v/8F3K2A`
- `filename` (TEXT, NOT NULL)
- `storage_provider` (`storage_provider_type`, DEFAULT `'GOOGLE_DRIVE'`)
- `storage_status` (`video_storage_status`, DEFAULT `'LOCAL_ONLY'`)
- `publication_status` (`video_publication_status`, DEFAULT `'DRAFT'`)
- `drive_file_id` (TEXT) — Google Drive File ID for final MP4
- `drive_thumbnail_file_id` (TEXT) — Google Drive File ID for thumbnail
- `local_file_path` / `local_thumbnail_path` (TEXT)
- `storage_path` / `thumbnail_path` (TEXT)
- `duration` (NUMERIC(6, 2)) — In seconds
- `width` (INTEGER, DEFAULT 1080), `height` (INTEGER, DEFAULT 1920), `fps` (INTEGER, DEFAULT 30)
- `codec` (TEXT, DEFAULT `'h264'`), `file_size` (BIGINT)
- `view_count` (INTEGER, DEFAULT 0), `download_count` (INTEGER, DEFAULT 0)
- `upload_started_at`, `uploaded_at`, `verified_at` (TIMESTAMPTZ)
- `created_at` / `updated_at` (TIMESTAMPTZ)

### 3.7 `video_renders`
FFmpeg job records and configuration history.
- `id` (UUID, PK)
- `video_id` (UUID, FK `videos(id)` ON DELETE CASCADE)
- `event_id` (UUID, FK `events(id)` ON DELETE CASCADE)
- `device_id` (UUID, FK `devices(id)` ON DELETE RESTRICT)
- `source_file_path` / `output_file_path` (TEXT, NOT NULL)
- `speed_ramp_config` (JSONB) — Normalized segments `[{"start": 0, "end": 3, "speed": 0.5}]`
- `is_reversed` (BOOLEAN, DEFAULT `false`), `boomerang_count` (INTEGER, DEFAULT 0)
- `filter_name` (TEXT, DEFAULT `'normal'`)
- `applied_overlays` (JSONB) — Layer stack
- `audio_track_id` (UUID), `audio_volume` (NUMERIC), `audio_fade_in_sec` / `audio_fade_out_sec` (NUMERIC)
- `intro_video_path` / `outro_video_path` (TEXT)
- `status` (`render_status`, DEFAULT `'QUEUED'`)
- `progress` (NUMERIC, DEFAULT 0.0), `render_duration_ms` (INTEGER)
- `error_message`, `ffmpeg_log` (TEXT)
- `started_at` / `completed_at` (TIMESTAMPTZ)

### 3.8 `galleries` & `gallery_settings`
Public gallery branding and access configurations.
- `galleries`: `id`, `event_id` (UNIQUE), `slug` (UNIQUE), `title`, `hero_cover_url`, `visibility`, `password_hash`, `is_download_enabled`, `is_sharing_enabled`, `expires_at`, `total_views`.
- `gallery_settings`: `gallery_id` (UNIQUE), `show_luster_branding`, `primary_color`, `accent_color`, `custom_css`, `google_analytics_id`, `meta_title`, `meta_description`.

### 3.9 `media_assets` & `templates`
Branding graphics, audio tracks, and reusable booth configurations.
- `media_assets`: Assets stored in Google Drive (`OVERLAY_PNG`, `LOGO`, `AUDIO`, `INTRO`, `OUTRO`).
- `templates`: Complete booth presets (`Wedding Blue`, `Corporate Gold`, `Luster Default`) including speed ramping and overlay layers.

### 3.10 `upload_queue`
Offline synchronization queue tracking local files awaiting upload.
- `id` (UUID, PK)
- `video_id` (UUID, FK `videos(id)` ON DELETE CASCADE)
- `event_id` (UUID, FK `events(id)` ON DELETE CASCADE)
- `device_id` (UUID, FK `devices(id)` ON DELETE RESTRICT)
- `local_video_path`, `local_thumbnail_path` (TEXT)
- `target_drive_folder_id`, `target_thumbnail_folder_id` (TEXT)
- `status` (`video_storage_status`, DEFAULT `'QUEUED'`)
- `progress` (NUMERIC), `retry_count` (INTEGER), `max_retries` (INTEGER, DEFAULT 10)
- `backoff_until` (TIMESTAMPTZ), `last_error` (TEXT)

### 3.11 `device_heartbeats`
High-resolution operational telemetry history.
- `id` (UUID, PK)
- `device_id` (UUID, FK `devices(id)` ON DELETE CASCADE)
- `current_event_id` (UUID, FK `events(id)` ON DELETE SET NULL)
- `operational_state` (`device_operational_state`, NOT NULL)
- `battery_level` (INTEGER), `is_charging` (BOOLEAN)
- `storage_free_bytes` (BIGINT)
- `network_type` (TEXT), `network_strength_dbm` (INTEGER)
- `app_version` (TEXT)
- `timestamp` (TIMESTAMPTZ, DEFAULT `now()`)

### 3.12 `subscriptions` & `audit_logs`
SaaS multi-tenancy limits and immutable security audit log.
- `subscriptions`: `profile_id`, `plan_tier`, `max_devices`, `max_events_per_month`, `cloud_storage_limit_bytes`.
- `audit_logs`: `actor_id`, `device_id`, `action`, `resource_type`, `resource_id`, `metadata`, `ip_address`, `created_at`.

---

## 4. Performance Indexes

The schema creates dedicated indexes targeting the critical operational queries:
```sql
CREATE INDEX idx_devices_device_identifier ON devices(device_identifier);
CREATE INDEX idx_devices_status ON devices(status);
CREATE INDEX idx_devices_last_heartbeat ON devices(last_heartbeat);

CREATE INDEX idx_events_slug ON events(gallery_slug);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_date ON events(event_date);

CREATE INDEX idx_videos_short_code ON videos(short_code);
CREATE INDEX idx_videos_event_id ON videos(event_id);
CREATE INDEX idx_videos_storage_status ON videos(storage_status);
CREATE INDEX idx_videos_created_at ON videos(created_at DESC);

CREATE INDEX idx_upload_queue_status_retry ON upload_queue(status, retry_count);
CREATE INDEX idx_heartbeats_device_timestamp ON device_heartbeats(device_id, timestamp DESC);
```

---

## 5. Row-Level Security (RLS) Policies

All tables enable RLS (`ALTER TABLE <table> ENABLE ROW LEVEL SECURITY;`).

1. **Public Anonymous Access (`anon`)**:
   - `videos`: `SELECT` permitted where `publication_status = 'READY'` and `short_code` matches request.
   - `events` & `galleries`: `SELECT` permitted where `gallery_visibility = 'PUBLIC'` and `gallery_expiration_at > now()`.
   - Direct queries for device tokens, heartbeat histories, and operator credentials are blocked.

2. **Authenticated Operator Access (`authenticated`)**:
   - Permitted `SELECT`, `INSERT`, `UPDATE` on events where the operator is assigned in `event_members` or `created_by = auth.uid()`.
   - Full read/write on media renders and upload queues belonging to their assigned events.

3. **Admin / Service Role Access (`service_role`)**:
   - Bypasses RLS to allow the backend LUSTER Media API to coordinate cross-device telemetry, folder provisioning, and storage verification.
