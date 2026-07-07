import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_math_marathon/app/constants.dart';

class DailyRewardService {
  DailyRewardService._();
  static final DailyRewardService instance = DailyRewardService._();

  static const String _keyLastDaily = 'daily_reward_last_date';
  static const String _keyDailyStreak = 'daily_reward_streak';
  static const String _keyDayOffset = 'daily_reward_day';

  Future<bool> canClaimToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_keyLastDaily);
    if (lastDate == null) return true;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastDate != today;
  }

  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDailyStreak) ?? 0;
  }

  Future<int> getCurrentDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDayOffset) ?? 1;
  }

  Future<DailyReward> claimReward({bool doubled = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_keyLastDaily);
    var currentStreak = prefs.getInt(_keyDailyStreak) ?? 0;
    var currentDay = prefs.getInt(_keyDayOffset) ?? 1;

    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

    if (lastDate == yesterday) {
    } else if (lastDate == today) {
      return DailyReward(day: currentDay, xp: 0, streak: currentStreak);
    } else {
      currentStreak = 0;
      currentDay = 1;
    }

    final newStreak = currentStreak + 1;
    final rewardInfo = _getRewardsForDay(currentDay);
    final xpReward = doubled ? rewardInfo.xp * 2 : rewardInfo.xp;

    try {
      final stats = StatsRepository(prefs);
      stats.addXp(xpReward);
    } catch (_) {}

    await prefs.setString(_keyLastDaily, today);
    await prefs.setInt(_keyDailyStreak, newStreak);
    await prefs.setInt(_keyDayOffset, currentDay + 1);

    return DailyReward(
      day: currentDay,
      xp: xpReward,
      streak: newStreak,
      doubled: doubled,
      label: rewardInfo.label,
    );
  }

  DailyRewardInfo _getRewardsForDay(int day) {
    final index = ((day - 1) % _dailyRewards.length);
    return _dailyRewards[index];
  }

  static const List<DailyRewardInfo> _dailyRewards = [
    DailyRewardInfo(day: 1, xp: 50, label: 'Day 1'),
    DailyRewardInfo(day: 2, xp: 75, label: 'Day 2'),
    DailyRewardInfo(day: 3, xp: 100, label: 'Day 3'),
    DailyRewardInfo(day: 4, xp: 150, label: 'Day 4'),
    DailyRewardInfo(day: 5, xp: 200, label: 'Day 5'),
    DailyRewardInfo(day: 6, xp: 250, label: 'Day 6'),
    DailyRewardInfo(day: 7, xp: 500, label: 'Day 7 (Bonus!)'),
  ];
}

class DailyRewardInfo {
  final int day;
  final int xp;
  final String label;
  const DailyRewardInfo({
    required this.day,
    required this.xp,
    required this.label,
  });
}

class DailyReward {
  final int day;
  final int xp;
  final int streak;
  final bool doubled;
  final String label;
  const DailyReward({
    required this.day,
    required this.xp,
    required this.streak,
    this.doubled = false,
    this.label = '',
  });
}

class StatsRepository {
  final SharedPreferences _prefs;
  StatsRepository(this._prefs);

  void addXp(int xp) {
    final totalXp = _prefs.getInt(AppConstants.keyTotalXp) ?? 0;
    _prefs.setInt(AppConstants.keyTotalXp, totalXp + xp);
  }
}

final dailyRewardServiceProvider = Provider<DailyRewardService>((ref) {
  return DailyRewardService.instance;
});
