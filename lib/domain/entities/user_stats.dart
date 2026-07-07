class UserStats {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int bestCph;
  final int bestStreak;
  final int totalXp;
  final int currentLevel;

  const UserStats({
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.bestCph = 0,
    this.bestStreak = 0,
    this.totalXp = 0,
    this.currentLevel = 1,
  });

  double get accuracy =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  UserStats copyWith({
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    int? bestCph,
    int? bestStreak,
    int? totalXp,
    int? currentLevel,
  }) {
    return UserStats(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      bestCph: bestCph ?? this.bestCph,
      bestStreak: bestStreak ?? this.bestStreak,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }
}
