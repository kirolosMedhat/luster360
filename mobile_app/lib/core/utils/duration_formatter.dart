class DurationFormatter {
  DurationFormatter._();

  static String formatSeconds(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    if (hours > 0) {
      return '${twoDigits(hours)}h ${twoDigits(minutes)}m';
    }
    return '${twoDigits(minutes)}m ${twoDigits(seconds)}s';
  }

  static String formatVideoTime(double seconds) {
    if (seconds < 0) seconds = 0;
    final totalSecs = seconds.floor();
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(mins)}:${twoDigits(secs)}';
  }

  /// Deterministic server-independent duration calculation based on UTC timestamps
  static ({int durationSeconds, String formatted}) calculateEventDuration({
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    if (startedAt == null) {
      return (durationSeconds: 0, formatted: '00h 00m');
    }

    final startUtc = startedAt.toUtc();
    final endUtc = (endedAt ?? DateTime.now()).toUtc();
    final diff = endUtc.difference(startUtc).inSeconds;
    final durationSeconds = diff < 0 ? 0 : diff;

    return (
      durationSeconds: durationSeconds,
      formatted: formatSeconds(durationSeconds),
    );
  }
}
