import 'package:mental_math_marathon/data/models/achievement_model.dart';
import 'package:mental_math_marathon/domain/entities/achievement.dart';
import 'package:mental_math_marathon/domain/entities/user_stats.dart';
import 'package:mental_math_marathon/models/session_result.dart';

class AchievementEngine {
  static List<AchievementModel> checkAchievements(
    UserStats stats,
    List<AchievementModel> currentAchievements, {
    SessionResult? lastSession,
  }) {
    final newlyUnlocked = <AchievementModel>[];

    for (final def in AchievementDefinitions.all) {
      if (isAchievementUnlocked(currentAchievements, def.id)) continue;

      bool shouldUnlock = false;
      switch (def.id) {
        case 'first_calc':
          shouldUnlock = stats.correctAnswers >= 1;
          break;
        case 'calc_100':
          shouldUnlock = stats.correctAnswers >= 100;
          break;
        case 'calc_500':
          shouldUnlock = stats.correctAnswers >= 500;
          break;
        case 'calc_1000':
          shouldUnlock = stats.correctAnswers >= 1000;
          break;
        case 'calc_10000':
          shouldUnlock = stats.correctAnswers >= 10000;
          break;
        case 'streak_5':
          shouldUnlock = stats.bestStreak >= 5;
          break;
        case 'streak_10':
          shouldUnlock = stats.bestStreak >= 10;
          break;
        case 'streak_25':
          shouldUnlock = stats.bestStreak >= 25;
          break;
        case 'streak_50':
          shouldUnlock = stats.bestStreak >= 50;
          break;
        case 'streak_100':
          shouldUnlock = stats.bestStreak >= 100;
          break;
        case 'cph_100':
          shouldUnlock = stats.bestCph >= 100;
          break;
        case 'cph_500':
          shouldUnlock = stats.bestCph >= 500;
          break;
        case 'cph_1000':
          shouldUnlock = stats.bestCph >= 1000;
          break;
        case 'level_5':
          shouldUnlock = stats.currentLevel >= 5;
          break;
        case 'level_10':
          shouldUnlock = stats.currentLevel >= 10;
          break;
        case 'level_25':
          shouldUnlock = stats.currentLevel >= 25;
          break;
        case 'level_50':
          shouldUnlock = stats.currentLevel >= 50;
          break;
        case 'total_xp_1000':
          shouldUnlock = stats.totalXp >= 1000;
          break;
        case 'total_xp_10000':
          shouldUnlock = stats.totalXp >= 10000;
          break;
        case 'total_xp_100000':
          shouldUnlock = stats.totalXp >= 100000;
          break;
        case 'accuracy_100':
          shouldUnlock = lastSession != null &&
              lastSession.wrongCount == 0 &&
              lastSession.totalQuestions > 0;
          break;
      }

      if (shouldUnlock) {
        newlyUnlocked.add(AchievementModel.fromEntity(def).copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        ));
      }
    }

    return newlyUnlocked;
  }

  static bool isAchievementUnlocked(
    List<AchievementModel> achievements,
    String id,
  ) {
    return achievements.any((a) => a.id == id && a.isUnlocked);
  }
}
