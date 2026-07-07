import 'package:mental_math_marathon/app/constants.dart';

class ScoreEngine {
  static int calculateXp(bool isCorrect, int streak) {
    if (!isCorrect) return 0;
    return AppConstants.xpPerCorrect + (streak ~/ 5) * AppConstants.xpPerStreakBonus;
  }

  static int calculateLevel(int totalXp) {
    for (int i = AppConstants.levelThresholds.length - 1; i >= 0; i--) {
      if (totalXp >= AppConstants.levelThresholds[i]) {
        return i;
      }
    }
    return 0;
  }

  static int calculateCph(int correctCount, double seconds) {
    if (seconds <= 0) return 0;
    return ((correctCount / seconds) * 3600).round();
  }

  static double calculateAccuracy(int correct, int total) {
    if (total <= 0) return 0;
    return (correct / total) * 100;
  }
}
