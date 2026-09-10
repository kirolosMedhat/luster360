# LUSTER 360 — REST API SPECIFICATION

## 1. Overview & Authentication

The LUSTER 360 Media API runs on Node.js / Express and serves as the secure gateway connecting booth hardware, web applications, Supabase PostgreSQL, and Google Drive V1 media storage.

- **Base URL**: `https://api.luster360.com/api/v1` (or `http://localhost:4000/api/v1` in development)
- **Content Types**: `application/json` (Standard payloads), `multipart/form-data` (Media uploads)
- **Standard Error Format**:
```json
{
  "success": false,
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "The requested video short code does not exist or has expired."
  }
}
```

### Authentication Headers
1. **Device Authentication**: Mobile booths send the assigned device secret in the header:
   ```http
   X-Luster-Device-Token: dev_secret_9a7b2c...
   ```
2. **Operator & Admin Authentication**: Supabase JWT or Admin Key:
   ```http
   Authorization: Bearer <jwt_access_token>
   ```

---

## 2. System & Storage Health

### `GET /system/health`
Checks server uptime, Supabase PostgreSQL connectivity, and active Media Storage provider readiness.

- **Auth**: None
- **Response `200 OK`**:
```json
{
  "status": "healthy",
  "timestamp": "2026-09-10T20:30:00.000Z",
  "storageProvider": "GOOGLE_DRIVE",
  "storageHealth": {
    "provider": "GOOGLE_DRIVE",
    "isConfigured": true,
    "hasCredentials": true,
    "rootFolderAccessible": true
  },
  "database": "connected"
}
```

---

## 3. Events & Operations Endpoints

### `GET /events`
Lists all events with calculated duration, device assignments, and Google Drive folder IDs.
- **Auth**: None (or authenticated for operator-specific filtering)
- **Response `200 OK`**: Array of event objects.

### `GET /events/:id`
Fetch single event by UUID.

### `GET /events/by-slug/:slug`
Fetch single event by its public gallery slug (e.g. `ahmed-mariam`).

### `POST /events`
Creates a new event and automatically provisions the Google Drive folder hierarchy:
- `/{Client Name} - {Event Name}/Videos`
- `/{Client Name} - {Event Name}/Thumbnails`
- `/{Client Name} - {Event Name}/Branding`
- `/{Client Name} - {Event Name}/Assets`
- **Auth**: Required (`Admin` or `Operator`)
- **Body**:
```json
{
  "name": "Ahmed & Mariam Wedding",
  "clientName": "Ahmed Al-Sayed",
  "eventDate": "2026-09-15",
  "gallerySlug": "ahmed-mariam",
  "primaryDeviceId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
}
```

### Event Lifecycle Endpoints (UTC Anchored)
- `POST /events/:id/start`: Sets `status = 'ACTIVE'`, `started_at = UTC_NOW`.
- `POST /events/:id/pause`: Sets `status = 'PAUSED'`, records pause timestamp.
- `POST /events/:id/resume`: Sets `status = 'ACTIVE'`, updates active duration accumulator.
- `POST /events/:id/end`: Sets `status = 'COMPLETED'`, `ended_at = UTC_NOW`.

---

## 4. Idempotent Upload Engine

### `POST /uploads/initiate`
Initiates an upload for a rendered video. Guarantees that retries with the same `video_id` reuse the existing upload ticket.
- **Auth**: Required (`Device` or `Admin`)
- **Body**:
```json
{
  "videoId": "vid_8f3k2a_109283",
  "eventId": "evt_wedding_001",
  "deviceId": "dev_001",
  "shortCode": "8F3K2A",
  "filename": "spin_0102.mp4",
  "fileSizeBytes": 18450920,
  "durationSeconds": 15.4
}
```
- **Response `200 OK`**:
```json
{
  "success": true,
  "ticket": {
    "videoId": "vid_8f3k2a_109283",
    "shortCode": "8F3K2A",
    "status": "QUEUED",
    "targetFolderId": "1g9P...DriveFolderId"
  }
}
```

### `POST /uploads/:videoId/video`
Multipart upload of the master MP4 file.
- **Auth**: Required
- **Form Data**: `video: [File binary]`

### `POST /uploads/:videoId/thumbnail`
Multipart upload of the poster JPEG image.
- **Auth**: Required
- **Form Data**: `thumbnail: [File binary]`

### `POST /uploads/:videoId/verify`
Triggers storage verification. Confirms file integrity in Google Drive (validates size > 0 and drive file existence), transitioning status from `VERIFYING` to `READY` and setting `publication_status = 'READY'`.
- **Auth**: Required
- **Response `200 OK`**:
```json
{
  "success": true,
  "status": "READY",
  "driveFileId": "1aB2cD3eF4g5H6i7j8k9...",
  "verifiedAt": "2026-09-10T20:31:05.120Z"
}
```

---

## 5. Media Streaming & Downloads (Zero Direct Access)

### `GET /media/stream/:shortCode`
Streams the video directly to mobile browsers and gallery viewers with HTTP 206 Byte-Range support (`Accept-Ranges: bytes`).
- **Headers Supported**: `Range: bytes=0-1048575`
- **Response**: `206 Partial Content` (or `200 OK`), `Content-Type: video/mp4`
- **Security**: The client connects to `api.luster360.com`. The backend streams bytes securely from Google Drive using internal OAuth2 credentials. The client never learns the Google Drive file URL.

### `GET /media/download/:shortCode`
Forces browser download of the original master MP4 file.
- **Headers Returned**: `Content-Disposition: attachment; filename="Luster360_8F3K2A.mp4"`

### `GET /media/thumbnail/:shortCode`
Streams the JPEG thumbnail poster image (`Content-Type: image/jpeg`).

### `GET /videos/resolve/:shortCode`
Resolves metadata and readiness state for a short code. Used by the gallery to show the "Processing" state if the video is still syncing from the booth.
- **Response `200 OK`**:
```json
{
  "shortCode": "8F3K2A",
  "status": "READY",
  "duration": 15.4,
  "eventName": "Ahmed & Mariam Wedding",
  "streamUrl": "/api/v1/media/stream/8F3K2A",
  "downloadUrl": "/api/v1/media/download/8F3K2A",
  "thumbnailUrl": "/api/v1/media/thumbnail/8F3K2A"
}
```

---

## 6. Devices & Telemetry Endpoints

### `POST /devices/register`
Hardware enrollment handshake.
- **Body**:
```json
{
  "deviceIdentifier": "LUSTER-360-004",
  "deviceName": "Booth Unit 4 (Red Dragon)",
  "platform": "android",
  "appVersion": "1.0.0+1"
}
```
- **Response `201 Created`**: Returns one-time secret `device_token`. Operator stores this in the app.

### `POST /devices/heartbeat`
Emitted every 30 seconds by the mobile booth.
- **Body**:
```json
{
  "deviceId": "dev_001",
  "batteryLevel": 92,
  "isCharging": true,
  "storageFreeBytes": 42949672960,
  "storageTotalBytes": 128000000000,
  "operationalState": "READY",
  "networkType": "WIFI",
  "appVersion": "1.0.0+1"
}
```

### `GET /devices/fleet`
Returns fleet telemetry for all booths. Devices without a heartbeat within 120 seconds are dynamically flagged `OFFLINE`.

---

## 7. Public Customer Galleries

### `GET /galleries/:slug`
Fetches gallery header, theme colors, and array of ready videos for guest display.
- **Query Params**: `?password=<pass>` (if password-protected)
- **Response `200 OK`**:
```json
{
  "slug": "ahmed-mariam",
  "title": "Ahmed & Mariam Wedding",
  "primaryColor": "#86CFFF",
  "secondaryColor": "#18283F",
  "videos": [
    {
      "shortCode": "8F3K2A",
      "thumbnailUrl": "/api/v1/media/thumbnail/8F3K2A",
      "duration": 15.4,
      "createdAt": "2026-09-10T19:42:00.000Z"
    }
  ]
}
```
