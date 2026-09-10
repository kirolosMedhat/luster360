# LUSTER 360 — MOBILE BOOTH APPLICATION SETUP & COMPILATION GUIDE

## 1. Development Environment Prerequisites

To compile and run the LUSTER 360 mobile booth application on real hardware:

| Tool | Minimum Version | Recommended Version | Purpose |
|---|---|---|---|
| **Flutter SDK** | 3.24.0 | 3.24.5+ | Core framework & Riverpod engine |
| **Dart SDK** | 3.5.0 | 3.5.3+ | Language runtime |
| **Android Studio** | Ladybug / Koala | Latest Stable | Android SDK & NDK toolchains |
| **Android SDK** | API Level 34 | API Level 34 | Platform SDK |
| **JDK** | Java 17 | Eclipse Temurin 17 | Gradle build runtime |
| **Xcode (macOS)** | 15.0+ | 16.0+ | iOS compilation & AVFoundation |
| **CocoaPods** | 1.14.0+ | 1.15.2+ | iOS dependency manager |

---

## 2. Android Configuration & Native Camera2 Bridge

### 2.1 Gradle & SDK Levels
The application requires `minSdkVersion 26` (Android 8.0 Oreo) because high-speed video capture (`CameraConstrainedHighSpeedCaptureSession`) and modern hardware codecs are only supported on Android 26+.

In `android/app/build.gradle`:
```groovy
android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.luster.luster360"
        minSdkVersion 26
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }
}
```

### 2.2 Permissions in `AndroidManifest.xml`
The app requests production permissions required for continuous booth operation:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
<uses-feature android:name="android.hardware.camera.capability.constrained_high_speed_video" android:required="false" />
```

### 2.3 Android Lock-Task / Kiosk Mode (Booth Deployment)
For commercial operation where guests cannot exit the application:
1. Enable Developer Options on the device.
2. Under **Settings -> Security -> App Pinning** (or Device Owner mode), enable pinning.
3. In LUSTER 360 Booth Mode, the screen enforces full-screen immersive sticky mode (`SystemUiMode.immersiveSticky`), hiding the status bar and navigation gestures.
4. Exit requires entering the operator PIN (Default: `1234` or configured in Settings).

---

## 3. iOS Configuration & AVFoundation Bridge

### 3.1 `Info.plist` Usage Descriptions
Apple requires user-facing privacy descriptions for hardware sensors:
```xml
<key>NSCameraUsageDescription</key>
<string>Luster 360 requires camera access to record high-framerate 360 photobooth videos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Luster 360 requires microphone access to capture ambient event audio during recording.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Luster 360 saves finished rendered event videos to your local photo library.</string>
```

### 3.2 High Frame Rate (120/240 FPS) Capture Setup
On iPhone 12 Pro through 16 Pro, the native bridge selects the active `AVCaptureDeviceFormat` that supports `videoSupportedFrameRateRanges` with `maxFrameRate >= 120.0`.

### 3.3 iOS Guided Access (Kiosk Mode)
1. On the iPad or iPhone: Go to **Settings -> Accessibility -> Guided Access**.
2. Toggle **Guided Access** ON and configure a Passcode.
3. Launch LUSTER 360, tap the side button three times, select **Start**.
4. The device is now hardware-locked to LUSTER 360; hardware buttons and swipe gestures are disabled.

---

## 4. Compilation & Build Commands

### 4.1 Dependency Fetch
```bash
cd mobile_app
flutter pub get
```

### 4.2 Run on Connected USB Device
```bash
# List connected devices
flutter devices

# Run in debug mode
flutter run -d <device_id>

# Run in profile mode (for measuring FFmpeg render benchmarks)
flutter run --profile -d <device_id>
```

### 4.3 Production Release Builds

#### Android APK (Direct Sideloading for Booth Tablets):
```bash
flutter build apk --release --split-per-abi
```
The resulting APKs are located at `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.

#### Android App Bundle (Google Play Console):
```bash
flutter build appbundle --release
```

#### iOS IPA (TestFlight & App Store):
```bash
flutter build ipa --release
```
Open `build/ios/archive/Runner.xcarchive` in Xcode Organizer to distribute.

---

## 5. Environment Configuration

The mobile app connects to the LUSTER Media API backend. Configure the target endpoint in `lib/core/constants/api_constants.dart` or pass via `--dart-define`:
```bash
flutter run --release \
  --dart-define=LUSTER_API_BASE_URL=https://api.luster360.com/api/v1 \
  --dart-define=LUSTER_GALLERY_DOMAIN=https://gallery.luster360.com
```
