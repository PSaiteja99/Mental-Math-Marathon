import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_math_marathon/app/constants.dart';
import 'package:mental_math_marathon/core/services/audio_service.dart';
import 'package:mental_math_marathon/features/game/engine/score_engine.dart';
import 'package:mental_math_marathon/features/game/providers/game_provider.dart';
import 'package:mental_math_marathon/features/game/providers/session_provider.dart';
import 'package:mental_math_marathon/features/statistics/providers/statistics_provider.dart';
import 'package:mental_math_marathon/providers/stats_provider.dart';
import 'package:mental_math_marathon/features/game/widgets/answer_input.dart';
import 'package:mental_math_marathon/features/game/widgets/cph_widget.dart';
import 'package:mental_math_marathon/features/game/widgets/equation_card.dart';
import 'package:mental_math_marathon/features/game/widgets/streak_widget.dart';
import 'package:mental_math_marathon/features/game/widgets/timer_widget.dart';
import 'package:mental_math_marathon/models/game_config.dart';
import 'package:mental_math_marathon/models/session_result.dart';

class GameScreen extends ConsumerStatefulWidget {
  final GameConfig? config;

  const GameScreen({super.key, this.config});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  bool _showResult = false;
  bool _lastCorrect = false;
  int _correctAnswer = 0;
  bool _navigatingToResult = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.config != null) {
        ref.read(gameProvider.notifier).startGame(widget.config!);
      }
      ref.read(audioServiceProvider).playGameMusic();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      final gameState = ref.read(gameProvider);
      if (gameState.isRunning && !gameState.isPaused) {
        ref.read(gameProvider.notifier).pauseGame();
        context.push('/game/pause');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onSubmitAnswer(int answer) {
    final gameState = ref.read(gameProvider);
    if (!gameState.isRunning) return;

    final question = gameState.currentQuestion;
    if (question == null) return;

    _correctAnswer = question.answer;
    _lastCorrect = answer == question.answer;
    _showResult = true;

    if (_lastCorrect) {
      ref.read(audioServiceProvider).playCorrect();
    } else {
      ref.read(audioServiceProvider).playWrong();
    }

    ref.read(gameProvider.notifier).submitAnswer(answer);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _showResult = false);
      final state = ref.read(gameProvider);
      if (state.isRunning) {
        ref.read(gameProvider.notifier).nextQuestion();
      }
    });
  }

  Future<void> _onGameEnded(GameState gameState) async {
    if (_navigatingToResult) return;
    final stats = gameState.stats;
    if (stats == null) return;
    _navigatingToResult = true;

    final db = ref.read(localDatabaseProvider);
    final currentStats = db.getUserStats();
    final cumulativeXp = currentStats.totalXp + stats.totalXp;
    final cumulativeLevel = ScoreEngine.calculateLevel(cumulativeXp) + 1;

    final result = SessionResult(
      correctCount: stats.correctCount,
      wrongCount: stats.wrongCount,
      streak: stats.streak,
      bestStreak: stats.bestStreak,
      totalXp: stats.totalXp,
      questionsAnswered: stats.questionsAnswered,
      elapsedSeconds: stats.elapsedSeconds,
      accuracy: stats.accuracy,
      cph: stats.cph,
      level: stats.level,
      mode: widget.config?.gameMode ?? 'timer',
      difficulty: widget.config?.difficulty ?? 'easy',
      totalQuestions: stats.correctCount + stats.wrongCount,
      previousLevel: currentStats.currentLevel,
      newLevel: cumulativeLevel,
    );
    await ref.read(sessionProvider.notifier).saveSession(result);
    if (!mounted) return;
    ref.invalidate(statisticsProvider);
    if (context.mounted) context.go('/game/result', extra: result);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    ref.listen<GameState>(gameProvider, (previous, next) {
      if (!next.isRunning && next.stats != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onGameEnded(next);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.pause_rounded),
          onPressed: () {
            ref.read(audioServiceProvider).playPause();
            ref.read(gameProvider.notifier).pauseGame();
            context.push('/game/pause');
          },
        ),
        title: const StreakWidget(),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (gameState.stats != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      gameState.isQuestionsMode
                          ? '${gameState.stats!.questionsAnswered}/${widget.config?.questionCount ?? 0}'
                          : '${gameState.stats!.questionsAnswered}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                const CphWidget(),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (gameState.isQuestionsMode)
                  const TimerWidget.elapsed()
                else
                  TimerWidget(totalSeconds: widget.config?.timeLimitSeconds ?? 0),
              ],
            ),
            const SizedBox(height: 8),
            EquationCard(lastCorrect: _showResult ? _lastCorrect : null),
            if (_showResult)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _lastCorrect ? '✓ Correct!' : '✗ $_correctAnswer',
                    key: ValueKey(_lastCorrect),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _lastCorrect
                              ? AppConstants.success
                              : AppConstants.error,
                        ),
                  ),
                ),
              ),
            AnswerInput(onSubmit: _onSubmitAnswer),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
