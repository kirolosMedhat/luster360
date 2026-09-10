-- ==============================================================================
-- LUSTER 360 PLATFORM — SEED DATA
-- Seed: seed.sql
-- Description: Realistic production demo data for Luster 360 testing.
-- ==============================================================================

-- 1. Default Templates
INSERT INTO templates (id, name, category, description, is_system_preset, config)
VALUES 
(
    'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
    'Luster Default',
    'GENERAL',
    'Signature Luster 360 speed curve with smooth slow-motion center and brand watermark.',
    true,
    '{
        "speed_ramp": [
            {"start_time": 0.0, "end_time": 2.5, "speed": 1.0},
            {"start_time": 2.5, "end_time": 7.5, "speed": 0.4},
            {"start_time": 7.5, "end_time": 10.0, "speed": 1.0}
        ],
        "is_reversed": false,
        "boomerang_count": 0,
        "filter": "cinematic",
        "output": {"width": 1080, "height": 1920, "fps": 30, "bitrate": "8M"},
        "music": {"volume": 0.9, "fade_in_sec": 0.5, "fade_out_sec": 1.0}
    }'::jsonb
),
(
    'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e',
    'Wedding Romantic Blue',
    'WEDDING',
    'Slow dramatic curve with warm romantic grade and customizable floral overlay.',
    true,
    '{
        "speed_ramp": [
            {"start_time": 0.0, "end_time": 2.0, "speed": 0.8},
            {"start_time": 2.0, "end_time": 8.0, "speed": 0.3},
            {"start_time": 8.0, "end_time": 11.0, "speed": 0.8}
        ],
        "is_reversed": false,
        "boomerang_count": 0,
        "filter": "warm",
        "output": {"width": 1080, "height": 1920, "fps": 30, "bitrate": "8M"},
        "music": {"volume": 0.8, "fade_in_sec": 1.0, "fade_out_sec": 1.5}
    }'::jsonb
),
(
    'c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f',
    'Corporate Energy Boomerang',
    'CORPORATE',
    'High-energy punch with rapid start, ultra-slow center, and instant reverse boomerang.',
    true,
    '{
        "speed_ramp": [
            {"start_time": 0.0, "end_time": 1.5, "speed": 1.5},
            {"start_time": 1.5, "end_time": 5.0, "speed": 0.5},
            {"start_time": 5.0, "end_time": 6.5, "speed": 1.5}
        ],
        "is_reversed": false,
        "boomerang_count": 1,
        "filter": "contrast",
        "output": {"width": 1080, "height": 1920, "fps": 30, "bitrate": "10M"},
        "music": {"volume": 1.0, "fade_in_sec": 0.2, "fade_out_sec": 0.5}
    }'::jsonb
)
ON CONFLICT (id) DO NOTHING;

-- 2. Initial Hardware Device Registration
INSERT INTO devices (
    id,
    device_identifier,
    device_name,
    device_token_hash,
    platform,
    os_version,
    app_version,
    status,
    current_state,
    battery_level,
    is_charging,
    storage_free_bytes,
    storage_total_bytes,
    last_heartbeat
)
VALUES 
(
    'd0000001-0000-0000-0000-000000000001',
    'LUSTER-360-001',
    'Cairo Primary Booth #1',
    '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', -- SHA256 of demo token
    'android',
    'Android 14 (API 34)',
    '1.0.0+1',
    'ONLINE',
    'READY',
    84,
    true,
    45097156608,   -- ~42 GB free
    128000000000,  -- 128 GB total
    timezone('utc', now())
),
(
    'd0000002-0000-0000-0000-000000000002',
    'LUSTER-360-002',
    'Alexandria Corporate Booth #2',
    '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8',
    'ios',
    'iOS 17.5',
    '1.0.0+1',
    'ONLINE',
    'IDLE',
    92,
    false,
    88000000000,
    256000000000,
    timezone('utc', now()) - interval '3 minutes'
),
(
    'd0000003-0000-0000-0000-000000000003',
    'LUSTER-360-003',
    'Giza Standby Booth #3',
    '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8',
    'android',
    'Android 13',
    '0.9.8+4',
    'OFFLINE',
    'OFFLINE',
    35,
    false,
    18000000000,
    64000000000,
    timezone('utc', now()) - interval '45 minutes'
)
ON CONFLICT (device_identifier) DO NOTHING;

-- 3. Demo Event: Ahmed & Mariam Wedding
INSERT INTO events (
    id,
    name,
    event_date,
    start_time,
    end_time,
    timezone,
    venue,
    client_name,
    client_contact,
    client_email,
    status,
    started_at,
    gallery_slug,
    gallery_visibility,
    brand_primary_color,
    brand_secondary_color,
    drive_root_folder_id,
    drive_videos_folder_id,
    drive_thumbnails_folder_id,
    drive_branding_folder_id,
    primary_device_id
)
VALUES
(
    'e0000001-0000-0000-0000-000000000001',
    'Ahmed & Mariam Wedding',
    CURRENT_DATE,
    '18:00:00',
    '23:59:00',
    'Africa/Cairo',
    'Four Seasons Nile Plaza, Cairo',
    'Ahmed Hassan',
    '+20 100 123 4567',
    'ahmed.hassan@example.com',
    'ACTIVE',
    timezone('utc', now()) - interval '4 hours 42 minutes', -- Simulates 04h 42m duration
    'ahmed-mariam',
    'PUBLIC',
    '#86CFFF',
    '#18283F',
    'drive_folder_root_ahmed_mariam',
    'drive_folder_videos_ahmed_mariam',
    'drive_folder_thumbs_ahmed_mariam',
    'drive_folder_branding_ahmed_mariam',
    'd0000001-0000-0000-0000-000000000001'
)
ON CONFLICT (gallery_slug) DO NOTHING;

-- Associate primary device with event
UPDATE devices 
SET current_event_id = 'e0000001-0000-0000-0000-000000000001',
    current_state = 'READY'
WHERE id = 'd0000001-0000-0000-0000-000000000001';

-- 4. Sample Completed Video Records (matching prompt examples)
INSERT INTO videos (
    id,
    event_id,
    device_id,
    short_code,
    filename,
    storage_provider,
    storage_status,
    publication_status,
    drive_file_id,
    drive_thumbnail_file_id,
    duration,
    width,
    height,
    fps,
    codec,
    file_size,
    view_count,
    download_count,
    uploaded_at,
    verified_at
)
VALUES
(
    'f0000001-0000-0000-0000-000000000001',
    'e0000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    '8F3K2A',
    'luster_360_ahmed_mariam_001.mp4',
    'GOOGLE_DRIVE',
    'READY',
    'READY',
    '1A2B3C4D5E6F7G8H9I0J_mp4',
    '1A2B3C4D5E6F7G8H9I0J_thumb',
    15.0,
    1080,
    1920,
    30,
    'h264',
    14800000, -- 14.8 MB
    42,
    18,
    timezone('utc', now()) - interval '4 hours',
    timezone('utc', now()) - interval '4 hours'
),
(
    'f0000002-0000-0000-0000-000000000002',
    'e0000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    '9X7L4Q',
    'luster_360_ahmed_mariam_002.mp4',
    'GOOGLE_DRIVE',
    'READY',
    'READY',
    '2B3C4D5E6F7G8H9I0J1A_mp4',
    '2B3C4D5E6F7G8H9I0J1A_thumb',
    14.5,
    1080,
    1920,
    30,
    'h264',
    13900000,
    28,
    12,
    timezone('utc', now()) - interval '3 hours 30 minutes',
    timezone('utc', now()) - interval '3 hours 30 minutes'
),
(
    'f0000003-0000-0000-0000-000000000003',
    'e0000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    '4M9T1Z',
    'luster_360_ahmed_mariam_003.mp4',
    'GOOGLE_DRIVE',
    'READY',
    'READY',
    '3C4D5E6F7G8H9I0J1A2B_mp4',
    '3C4D5E6F7G8H9I0J1A2B_thumb',
    15.2,
    1080,
    1920,
    30,
    'h264',
    15100000,
    19,
    7,
    timezone('utc', now()) - interval '2 hours 15 minutes',
    timezone('utc', now()) - interval '2 hours 15 minutes'
)
ON CONFLICT (short_code) DO NOTHING;
