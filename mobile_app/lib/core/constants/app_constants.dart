class AppConstants {
  AppConstants._();

  static const String appName = 'Luster 360';
  static const String appVersion = '1.0.0+1';

  // Network & Cloud API
  static const String defaultMediaApiUrl = 'http://localhost:4000/api/v1';
  static const String publicGalleryBaseUrl = 'https://events.luster-photobooth.com';

  // Storage Directories
  static const String eventsDir = 'luster_events';
  static const String rawVideosDir = 'raw';
  static const String finalVideosDir = 'final';
  static const String thumbnailsDir = 'thumbnails';
  static const String overlaysDir = 'overlays';

  // Booth Countdown Options
  static const List<int> countdownOptions = [3, 5, 10];
  static const int defaultCountdown = 5;
  static const int defaultRecordingDurationSec = 10;
  static const int autoReturnSeconds = 12;

  // Video Resolutions & Frame Rates
  static const int defaultWidth = 1080;
  static const int defaultHeight = 1920;
  static const int defaultFps = 30;

  // Security
  static const String defaultOperatorPin = '1234';
}
