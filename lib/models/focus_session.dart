import 'dart:convert';

/// The outcome of a focus session.
enum SessionResult { completed, failed }

/// A single focus session — one "batch" of honey.
class FocusSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int plannedMinutes;
  final int actualSeconds;
  final SessionResult result;
  final double honeyMl; // honey "produced" for this session

  FocusSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.plannedMinutes,
    required this.actualSeconds,
    required this.result,
    required this.honeyMl,
  });

  bool get isCompleted => result == SessionResult.completed;

  Duration get actualDuration => Duration(seconds: actualSeconds);

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'plannedMinutes': plannedMinutes,
        'actualSeconds': actualSeconds,
        'result': result.name,
        'honeyMl': honeyMl,
      };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        plannedMinutes: json['plannedMinutes'] as int,
        actualSeconds: json['actualSeconds'] as int,
        result: SessionResult.values.firstWhere(
          (e) => e.name == json['result'],
          orElse: () => SessionResult.failed,
        ),
        honeyMl: (json['honeyMl'] as num).toDouble(),
      );

  static String encodeList(List<FocusSession> sessions) =>
      jsonEncode(sessions.map((s) => s.toJson()).toList());

  static List<FocusSession> decodeList(String raw) {
    final List decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => FocusSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// A jar/comb formed from a completed session, shown in the 3D apiary shelf.
class HoneyJar {
  final String sessionId;
  final DateTime date;
  final double honeyMl;
  final int hue; // 0-5, deterministic "flavor" variety based on time of day

  HoneyJar({
    required this.sessionId,
    required this.date,
    required this.honeyMl,
    required this.hue,
  });

  factory HoneyJar.fromSession(FocusSession s) {
    final hour = s.startTime.hour;
    int hue;
    if (hour < 6) {
      hue = 4; // midnight wildflower — deep amber
    } else if (hour < 12) {
      hue = 0; // morning blossom — light gold
    } else if (hour < 17) {
      hue = 1; // afternoon clover — classic gold
    } else if (hour < 21) {
      hue = 2; // evening buckwheat — amber
    } else {
      hue = 3; // night lavender — dark honey
    }
    return HoneyJar(
      sessionId: s.id,
      date: s.startTime,
      honeyMl: s.honeyMl,
      hue: hue,
    );
  }
}
