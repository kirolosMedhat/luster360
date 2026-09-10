# LUSTER 360 — ENVIRONMENT VARIABLE SPECIFICATION

## 1. Security Classification & Separation

Environment variables in LUSTER 360 are divided into two security tiers:
1. **Server-Only (Confidential / Secret)**: Never exposed to clients, web browsers, or mobile apps. Contains Google Cloud service account private keys, Supabase Service Role keys, and database credentials.
2. **Client-Safe (Public)**: Prefixed with `NEXT_PUBLIC_` or compiled into mobile client constants. Contains API endpoint URLs, public gallery domains, and anonymous Supabase public keys.

---

## 2. LUSTER Media API Backend (`backend/.env`)

| Variable | Type | Default / Example | Description |
|---|---|---|---|
| `PORT` | Number | `4000` | Port on which the Express server listens |
| `NODE_ENV` | String | `development` / `production` | Node execution environment |
| `API_BASE_URL` | String | `http://localhost:4000` | Canonical public URL of the backend API |
| `CORS_ORIGIN` | String | `http://localhost:3000,http://localhost:3001` | Comma-separated allowed origins |
| `RATE_LIMIT_WINDOW_MS` | Number | `900000` (15 mins) | Ingress rate limit sliding window |
| `RATE_LIMIT_MAX` | Number | `300` | Max requests per IP per window |
| `SUPABASE_URL` | String | `https://xyzcompany.supabase.co` | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | String (Secret) | `eyJh...` | Supabase service role secret (bypasses RLS) |
| `SUPABASE_ANON_KEY` | String | `eyJh...` | Supabase public anonymous key |
| `STORAGE_PROVIDER` | String | `GOOGLE_DRIVE` | Active media storage engine (`GOOGLE_DRIVE` or `MOCK`) |
| `GOOGLE_DRIVE_PARENT_FOLDER_ID` | String | `1g9P-ABC123xyz...` | ID of root folder in Google Drive where events are created |
| `GOOGLE_SERVICE_ACCOUNT_KEY` | JSON String | `{"type":"service_account",...}` | Full credentials JSON string for Service Account |
| `GOOGLE_SERVICE_ACCOUNT_EMAIL` | String | `luster-bot@project.iam.gserviceaccount.com` | Alternative: explicit Service Account email |
| `GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY` | String (Secret) | `"-----BEGIN PRIVATE KEY-----\n..."` | Alternative: explicit RSA private key |
| `GOOGLE_OAUTH_CLIENT_ID` | String | `...apps.googleusercontent.com` | Optional OAuth2 client ID (for user auth flow) |
| `GOOGLE_OAUTH_CLIENT_SECRET` | String (Secret) | `GOCSPX-...` | Optional OAuth2 client secret |
| `GOOGLE_OAUTH_REFRESH_TOKEN` | String (Secret) | `1//0...` | Optional OAuth2 refresh token |

---

## 3. Public Customer Gallery (`web/apps/events-gallery/.env.local`)

| Variable | Client Safe | Default / Example | Description |
|---|---|---|---|
| `NEXT_PUBLIC_API_URL` | Yes | `http://localhost:4000` | Base URL of the Luster Media API |
| `NEXT_PUBLIC_GALLERY_DOMAIN` | Yes | `http://localhost:3000` | Canonical domain used to construct QR codes |

---

## 4. Operations Command Center (`web/apps/command-center/.env.local`)

| Variable | Client Safe | Default / Example | Description |
|---|---|---|---|
| `NEXT_PUBLIC_API_URL` | Yes | `http://localhost:4000` | Base URL of the Luster Media API |
| `NEXT_PUBLIC_SUPABASE_URL` | Yes | `https://xyzcompany.supabase.co` | Supabase project URL for realtime subscriptions |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Yes | `eyJh...` | Supabase public anonymous key |

---

## 5. Mobile Booth Application (Flutter `--dart-define`)

| Parameter | Default | Production Example |
|---|---|---|
| `LUSTER_API_BASE_URL` | `http://10.0.2.2:4000/api/v1` (Android Emulator) | `https://api.luster360.com/api/v1` |
| `LUSTER_GALLERY_DOMAIN` | `https://gallery.luster360.com` | `https://gallery.luster360.com` |
