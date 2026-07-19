/// App-wide constants and small pure helper functions.
class AppConstants {
  AppConstants._();

  static const List<int> presetMinutes = [15, 25, 45];
  static const int minCustomMinutes = 5;
  static const int maxCustomMinutes = 180;

  /// How much honey (ml) a fully completed session of [minutes] produces.
  /// Roughly 1ml per minute, with a small bonus for longer focus.
  static double honeyForSession(int minutes, {bool completed = true}) {
    if (!completed) return 0;
    final base = minutes.toDouble();
    final bonus = minutes >= 45 ? minutes * 0.15 : (minutes >= 25 ? minutes * 0.08 : 0.0);
    return base + bonus;
  }

  /// Partial honey lost/salvaged when a session is abandoned early.
  /// A failed batch keeps a small fraction as "spilled honey" for realism,
  /// but does not count toward completed stats.
  static double partialHoney(int elapsedSeconds) {
    final minutes = elapsedSeconds / 60.0;
    return (minutes * 0.25).clamp(0, 999);
  }
}

enum TimeOfDayBucket { morning, afternoon, evening, night }

TimeOfDayBucket bucketForHour(int hour) {
  if (hour >= 5 && hour < 12) return TimeOfDayBucket.morning;
  if (hour >= 12 && hour < 17) return TimeOfDayBucket.afternoon;
  if (hour >= 17 && hour < 21) return TimeOfDayBucket.evening;
  return TimeOfDayBucket.night;
}

String bucketLabel(TimeOfDayBucket b) {
  switch (b) {
    case TimeOfDayBucket.morning:
      return 'Morning';
    case TimeOfDayBucket.afternoon:
      return 'Afternoon';
    case TimeOfDayBucket.evening:
      return 'Evening';
    case TimeOfDayBucket.night:
      return 'Night';
  }
}

enum AnalyticsRange { day, week, month, year }

String twoDigits(int n) => n.toString().padLeft(2, '0');

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) return '${h}h ${twoDigits(m)}m';
  if (m > 0) return '${m}m ${twoDigits(s)}s';
  return '${s}s';
}

String formatClock(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${twoDigits(m)}:${twoDigits(s)}';
}

String formatHoney(double ml) {
  if (ml >= 1000) {
    return '${(ml / 1000).toStringAsFixed(2)} L';
  }
  return '${ml.toStringAsFixed(0)} ml';
}

double mlToOz(double ml) => ml * 0.033814;
