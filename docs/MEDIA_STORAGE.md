# LUSTER 360 — Provider-Agnostic MediaStorage Specification

## 1. Architectural Philosophy

LUSTER 360 decouples application business logic from physical cloud storage providers. The entire platform interacts with an abstract interface (`MediaStorage`).

For **V1**, `GoogleDriveStorage` is the primary production adapter.
In future iterations (**V2+**), adapters for **Cloudflare R2**, **Amazon S3**, or **Supabase Storage** can be dropped in without changing a single line of code in the Flutter mobile application, the Public Gallery, or the Command Center.

```
+-------------------------------------------------------------+
|                      LUSTER Media API                       |
+-------------------------------------------------------------+
                              |
                              v
                +----------------------------+
                |     MediaStorage (API)     |
                +----------------------------+
                              |
         +--------------------+--------------------+
         |                    |                    |
         v                    v                    v
+------------------+ +------------------+ +------------------+
|GoogleDriveStorage| | Cloudflare R2    | | Amazon S3        |
|  (V1 Production) | | (V2 Future)      | | (Enterprise)     |
+------------------+ +------------------+ +------------------+
```

---

## 2. MediaStorage Interface Methods

| Method | Parameters | Description |
| :--- | :--- | :--- |
| `initialize()` | - | Authenticates client and ensures root folder structure. |
| `healthCheck()` | - | Returns connection status: `CONNECTED`, `DEGRADED`, or `CONFIGURATION_REQUIRED`. |
| `createEventFolders(name)` | `eventName: string` | Provisions root and subfolders (`Videos`, `Thumbnails`, `Branding`, `Assets`). |
| `uploadFile(params)` | `stream, filename, parentFolderId, mimeType, sizeBytes` | Streams file to target directory with idempotency verification. |
| `verifyFile(fileId, size)` | `fileId: string, expectedSizeBytes?: number` | Confirms file exists and has non-zero size before marking `READY`. |
| `getFileStream(fileId, range)` | `fileId: string, rangeHeader?: string` | Resolves media stream with HTTP 206 Partial Content byte-range support. |
| `getDownloadStream(fileId)` | `fileId: string` | Resolves full download stream with custom attachment filename headers. |
| `findFileByName(folderId, name)`| `folderId: string, filename: string` | Checks whether identical file already exists (idempotent retries). |

---

## 3. Video Storage State Machine

Every recorded video progresses through a deterministic state machine:

```
[CAMERA CAPTURE]
       │
       ▼
  LOCAL_ONLY       (Raw MP4 & Final MP4 saved locally in device sandbox)
       │
       ▼
    QUEUED         (Task enqueued in local SQLite upload queue)
       │
       ▼
   UPLOADING       (Actively streaming bytes to Luster Media API -> Google Drive)
       │
       ▼
   UPLOADED        (Stream write completed on storage provider)
       │
       ▼
   VERIFYING       (Backend checks file existence, size, and thumbnail)
       │
       ▼
     READY         (Published to Public Gallery & QR code activated)
       │
       └──> [FAILED] (Network dropped or API error -> Exponential backoff retry)
```

---

## 4. Idempotency Guarantees

When network interruptions occur during upload, the mobile queue retries the upload with the same `video_id` and `filename`.

Before allocating a new upload stream in Google Drive, `UploadService` and `GoogleDriveStorage` query the target folder for existing files matching `filename`.
If found:
1. The upload is skipped.
2. The existing Google Drive `fileId` is reused.
3. The video is immediately marked `VERIFYING` -> `READY`.

This guarantees **zero duplicate video files** in Google Drive regardless of how many times an upload task is retried.
