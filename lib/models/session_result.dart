import 'package:mental_math_marathon/data/models/session_model.dart';

class SessionResult {
  final int correctCount;
  final int wrongCount;
  final int streak;
  final int bestStreak;
  final int totalXp;
  final int questionsAnswered;
  final double elapsedSeconds;
  final double accuracy;
  final int cph;
  final int level;
  final String mode;
  final String difficulty;
  final int totalQuestions;
  final int previousLevel;
  final int newLevel;

  const SessionResult({
    required this.correctCount,
    required this.wrongCount,
    required this.streak,
    required this.bestStreak,
    required this.totalXp,
    required this.questionsAnswered,
    required this.elapsedSeconds,
    required this.accuracy,
    required this.cph,
    required this.level,
    required this.mode,
    required this.difficulty,
    required this.totalQuestions,
    required this.previousLevel,
    required this.newLevel,
  });

  bool get leveledUp => newLevel > previousLevel;

  SessionModel toSessionModel() {
    return SessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now().subtract(Duration(seconds: elapsedSeconds.round())),
      endTime: DateTime.now(),
      mode: mode,
      difficulty: difficulty,
      operators: [],
      totalQuestions: totalQuestions,
      correctAnswers: correctCount,
      wrongAnswers: wrongCount,
      cph: cph,
      accuracy: accuracy,
      bestStreak: bestStreak,
      xpEarned: totalXp,
    );
  }
}
