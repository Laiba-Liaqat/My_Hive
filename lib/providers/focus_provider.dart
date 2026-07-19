import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import '../models/focus_session.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

enum HiveSessionState {
  idle, // no active session, picking a duration
  running, // bees actively collecting honey
  paused, // user paused deliberately
  distracted, // app left foreground during a running session (grace period)
  completed, // just finished — show reward screen
  failed, // colony collapsed — session lost
}

/// Drives the focus timer, the "colony health" mechanic, and the
/// persisted history of sessions/honey jars. Also detects when the app
/// leaves the foreground during an active session (distraction) via
/// WidgetsBindingObserver, matching the "leave the session = production
/// stops" behavioral concept.
class FocusProvider extends ChangeNotifier with WidgetsBindingObserver {
  FocusProvider(this._storage) {
    WidgetsBinding.instance.addObserver(this);
    _restore();
  }

  final StorageService _storage;
  final _uuid = const Uuid();

  // --- Session config & live state -----------------------------------
  int _plannedMinutes = 25;
  int _remainingSeconds = 25 * 60;
  int _elapsedSeconds = 0;
  HiveSessionState _state = HiveSessionState.idle;
  Timer? _ticker;
  DateTime? _sessionStart;

  /// Seconds allowed away from the app before the colony fully collapses.
  static const int distractionGraceSeconds = 6;
  int _distractionSecondsUsed = 0;
  Timer? _distractionTicker;

  // --- History ----------------------------------------------------------
  List<FocusSession> _sessions = [];
  bool _loaded = false;

  // --- Getters ------------------------------------------------------
  HiveSessionState get state => _state;
  int get plannedMinutes => _plannedMinutes;
  int get remainingSeconds => _remainingSeconds;
  int get elapsedSeconds => _elapsedSeconds;
  bool get loaded => _loaded;
  List<FocusSession> get sessions => List.unmodifiable(_sessions);

  /// 0.0 -> 1.0 progress of the current honeycomb filling up.
  double get progress {
    final total = _plannedMinutes * 60;
    if (total == 0) return 0;
    return (_elapsedSeconds / total).clamp(0.0, 1.0);
  }

  /// Colony health shrinks while distracted, recovers while focused.
  double _colonyHealth = 1.0;
  double get colonyHealth => _colonyHealth;

  // --- Setup ----------------------------------------------------------
  Future<void> _restore() async {
    _sessions = await _storage.loadSessions();
    final lastDuration = await _storage.loadLastDuration();
    if (lastDuration != null) {
      _plannedMinutes = lastDuration;
      _remainingSeconds = lastDuration * 60;
    }
    _loaded = true;
    notifyListeners();
  }

  /// Called after a successful login so a returning user's session
  /// history loads from the cloud instead of staying empty/pre-login.
  Future<void> reload() async {
    _loaded = false;
    notifyListeners();
    await _restore();
  }

  void setPlannedMinutes(int minutes) {
    if (_state == HiveSessionState.running || _state == HiveSessionState.paused) return;
    _plannedMinutes = minutes.clamp(
      AppConstants.minCustomMinutes,
      AppConstants.maxCustomMinutes,
    );
    _remainingSeconds = _plannedMinutes * 60;
    _storage.saveLastDuration(_plannedMinutes);
    notifyListeners();
  }

  // --- Session lifecycle -----------------------------------------------
  void startSession() {
    _sessionStart = DateTime.now();
    _elapsedSeconds = 0;
    _remainingSeconds = _plannedMinutes * 60;
    _colonyHealth = 1.0;
    _distractionSecondsUsed = 0;
    _state = HiveSessionState.running;
    _startTicker();
    notifyListeners();
  }

  void pauseSession() {
    if (_state != HiveSessionState.running) return;
    _state = HiveSessionState.paused;
    _ticker?.cancel();
    notifyListeners();
  }

  void resumeSession() {
    if (_state != HiveSessionState.paused) return;
    _state = HiveSessionState.running;
    _startTicker();
    notifyListeners();
  }

  void giveUp() {
    _endAsFailed();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_state != HiveSessionState.running) return;
    _elapsedSeconds++;
    _remainingSeconds = (_plannedMinutes * 60 - _elapsedSeconds).clamp(0, _plannedMinutes * 60);

    // Colony slowly recovers while actively focused.
    _colonyHealth = (_colonyHealth + 0.02).clamp(0.0, 1.0);

    if (_remainingSeconds <= 0) {
      _endAsCompleted();
      return;
    }
    notifyListeners();
  }

  void _endAsCompleted() {
    _ticker?.cancel();
    _distractionTicker?.cancel();
    final honey = AppConstants.honeyForSession(_plannedMinutes, completed: true);
    final session = FocusSession(
      id: _uuid.v4(),
      startTime: _sessionStart ?? DateTime.now().subtract(Duration(seconds: _elapsedSeconds)),
      endTime: DateTime.now(),
      plannedMinutes: _plannedMinutes,
      actualSeconds: _elapsedSeconds,
      result: SessionResult.completed,
      honeyMl: honey,
    );
    _sessions.insert(0, session);
    _storage.saveSessions(_sessions);
    _state = HiveSessionState.completed;
    notifyListeners();
  }

  void _endAsFailed() {
    _ticker?.cancel();
    _distractionTicker?.cancel();
    final honey = AppConstants.partialHoney(_elapsedSeconds);
    final session = FocusSession(
      id: _uuid.v4(),
      startTime: _sessionStart ?? DateTime.now().subtract(Duration(seconds: _elapsedSeconds)),
      endTime: DateTime.now(),
      plannedMinutes: _plannedMinutes,
      actualSeconds: _elapsedSeconds,
      result: SessionResult.failed,
      honeyMl: honey,
    );
    _sessions.insert(0, session);
    _storage.saveSessions(_sessions);
    _state = HiveSessionState.failed;
    _colonyHealth = 0.0;
    notifyListeners();
  }

  /// Called by the UI after showing the result screen, to return to idle.
  void acknowledgeResult() {
    _state = HiveSessionState.idle;
    _elapsedSeconds = 0;
    _remainingSeconds = _plannedMinutes * 60;
    _colonyHealth = 1.0;
    notifyListeners();
  }

  /// Permanently deletes every logged session and honey jar, and resets
  /// the timer back to idle. Used by Settings > Danger Zone > Reset.
  Future<void> clearHistory() async {
    _ticker?.cancel();
    _distractionTicker?.cancel();
    _sessions = [];
    _state = HiveSessionState.idle;
    _elapsedSeconds = 0;
    _remainingSeconds = _plannedMinutes * 60;
    _colonyHealth = 1.0;
    await _storage.clearSessions();
    notifyListeners();
  }

  // --- Distraction detection --------------------------------------------
  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (_state != HiveSessionState.running && _state != HiveSessionState.distracted) {
      return;
    }

    if (appState == AppLifecycleState.paused || appState == AppLifecycleState.inactive) {
      _enterDistracted();
    } else if (appState == AppLifecycleState.resumed) {
      _leaveDistracted();
    }
  }

  void _enterDistracted() {
    if (_state == HiveSessionState.distracted) return;
    _state = HiveSessionState.distracted;
    _ticker?.cancel();
    _distractionSecondsUsed = 0;
    _distractionTicker?.cancel();
    _distractionTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _distractionSecondsUsed++;
      _colonyHealth = (_colonyHealth - 0.15).clamp(0.0, 1.0);
      if (_distractionSecondsUsed >= distractionGraceSeconds || _colonyHealth <= 0) {
        _distractionTicker?.cancel();
        _endAsFailed();
      }
    });
  }

  void _leaveDistracted() {
    if (_state != HiveSessionState.distracted) return;
    _distractionTicker?.cancel();
    _state = HiveSessionState.running;
    _startTicker();
    notifyListeners();
  }

  // --- Stats --------------------------------------------------------
  List<FocusSession> get completedSessions =>
      _sessions.where((s) => s.isCompleted).toList();

  double get totalHoneyMl =>
      completedSessions.fold(0.0, (sum, s) => sum + s.honeyMl);

  int get failedBatchCount => _sessions.where((s) => !s.isCompleted).length;

  Duration get totalFocusTime => completedSessions.fold(
        Duration.zero,
        (sum, s) => sum + s.actualDuration,
      );

  Duration get averageSessionDuration {
    if (completedSessions.isEmpty) return Duration.zero;
    final totalSecs = completedSessions.fold<int>(0, (sum, s) => sum + s.actualSeconds);
    return Duration(seconds: totalSecs ~/ completedSessions.length);
  }

  List<HoneyJar> get honeyJars =>
      completedSessions.map((s) => HoneyJar.fromSession(s)).toList();

  /// Map of TimeOfDayBucket -> count of completed sessions, for the
  /// "when are your bees most active" chart.
  Map<TimeOfDayBucket, int> get timeDistribution {
    final map = {
      for (final b in TimeOfDayBucket.values) b: 0,
    };
    for (final s in completedSessions) {
      map[bucketForHour(s.startTime.hour)] = map[bucketForHour(s.startTime.hour)]! + 1;
    }
    return map;
  }

  /// Honey yield grouped by day/week/month/year for the productivity chart.
  List<MapEntry<String, double>> yieldSeries(AnalyticsRange range) {
    final now = DateTime.now();
    final buckets = <String, double>{};

    switch (range) {
      case AnalyticsRange.day:
        for (int i = 6; i >= 0; i--) {
          final d = now.subtract(Duration(days: i));
          buckets[_dayLabel(d)] = 0;
        }
        for (final s in completedSessions) {
          final d = s.startTime;
          if (now.difference(d).inDays <= 6) {
            final key = _dayLabel(d);
            if (buckets.containsKey(key)) buckets[key] = buckets[key]! + s.honeyMl;
          }
        }
        break;
      case AnalyticsRange.week:
        for (int i = 7; i >= 0; i--) {
          final d = now.subtract(Duration(days: i * 7));
          buckets[_weekLabel(d)] = 0;
        }
        for (final s in completedSessions) {
          final key = _weekLabel(s.startTime);
          if (buckets.containsKey(key)) buckets[key] = buckets[key]! + s.honeyMl;
        }
        break;
      case AnalyticsRange.month:
        for (int i = 5; i >= 0; i--) {
          final d = DateTime(now.year, now.month - i, 1);
          buckets[_monthLabel(d)] = 0;
        }
        for (final s in completedSessions) {
          final key = _monthLabel(s.startTime);
          if (buckets.containsKey(key)) buckets[key] = buckets[key]! + s.honeyMl;
        }
        break;
      case AnalyticsRange.year:
        for (int i = 4; i >= 0; i--) {
          final y = now.year - i;
          buckets['$y'] = 0;
        }
        for (final s in completedSessions) {
          final key = '${s.startTime.year}';
          if (buckets.containsKey(key)) buckets[key] = buckets[key]! + s.honeyMl;
        }
        break;
    }

    return buckets.entries.toList();
  }

  String _dayLabel(DateTime d) => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];
  String _weekLabel(DateTime d) {
    final firstDayOfYear = DateTime(d.year, 1, 1);
    final weekNum = ((d.difference(firstDayOfYear).inDays) / 7).ceil() + 1;
    return 'W$weekNum';
  }
  String _monthLabel(DateTime d) =>
      const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.month - 1];

  /// Days (normalized to midnight) that had at least one completed session,
  /// for the focus calendar heatmap/markers.
  Set<DateTime> get activeDays => completedSessions
      .map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
      .toSet();

  int get currentStreak {
    final days = activeDays;
    if (days.isEmpty) return 0;
    int streak = 0;
    DateTime cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _distractionTicker?.cancel();
    super.dispose();
  }
}
