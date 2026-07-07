import 'package:mental_math_marathon/data/datasources/local_database.dart';
import 'package:mental_math_marathon/data/models/achievement_model.dart';
import 'package:mental_math_marathon/data/models/session_model.dart';
import 'package:mental_math_marathon/data/models/user_stats_model.dart';
import 'package:mental_math_marathon/domain/repositories/stats_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  final LocalDatabase _db;

  StatsRepositoryImpl(this._db);

  @override
  UserStatsModel getUserStats() {
    return _db.getUserStats();
  }

  @override
  Future<void> updateUserStats(UserStatsModel stats) async {
    await _db.saveUserStats(stats);
  }

  @override
  List<SessionModel> getSessions() {
    return _db.getSessions();
  }

  @override
  List<AchievementModel> getAchievements() {
    return _db.getAchievements();
  }

  @override
  Future<void> unlockAchievement(AchievementModel achievement) async {
    await _db.addAchievement(achievement);
  }
}
