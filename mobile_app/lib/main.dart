import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'app.dart';
import 'core/logging/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep screen awake during 360 booth operations
  try {
    await WakelockPlus.enable();
  } catch (e) {
    AppLogger.warn('Wakelock not available on current platform: $e');
  }

  // Force portrait orientation for standard 360 phone mounting rigs
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Dark navigation bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0F17),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  AppLogger.info('Launching LUSTER 360 Booth Platform');

  runApp(
    const ProviderScope(
      child: Luster360App(),
    ),
  );
}
