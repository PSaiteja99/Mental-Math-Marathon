import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_math_marathon/data/repositories/game_repository.dart';
import 'package:mental_math_marathon/data/repositories/stats_repository.dart';
import 'package:mental_math_marathon/domain/repositories/game_repository.dart';
import 'package:mental_math_marathon/domain/repositories/stats_repository.dart';
import 'package:mental_math_marathon/features/achievements/providers/achievements_provider.dart';
import 'package:mental_math_marathon/features/game/engine/achievement_engine.dart';
import 'package:mental_math_marathon/features/game/engine/score_engine.dart';
import 'package:mental_math_marathon/models/session_result.dart';
import 'package:mental_math_marathon/providers/stats_provider.dart';

class SessionNotifier extends StateNotifier<AsyncValue<void>> {
  final StatsRepository _statsRepo;
  final GameRepository _gameRepo;
  final AchievementsNotifier _achievementsNotifier;
  final RecentlyUnlockedNotifier _recentlyUnlockedNotifier;
  final void Function()? onStatsUpdated;

  SessionNotifier(
    this._statsRepo,
    this._gameRepo,
    this._achievementsNotifier,
    this._recentlyUnlockedNotifier,
    this.onStatsUpdated,
  ) : super(const AsyncValue.data(null));

  Future<void> saveSession(SessionResult result) async {
    state = const AsyncValue.loading();
    try {
      final session = result.toSessionModel();
      await _gameRepo.saveSession(session);

      final currentStats = _statsRepo.getUserStats();
      final cumulativeXp = currentStats.totalXp + result.totalXp;
      final cumulativeLevel = ScoreEngine.calculateLevel(cumulativeXp) + 1;
      final updatedStats = currentStats.copyWith(
        totalQuestions: currentStats.totalQuestions + result.totalQuestions,
        correctAnswers: currentStats.correctAnswers + result.correctCount,
        wrongAnswers: currentStats.wrongAnswers + result.wrongCount,
        totalXp: cumulativeXp,
        bestCph: result.cph > currentStats.bestCph
            ? result.cph
            : currentStats.bestCph,
        bestStreak: result.bestStreak > currentStats.bestStreak
            ? result.bestStreak
            : currentStats.bestStreak,
        currentLevel: cumulativeLevel,
      );
      await _statsRepo.updateUserStats(updatedStats);

      final unlocked = AchievementEngine.checkAchievements(
        updatedStats,
        _achievementsNotifier.state,
        lastSession: result,
      );
      for (final achievement in unlocked) {
        await _achievementsNotifier.unlockAchievement(achievement.id);
        _recentlyUnlockedNotifier.addAchievement(achievement);
      }

      onStatsUpdated?.call();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, AsyncValue<void>>((ref) {
  final statsRepo = StatsRepositoryImpl(ref.watch(localDatabaseProvider));
  final gameRepo = GameRepositoryImpl(ref.watch(localDatabaseProvider));
  return SessionNotifier(
    statsRepo,
    gameRepo,
    ref.watch(achievementsProvider.notifier),
    ref.watch(recentlyUnlockedProvider.notifier),
    () => ref.read(homeStatsRefreshProvider.notifier).state++,
  );
});
