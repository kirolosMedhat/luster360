import 'package:flutter/foundation.dart';

enum AppLogLevel { debug, info, warn, error }

class AppLogger {
  AppLogger._();

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(AppLogLevel.debug, message, error, stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(AppLogLevel.info, message, error, stackTrace);
  }

  static void warn(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(AppLogLevel.warn, message, error, stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(AppLogLevel.error, message, error, stackTrace);
  }

  static void _log(AppLogLevel level, String message, [dynamic error, StackTrace? stackTrace]) {
    if (kReleaseMode && level == AppLogLevel.debug) return;

    final timestamp = DateTime.now().toIso8601String();
    final tag = level.name.toUpperCase();
    final errorPart = error != null ? ' | Error: $error' : '';
    debugPrint('[$timestamp] [$tag] $message$errorPart');

    if (stackTrace != null && (level == AppLogLevel.error || level == AppLogLevel.warn)) {
      debugPrint(stackTrace.toString());
    }
  }
}
