import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_math_marathon/app/constants.dart';
import 'package:mental_math_marathon/core/services/audio_service.dart';
import 'package:mental_math_marathon/core/services/ad_service.dart';
import 'package:mental_math_marathon/core/services/crazy_games_sdk_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await AdService.instance.onGameStart();

      if (widget.config != null) {
        ref.read(gameProvider.notifier).startGame(widget.config!);
      }
      ref.read(audioServiceProvider).playGameMusic();
      CrazyGamesSdkService.instance.gameplayStart();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
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
    AdService.instance.onQuestionAnswered();

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

    CrazyGamesSdkService.instance.gameplayStop();
    AdService.instance.onGameEnded();
    AdService.instance.happyTime();

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

  Future<void> _onContinueWithAd() async {
    final adShown = await AdService.instance.showRewardedAd();
    if (!adShown || !mounted) return;
    ref.read(gameProvider.notifier).addContinue();
    ref.read(gameProvider.notifier).addExtraTime(30);
    ref.read(gameProvider.notifier).resumeGame();
    CrazyGamesSdkService.instance.gameplayStart();
  }

  void _onEndFromTimeUp() {
    ref.read(gameProvider.notifier).endGame();
  }

  Future<void> _onUseHint() async {
    final gameState = ref.read(gameProvider);
    if (!gameState.isRunning) return;

    final adShown = await AdService.instance.showRewardedAd();
    if (!adShown || !mounted) return;
    ref.read(gameProvider.notifier).useHint();
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
                if (gameState.xpDoubled)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.auto_awesome, color: AppConstants.warning, size: 18),
                  ),
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                EquationCard(
                  lastCorrect: _showResult ? _lastCorrect : null,
                  hintDigit: gameState.hintDigit,
                ),
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
                const SizedBox(height: 8),
                _buildHintButton(gameState),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (gameState.isTimeUp) _buildTimeUpOverlay(),
        ],
      ),
    );
  }

  Widget _buildHintButton(GameState gameState) {
    if (!gameState.isRunning || gameState.isPaused) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _onUseHint,
          icon: const Icon(Icons.lightbulb_rounded, size: 18),
          label: Text(
            gameState.hintDigit != null ? 'Another Hint (Watch Ad)' : 'Get Hint (Watch Ad)',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(
              color: AppConstants.warning.withValues(alpha: 0.5),
            ),
            foregroundColor: AppConstants.warning,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeUpOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_off_rounded, size: 64, color: AppConstants.error),
                const SizedBox(height: 16),
                Text(
                  'Time\'s Up!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Continue with +30 seconds?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _onContinueWithAd,
                    icon: const Icon(Icons.play_circle_rounded),
                    label: const Text('Continue (Watch Ad)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _onEndFromTimeUp,
                    child: const Text('End Game'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
