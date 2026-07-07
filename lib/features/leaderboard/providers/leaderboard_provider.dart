import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/session_model.dart';
import '../../../providers/stats_provider.dart';

class LeaderboardEntry {
  final String label;
  final String value;
  final String? subtitle;
  final double progress;

  const LeaderboardEntry({
    required this.label,
    required this.value,
    this.subtitle,
    this.progress = 1.0,
  });
}

class LeaderboardData {
  final List<LeaderboardEntry> entries;
  final List<SessionModel> topSessions;

  const LeaderboardData({
    required this.entries,
    required this.topSessions,
  });
}

final leaderboardProvider = FutureProvider<LeaderboardData>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  final stats = db.getUserStats();
  final sessions = db.getSessions();

  final topSessions = List<SessionModel>.from(sessions)
    ..sort((a, b) => b.cph.compareTo(a.cph));

  final bestCph = stats.bestCph;
  final bestStreak = stats.bestStreak;
  final bestAccuracy = sessions.isEmpty
      ? 0.0
      : sessions.map((s) => s.accuracy).reduce((a, b) => a > b ? a : b);
  final mostInSession = sessions.isEmpty
      ? 0
      : sessions.map((s) => s.totalQuestions).reduce((a, b) => a > b ? a : b);

  return LeaderboardData(
    entries: [
      LeaderboardEntry(
        label: 'Highest CPH',
        value: '$bestCph',
        subtitle: 'Calculations per hour',
        progress: bestCph > 0 ? (bestCph / 1000).clamp(0.0, 1.0) : 0.0,
      ),
      LeaderboardEntry(
        label: 'Longest Streak',
        value: '$bestStreak',
        subtitle: 'Consecutive correct',
        progress: bestStreak > 0 ? (bestStreak / 100).clamp(0.0, 1.0) : 0.0,
      ),
      LeaderboardEntry(
        label: 'Most in Session',
        value: '$mostInSession',
        subtitle: 'Questions in one session',
        progress: mostInSession > 0 ? (mostInSession / 100).clamp(0.0, 1.0) : 0.0,
      ),
      LeaderboardEntry(
        label: 'Best Accuracy',
        value: '${bestAccuracy.toStringAsFixed(1)}%',
        subtitle: 'Single session accuracy',
        progress: bestAccuracy / 100,
      ),
    ],
    topSessions: topSessions.take(5).toList(),
  );
});
