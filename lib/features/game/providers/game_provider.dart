import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_math_marathon/domain/entities/question.dart';
import 'package:mental_math_marathon/features/game/engine/game_engine.dart';
import 'package:mental_math_marathon/models/game_config.dart';

class GameState {
  final Question? currentQuestion;
  final GameStats? stats;
  final bool isRunning;
  final double elapsedSeconds;
  final int cph;
  final bool isPaused;
  final int timeDisplaySeconds;
  final bool isQuestionsMode;

  const GameState({
    this.currentQuestion,
    this.stats,
    this.isRunning = false,
    this.elapsedSeconds = 0,
    this.cph = 0,
    this.isPaused = false,
    this.timeDisplaySeconds = 0,
    this.isQuestionsMode = false,
  });

  GameState copyWith({
    Question? currentQuestion,
    GameStats? stats,
    bool? isRunning,
    double? elapsedSeconds,
    int? cph,
    bool? isPaused,
    int? timeDisplaySeconds,
    bool? isQuestionsMode,
  }) {
    return GameState(
      currentQuestion: currentQuestion ?? this.currentQuestion,
      stats: stats ?? this.stats,
      isRunning: isRunning ?? this.isRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      cph: cph ?? this.cph,
      isPaused: isPaused ?? this.isPaused,
      timeDisplaySeconds: timeDisplaySeconds ?? this.timeDisplaySeconds,
      isQuestionsMode: isQuestionsMode ?? this.isQuestionsMode,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final GameEngine _engine = GameEngine();
  Timer? _timer;
  int? _timeRemaining;
  int _totalTimeLimit = 0;

  GameNotifier() : super(const GameState());

  void startGame(GameConfig config) {
    _engine.startGame(config);
    _totalTimeLimit = config.timeLimitSeconds ?? 0;
    _timeRemaining = config.gameMode == 'timer' ? _totalTimeLimit : null;
    state = GameState(
      currentQuestion: _engine.getCurrentQuestion(),
      isRunning: true,
      elapsedSeconds: 0,
      cph: 0,
      timeDisplaySeconds: config.gameMode == 'timer' ? _totalTimeLimit : 0,
      isQuestionsMode: config.gameMode == 'questions',
    );
    _startTimer();
  }

  void submitAnswer(int answer) {
    if (!state.isRunning || state.isPaused) return;
    _engine.submitAnswer(answer);
    final stats = _engine.getStats();
    state = state.copyWith(stats: stats, cph: stats.cph);
  }

  void nextQuestion() {
    if (!state.isRunning || state.isPaused) return;
    _engine.nextQuestion();
    state = state.copyWith(currentQuestion: _engine.getCurrentQuestion());
  }

  void pauseGame() {
    if (!state.isRunning || state.isPaused) return;
    _engine.pause();
    _timer?.cancel();
    state = state.copyWith(isPaused: true);
  }

  void resumeGame() {
    if (!state.isRunning || !state.isPaused) return;
    _engine.resume();
    state = state.copyWith(isPaused: false);
    _startTimer();
  }

  void endGame() {
    _engine.endGame();
    _timer?.cancel();
    _timeRemaining = null;
    final stats = _engine.getStats();
    state = state.copyWith(
      stats: stats,
      isRunning: false,
      cph: stats.cph,
      isPaused: false,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isPaused) return;

      if (!_engine.isRunning) {
        endGame();
        return;
      }

      if (_timeRemaining != null) {
        _timeRemaining = _timeRemaining! - 1;
        if (_timeRemaining! <= 0) {
          _timeRemaining = 0;
          _engine.endGame();
          endGame();
          return;
        }
      }

      state = state.copyWith(
        elapsedSeconds: _engine.elapsedSeconds,
        cph: _engine.getStats().cph,
        timeDisplaySeconds: state.isQuestionsMode
            ? _engine.elapsedSeconds.round()
            : (_timeRemaining ?? 0),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _engine.endGame();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider.autoDispose<GameNotifier, GameState>((ref) {
  return GameNotifier();
});
