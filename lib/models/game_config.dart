class GameConfig {
  final String difficulty;
  final List<String> operators;
  final int? timeLimitSeconds;
  final int? questionCount;
  final String gameMode;

  const GameConfig({
    required this.difficulty,
    required this.operators,
    this.timeLimitSeconds,
    this.questionCount,
    this.gameMode = 'timer',
  });

  GameConfig copyWith({
    String? difficulty,
    List<String>? operators,
    int? timeLimitSeconds,
    int? questionCount,
    String? gameMode,
  }) {
    return GameConfig(
      difficulty: difficulty ?? this.difficulty,
      operators: operators ?? this.operators,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      questionCount: questionCount ?? this.questionCount,
      gameMode: gameMode ?? this.gameMode,
    );
  }
}
