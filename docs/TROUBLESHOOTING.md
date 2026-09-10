# LUSTER 360 — OPERATIONAL RUNBOOK & TROUBLESHOOTING GUIDE

## 1. Live Event Emergency Response

### Scenario 1: Total Internet Loss During an Active Event

**Symptom**: Venue Wi-Fi fails or cellular hotspot drops to 0 bars. The booth operator sees the status indicator change to `OFFLINE`.

**System Behavior**:
- **Operation Continues 100% Normally**: The 360 booth does **NOT** stop or lock up.
- **Local Renders**: FFmpeg completes rendering on-device in 8–12 seconds.
- **Immediate QR Codes**: Guests scan their QR codes immediately on the booth screen. The short URL (`https://gallery.luster360.com/v/XXXXXX`) is already locked and assigned.
- **Embedded SQLite Queue**: Upload tasks transition to `QUEUED` state and remain saved on disk.

**Operator Action**:
1. **DO NOT restart the app or reboot the phone/tablet.**
2. Let guests continue taking 360 videos as usual.
3. Inform guests: *"Your video will appear online within a few minutes once uploaded!"*
4. When connectivity returns (or you connect to a personal 5G mobile hotspot), the upload queue daemon automatically resumes uploading in the background.
5. In the booth app, open **Settings -> Upload Queue** to monitor items syncing to Google Drive.

---

### Scenario 2: Guest Scans QR Before Upload Completes

**Symptom**: Guest immediately scans their QR code at the booth while the video is still in `QUEUED` or `UPLOADING` state.

**System Behavior**:
- The Public Gallery displays the **"Processing Master Render"** status screen.
- An animated spinner indicates: *"Your 360 spin is rendering and uploading to cloud storage. This page will automatically update once ready."*
- The webpage automatically polls `/api/v1/videos/resolve/:shortCode` every 3 seconds.
- The millisecond the backend verifies the file in Google Drive, the webpage instantly transitions to the full interactive video player and download button.

**Operator Action**: None required. This is the intended real-world design.

---

### Scenario 3: Device Overheating / Thermal Throttling

**Symptom**: Android or iOS device feels excessively hot; rendering slows down from 10s to 30s; camera preview stutters.

**Causes**: Continuous 120 FPS camera sensor feed under high ambient temperatures (e.g., outdoor summer weddings, heavy studio LED ring lights).

**Operator Remediation**:
1. **Shade the Device**: Position the 360 booth or mounting arm away from direct sunlight or radiant halogen spotlights.
2. **Remove Protective Case**: Thick silicone or leather cases trap heat. Use an open aluminum cage or mount.
3. **Power Source**: Use an official high-wattage GaN charger. Low-quality power banks cause devices to generate excess heat during fast-charging.
4. **App Settings**:
   - In **Settings -> Camera Configuration**, toggle off continuous torch/ring light when idle.
   - If capture was set to 240 FPS, switch to 120 FPS.

---

### Scenario 4: External Camera (GoPro / Sony / Canon) Shows "NOT CONNECTED"

**Symptom**: Camera preview displays black or the status badge shows `EXTERNAL CAMERA NOT CONNECTED`.

**Diagnostic Steps**:
1. **Honest Reporting**: LUSTER 360 will never display fake synthetic previews. If the external camera is disconnected, it explicitly reports `NOT CONNECTED`.
2. **USB-C OTG Cable**: Check that the USB-C cable supports high-speed data transfer (USB 3.1 Gen 2), not just power charging.
3. **Camera Mode**:
   - **GoPro (Hero 10/11/12)**: Ensure **Preferences -> Connections -> USB Connection** is set to **GoPro Connect** (Webcam mode) or MTP depending on model.
   - **Sony Alpha (A7 IV, FX3, ZV-E10)**: Set **USB Streaming** to **ON** in the camera menu.
   - **Canon EOS (R5, R6, M50 Mark II)**: Set USB mode to **Live Streaming (UVC/UAC)**.
4. **Quick Fallback**: If the external camera fails, tap **Switch to Phone Camera** on the Capture screen to continue the event immediately using the phone's native 120 FPS sensor without downtime.

---

### Scenario 5: Google Drive API Rate Limit or Storage Quota Exceeded

**Symptom**: Upload queue shows error: `Google Drive API error: 403 rateLimitExceeded` or `storageQuotaExceeded`.

**Causes**:
- Exceeding Google's default 10 requests/second per user rate limit during a sudden burst.
- Google account or Shared Drive reaching the 15 GB free tier limit.

**Resolution**:
1. **Automatic Retry Backoff**: The Luster Media API and mobile app automatically implement exponential backoff ($1\text{s}, 2\text{s}, 4\text{s}, 8\text{s}, 16\text{s}, 32\text{s}, 60\text{s}$). Transient rate limits resolve automatically without data loss.
2. **Storage Quota**:
   - Ensure the Google Service Account is uploading into a **Google Workspace Shared Drive** (which provides enterprise pooled storage) rather than a personal Gmail Drive.
   - Check the **Command Center -> Storage Health** page (`admin.luster360.com/storage`) for live Drive quota metrics.

---

### Scenario 6: Low Device Disk Space Alert (< 5 GB Free)

**Symptom**: App displays an orange warning badge: `Storage Free: 3.2 GB`.

**Resolution**:
1. Open **Settings -> Storage Manager**.
2. Tap **Clean Verified Cache**: This safely purges local copies of videos that have already reached status `READY` and been verified in Google Drive.
3. Raw capture files older than 48 hours are automatically purged if configured in the storage policy.
