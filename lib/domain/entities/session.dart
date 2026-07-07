class Session {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String mode;
  final String difficulty;
  final List<String> operators;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int cph;
  final double accuracy;
  final int bestStreak;
  final int xpEarned;

  const Session({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.mode,
    required this.difficulty,
    required this.operators,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.cph,
    required this.accuracy,
    required this.bestStreak,
    required this.xpEarned,
  });

  Duration get duration => endTime.difference(startTime);
}
