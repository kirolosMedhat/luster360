# LUSTER 360 — Google Drive V1 Setup & Production Integration Guide

This guide details the exact steps required to configure Google Drive as the V1 primary media storage engine for LUSTER 360.

---

## 1. Overview of the Storage Architecture

In LUSTER 360:
- **Finished 360 MP4 videos and thumbnails are stored in Google Drive.**
- **PostgreSQL / Supabase stores media metadata, relationships, and authentication.**
- **The dedicated LUSTER Media API backend (`backend/`)** acts as the secure storage resolver and credentials guardian.
- **Customers NEVER access Google Drive directly.** All public streams and downloads pass through the Luster Media API storage resolver (`/api/v1/media/stream/:shortCode` and `/api/v1/media/download/:shortCode`).

---

## 2. Google Cloud Platform Setup

### Step 1: Create a Google Cloud Project
1. Open the [Google Cloud Console](https://console.cloud.google.com/).
2. Click **Select a Project** → **New Project**.
3. Set the Project Name: `Luster-360-Media`.
4. Click **Create**.

### Step 2: Enable the Google Drive API
1. In the Google Cloud Console, navigate to **APIs & Services** → **Library**.
2. Search for `Google Drive API`.
3. Click **Enable**.

---

## 3. Choose Authentication Strategy

LUSTER 360 supports two production-grade authentication strategies:
- **Option A: Service Account (Recommended for dedicated workspace shared drives)**
- **Option B: OAuth2 Refresh Token (Recommended for standard Google Workspace accounts)**

### Option A: Service Account Configuration
1. Go to **APIs & Services** → **Credentials**.
2. Click **Create Credentials** → **Service Account**.
3. Name: `luster-360-backend-uploader`.
4. Grant the Service Account role: **Editor** or **Storage Admin**.
5. Once created, open the service account details, navigate to the **Keys** tab, and click **Add Key** → **Create new key** (JSON).
6. Download the key JSON securely.
7. Open Google Drive in your browser, create the root folder named `LUSTER 360`, and share this folder with the service account email (e.g. `luster-360-backend-uploader@luster-360-media.iam.gserviceaccount.com`) granting **Editor** access.
8. Set the environment variables in `backend/.env`:
   ```env
   STORAGE_PROVIDER=GOOGLE_DRIVE
   GOOGLE_DRIVE_SERVICE_ACCOUNT_EMAIL=luster-360-backend-uploader@luster-360-media.iam.gserviceaccount.com
   GOOGLE_DRIVE_SERVICE_ACCOUNT_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----\n"
   GOOGLE_DRIVE_ROOT_FOLDER_ID=your_luster_360_root_folder_id_from_url
   ```

### Option B: OAuth2 Web Application Configuration
1. Go to **APIs & Services** → **OAuth consent screen**.
   - Select **Internal** (if Google Workspace) or **External**.
   - Add scope: `https://www.googleapis.com/auth/drive`.
2. Go to **Credentials** → **Create Credentials** → **OAuth client ID** (Web application).
   - Authorized redirect URIs: `https://developers.google.com/oauthplayground`.
3. Use [Google OAuth Playground](https://developers.google.com/oauthplayground) to authorize the `https://www.googleapis.com/auth/drive` scope and exchange the authorization code for a `refresh_token`.
4. Set the environment variables in `backend/.env`:
   ```env
   STORAGE_PROVIDER=GOOGLE_DRIVE
   GOOGLE_DRIVE_CLIENT_ID=your_client_id.apps.googleusercontent.com
   GOOGLE_DRIVE_CLIENT_SECRET=your_client_secret
   GOOGLE_DRIVE_REFRESH_TOKEN=your_refresh_token
   GOOGLE_DRIVE_ROOT_FOLDER_ID=your_folder_id
   ```

---

## 4. Automatic Folder Hierarchy

When an event is created (e.g. *"Ahmed & Mariam Wedding"*), the Luster Media API automatically creates the following folder structure in Google Drive:

```text
Google Drive
└── LUSTER 360 (Root Folder)
    └── Ahmed & Mariam Wedding
        ├── Videos/       (Contains 1080x1920 MP4 finished videos)
        ├── Thumbnails/   (Contains WebP / JPG preview posters)
        ├── Branding/     (Contains custom PNG event overlays & logos)
        └── Assets/       (Contains music tracks, intros, outros)
```

The resulting Google Drive folder IDs are permanently recorded in the Supabase PostgreSQL database under the `events` table:
- `drive_root_folder_id`
- `drive_videos_folder_id`
- `drive_thumbnails_folder_id`
- `drive_branding_folder_id`

---

## 5. Security Checklist

- **NEVER** expose Google Drive credentials inside the Flutter mobile app, Android APK, iOS IPA, or Next.js browser client bundles.
- **NEVER** commit `.env` containing private keys or refresh tokens to Git.
- The LUSTER Media API acts as the sole authenticated gateway between client requests and Google Drive.
