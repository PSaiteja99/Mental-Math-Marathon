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
  bool _xpDoubled = false;
  int _hintsUsed = 0;
  int _continuesUsed = 0;
  int _extraTimeAdded = 0;

  bool get isRunning => _isRunning;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;
  int get streak => _streak;
  int get bestStreak => _bestStreak;
  int get totalXp => _totalXp;
  int get questionsAnswered => _questionsAnswered;
  double get elapsedSeconds => (_stopwatch?.elapsedMilliseconds ?? 0) / 1000.0;
  int get hintsUsed => _hintsUsed;
  int get continuesUsed => _continuesUsed;
  int get extraTimeAdded => _extraTimeAdded;
  bool get xpDoubled => _xpDoubled;

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
    _xpDoubled = false;
    _hintsUsed = 0;
    _continuesUsed = 0;
    _extraTimeAdded = 0;
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
      final xp = ScoreEngine.calculateXp(true, _streak);
      _totalXp += _xpDoubled ? xp * 2 : xp;
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

  int applyHint() {
    if (_currentQuestion == null) return 0;
    _hintsUsed++;
    final answer = _currentQuestion!.answer;
    final absAnswer = answer.abs();
    final numDigits = absAnswer.toString().length;
    if (numDigits <= 1) return 0;
    final revealDigit = (_hintsUsed - 1) % numDigits;
    final divisor = _pow(10, numDigits - 1 - revealDigit);
    final digit = (absAnswer ~/ divisor) % 10;
    return digit;
  }

  static int _pow(int base, int exp) {
    int result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  void addExtraTime(int seconds) {
    _extraTimeAdded += seconds;
  }

  void setXpDoubled(bool v) {
    _xpDoubled = v;
  }

  void addContinue() {
    _continuesUsed++;
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
      xpDoubled: _xpDoubled,
      hintsUsed: _hintsUsed,
      continuesUsed: _continuesUsed,
      extraTimeAdded: _extraTimeAdded,
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
  final bool xpDoubled;
  final int hintsUsed;
  final int continuesUsed;
  final int extraTimeAdded;

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
    this.xpDoubled = false,
    this.hintsUsed = 0,
    this.continuesUsed = 0,
    this.extraTimeAdded = 0,
  });
}
