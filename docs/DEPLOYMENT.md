# LUSTER 360 — PRODUCTION DEPLOYMENT GUIDE

## 1. Architecture Deployment Overview

LUSTER 360 consists of four deployable cloud components:
1. **Supabase PostgreSQL Database**: Hosted on Supabase Cloud or self-hosted PostgreSQL 16+.
2. **LUSTER Media API Backend**: Node.js 20+ service running on Ubuntu VPS (Docker/PM2) or Container Platform (Render, Railway, Fly.io, AWS ECS).
3. **Public Events Gallery**: Next.js 14 application deployed on Vercel or Node.js.
4. **Operations Command Center**: Next.js 14 application deployed on Vercel or internal corporate domain.

```
                  ┌──────────────────────┐
                  │    Internet / DNS    │
                  └──────────┬───────────┘
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
https://gallery.luster360.com │ https://admin.luster360.com
(Events Gallery)     │       │ (Command Center)
                     ▼       ▼
          https://api.luster360.com
             (Luster Media API)
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
Supabase PostgreSQL       Google Drive V1
  (Cloud Database)         (Media Storage)
```

---

## 2. Supabase PostgreSQL Deployment

### Step 2.1: Create Supabase Project
1. Log in to [Supabase Dashboard](https://supabase.com).
2. Create a new project: `luster-360-prod`. Select your primary event region (e.g. `eu-central-1` Frankfurt or `me-central-1`).
3. Under **Project Settings -> Database**, note the connection strings.
4. Under **Project Settings -> API**, copy the `Project URL`, `anon / public` key, and `service_role` key.

### Step 2.2: Apply Production Migrations
Open the Supabase **SQL Editor** or use the Supabase CLI:
```bash
# Using Supabase CLI:
supabase link --project-ref your-project-ref
supabase db push

# OR execute directly via SQL Editor:
# Paste contents of:
supabase/migrations/20260910000001_initial_schema.sql
# Then paste initial seeds (optional for staging/prod):
supabase/seed.sql
```

---

## 3. LUSTER Media API Backend Deployment

### Step 3.1: Build Production Bundle
```bash
cd backend
npm ci
npm run build
```
This outputs clean compiled JavaScript to `backend/dist/`.

### Step 3.2: Environment Configuration
Create `/etc/luster360/backend.env` on your production host:
```bash
NODE_ENV=production
PORT=4000
API_BASE_URL=https://api.luster360.com

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJh...your_service_role_key

STORAGE_PROVIDER=GOOGLE_DRIVE
GOOGLE_DRIVE_PARENT_FOLDER_ID=1g9P...YourSharedDriveFolderId
GOOGLE_SERVICE_ACCOUNT_KEY={"type":"service_account",...}

RATE_LIMIT_MAX=300
CORS_ORIGIN=https://gallery.luster360.com,https://admin.luster360.com
```

### Step 3.3: PM2 Process Manager Configuration
Create `ecosystem.config.js` in `backend/`:
```javascript
module.exports = {
  apps: [{
    name: 'luster-media-api',
    script: './dist/server.js',
    instances: 2,
    exec_mode: 'cluster',
    env_file: '/etc/luster360/backend.env',
    max_memory_restart: '1G',
    error_file: '/var/log/luster/api-error.log',
    out_file: '/var/log/luster/api-out.log',
  }]
};
```
Start the service:
```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### Step 3.4: Nginx Reverse Proxy & SSL Configuration
Install Nginx and Certbot:
```bash
sudo apt update && sudo apt install -y nginx certbot python3-certbot-nginx
```

Configure `/etc/nginx/sites-available/api.luster360.com`:
```nginx
server {
    server_name api.luster360.com;

    # Allow 250MB uploads for high-bitrate 360 MP4s
    client_max_body_size 250M;

    location / {
        proxy_pass http://127.0.0.1:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Disable buffering for chunked video streaming
        proxy_buffering off;
        proxy_read_timeout 300s;
    }
}
```
Obtain SSL certificate:
```bash
sudo ln -s /etc/nginx/sites-available/api.luster360.com /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d api.luster360.com
```

---

## 4. Next.js Public Gallery Deployment (Vercel)

1. Connect your GitHub repository to Vercel.
2. Set Root Directory to: `web/apps/events-gallery`.
3. Framework Preset: `Next.js`.
4. Configure Environment Variables:
   - `NEXT_PUBLIC_API_URL`: `https://api.luster360.com`
   - `NEXT_PUBLIC_GALLERY_DOMAIN`: `https://gallery.luster360.com`
5. Deploy. Assign custom domain `gallery.luster360.com`.

---

## 5. Next.js Command Center Deployment (Vercel / VPS)

1. Connect your repository to Vercel or deploy to an internal enterprise host.
2. Set Root Directory to: `web/apps/command-center`.
3. Configure Environment Variables:
   - `NEXT_PUBLIC_API_URL`: `https://api.luster360.com`
   - `NEXT_PUBLIC_SUPABASE_URL`: `https://your-project.supabase.co`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`: `eyJh...your_anon_key`
4. Deploy. Assign custom domain `admin.luster360.com`.

---

## 6. Verification Checklist

- [ ] Call `https://api.luster360.com/api/v1/system/health` — must return `"status": "healthy"` and `"storageProvider": "GOOGLE_DRIVE"`.
- [ ] Visit `https://admin.luster360.com` — verify dashboard shows live device table and event list.
- [ ] Test video upload ticket: `POST /api/v1/uploads/initiate`.
- [ ] Verify test video stream with Range header: `curl -I -H "Range: bytes=0-1024" https://api.luster360.com/api/v1/media/stream/8F3K2A` — must return `HTTP/1.1 206 Partial Content`.
