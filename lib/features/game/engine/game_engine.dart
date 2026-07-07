import 'package:mental_math_marathon/domain/entities/question.dart';
import 'package:mental_math_marathon/domain/usecases/generate_question.dart';
import 'package:mental_math_marathon/features/game/engine/score_engine.dart';
import 'package:mental_math_marathon/models/game_config.dart';

class GameEngine {
  final GenerateQuestion _generateQuestion = GenerateQuestion();

  GameConfig? _config;
  Question? _currentQuestion;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _totalXp = 0;
  int _questionsAnswered = 0;
  Stopwatch? _stopwatch;
  bool _isRunning = false;

  bool get isRunning => _isRunning;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;
  int get streak => _streak;
  int get bestStreak => _bestStreak;
  int get totalXp => _totalXp;
  int get questionsAnswered => _questionsAnswered;
  double get elapsedSeconds => (_stopwatch?.elapsedMilliseconds ?? 0) / 1000.0;

  bool get isQuestionsMode => _config?.gameMode == 'questions';

  void startGame(GameConfig config) {
    _config = config;
    _correctCount = 0;
    _wrongCount = 0;
    _streak = 0;
    _bestStreak = 0;
    _totalXp = 0;
    _questionsAnswered = 0;
    _isRunning = true;
    _stopwatch = Stopwatch()..start();
    nextQuestion();
  }

  void submitAnswer(int answer) {
    if (!_isRunning || _currentQuestion == null) return;

    _questionsAnswered++;
    if (answer == _currentQuestion!.answer) {
      _correctCount++;
      _streak++;
      if (_streak > _bestStreak) _bestStreak = _streak;
      _totalXp += ScoreEngine.calculateXp(true, _streak);
    } else {
      _wrongCount++;
      _streak = 0;
    }

    if (_config!.gameMode == 'questions' &&
        _config!.questionCount != null &&
        _questionsAnswered >= _config!.questionCount!) {
      endGame();
    }
  }

  void nextQuestion() {
    if (_config == null) return;
    _currentQuestion = _generateQuestion.call(_config!);
  }

  void endGame() {
    _isRunning = false;
    _stopwatch?.stop();
  }

  void pause() {
    _stopwatch?.stop();
  }

  void resume() {
    _stopwatch?.start();
  }

  Question? getCurrentQuestion() => _currentQuestion;

  GameStats getStats() {
    return GameStats(
      correctCount: _correctCount,
      wrongCount: _wrongCount,
      streak: _streak,
      bestStreak: _bestStreak,
      totalXp: _totalXp,
      questionsAnswered: _questionsAnswered,
      elapsedSeconds: elapsedSeconds,
      accuracy: ScoreEngine.calculateAccuracy(
        _correctCount,
        _questionsAnswered,
      ),
      cph: ScoreEngine.calculateCph(_correctCount, elapsedSeconds),
      level: ScoreEngine.calculateLevel(_totalXp),
    );
  }
}

class GameStats {
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

  const GameStats({
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
  });
}
