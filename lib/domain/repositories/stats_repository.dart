import 'package:mental_math_marathon/data/models/achievement_model.dart';
import 'package:mental_math_marathon/data/models/session_model.dart';
import 'package:mental_math_marathon/data/models/user_stats_model.dart';

abstract class StatsRepository {
  UserStatsModel getUserStats();
  Future<void> updateUserStats(UserStatsModel stats);
  List<SessionModel> getSessions();
  List<AchievementModel> getAchievements();
  Future<void> unlockAchievement(AchievementModel achievement);
}
