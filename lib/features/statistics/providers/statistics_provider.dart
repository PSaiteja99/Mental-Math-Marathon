import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/user_stats_model.dart';
import '../../../providers/stats_provider.dart';

class StatisticsData {
  final UserStatsModel stats;
  final List<SessionModel> recentSessions;
  final List<double> accuracyHistory;
  final List<int> cphHistory;
  final List<int> streakHistory;
  final List<String> sessionLabels;

  const StatisticsData({
    required this.stats,
    required this.recentSessions,
    required this.accuracyHistory,
    required this.cphHistory,
    required this.streakHistory,
    required this.sessionLabels,
  });
}

final statisticsProvider = FutureProvider<StatisticsData>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  final stats = db.getUserStats();
  final sessions = db.getSessions();

  sessions.sort((a, b) => a.startTime.compareTo(b.startTime));

  final recent = sessions.length > 10
      ? sessions.sublist(sessions.length - 10)
      : sessions;

  final accuracyHistory = recent.map((s) => s.accuracy).toList();
  final cphHistory = recent.map((s) => s.cph).toList();
  final streakHistory = recent.map((s) => s.bestStreak).toList();
  final sessionLabels = recent.map((s) {
    final local = s.startTime.toLocal();
    final hour = local.hour;
    final minute = local.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
  }).toList();

  return StatisticsData(
    stats: stats,
    recentSessions: recent.reversed.toList(),
    accuracyHistory: accuracyHistory,
    cphHistory: cphHistory,
    streakHistory: streakHistory,
    sessionLabels: sessionLabels,
  );
});
