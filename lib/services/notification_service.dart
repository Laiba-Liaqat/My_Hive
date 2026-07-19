import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/focus_session.dart';

/// Drives "Bee-Alert" nudges — reminders that reference the user's actual
/// state (time since last session, honey so far today, streak) instead of
/// a generic "come back to the app!" ping.
///
/// Requires platform notification permissions to be set up after running
/// `flutter create .` (see README) — Android 13+ and iOS both need an
/// explicit runtime permission request, handled in [init].
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    _initialized = true;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'hive_focus_nudges',
      'Bee Alerts',
      channelDescription: 'Personalized nudges from your hive',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Builds a personalized nudge based on today's progress so far, then
  /// fires it immediately. In production, schedule this via
  /// `zonedSchedule` at idle-detection points (e.g. app backgrounded with
  /// no session for 2+ hours during the user's usual focus window).
  Future<void> sendSmartNudge({
    required List<FocusSession> todaysSessions,
    required int currentStreak,
    int targetSessionMinutes = 15,
  }) async {
    final message = buildNudgeMessage(
      todaysSessions: todaysSessions,
      currentStreak: currentStreak,
      targetSessionMinutes: targetSessionMinutes,
    );
    await _plugin.show(
      Random().nextInt(1 << 31),
      message.title,
      message.body,
      _details,
    );
  }

  /// Pure function (no side effects) so it's easy to unit test and to
  /// preview copy in the Settings screen.
  static ({String title, String body}) buildNudgeMessage({
    required List<FocusSession> todaysSessions,
    required int currentStreak,
    int targetSessionMinutes = 15,
  }) {
    final completedToday = todaysSessions.where((s) => s.isCompleted).length;
    final honeyToday =
        todaysSessions.where((s) => s.isCompleted).fold(0.0, (a, s) => a + s.honeyMl);

    if (completedToday == 0 && currentStreak > 0) {
      return (
        title: '🐝 Your bees are waiting!',
        body:
            "You're on a $currentStreak-day streak — a $targetSessionMinutes-minute session keeps it alive.",
      );
    }
    if (completedToday == 0) {
      return (
        title: '🍯 The hive is quiet today',
        body: 'Start a $targetSessionMinutes-minute session to wake up the colony.',
      );
    }
    if (completedToday >= 1 && completedToday < 3) {
      return (
        title: '🐝 Almost a full honeycomb',
        body:
            "You've made ${honeyToday.toStringAsFixed(0)}ml today. One more $targetSessionMinutes-minute session finishes today's honeycomb.",
      );
    }
    return (
      title: '🍯 The apiary is thriving',
      body:
          'You\'ve completed $completedToday sessions today (${honeyToday.toStringAsFixed(0)}ml). Keep the streak going tomorrow!',
    );
  }
}
