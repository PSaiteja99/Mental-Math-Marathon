import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/local_database.dart';
import '../../../data/models/achievement_model.dart';
import '../../../domain/entities/achievement.dart';
import '../../../providers/stats_provider.dart';

final achievementsProvider = StateNotifierProvider<AchievementsNotifier, List<AchievementModel>>((ref) {
  final db = ref.watch(localDatabaseProvider);
  return AchievementsNotifier(db);
});

class AchievementsNotifier extends StateNotifier<List<AchievementModel>> {
  final LocalDatabase _db;

  AchievementsNotifier(this._db) : super([]) {
    _load();
  }

  void _load() {
    final saved = _db.getAchievements();
    final merged = AchievementDefinitions.all.map((def) {
      final match = saved.where((a) => a.id == def.id).firstOrNull;
      if (match != null && match.isUnlocked) {
        return match;
      }
      return AchievementModel.fromEntity(def);
    }).toList();
    state = merged;
  }

  Future<void> unlockAchievement(String id) async {
    final updated = state.map((a) {
      if (a.id == id && !a.isUnlocked) {
        return a.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
      return a;
    }).toList();
    state = updated;
    final unlocked = updated.where((a) => a.isUnlocked).toList();
    await _db.saveAchievements(unlocked);
  }

  bool isUnlocked(String id) {
    return state.any((a) => a.id == id && a.isUnlocked);
  }
}

final recentlyUnlockedProvider = StateNotifierProvider<RecentlyUnlockedNotifier, List<AchievementModel>>((ref) {
  return RecentlyUnlockedNotifier();
});

class RecentlyUnlockedNotifier extends StateNotifier<List<AchievementModel>> {
  RecentlyUnlockedNotifier() : super([]);

  void addAchievement(AchievementModel achievement) {
    state = [...state, achievement];
    Future.delayed(const Duration(seconds: 5), () {
        dismissAchievement(achievement.id);
    });
  }

  void dismissAchievement(String id) {
    state = state.where((a) => a.id != id).toList();
  }
}



