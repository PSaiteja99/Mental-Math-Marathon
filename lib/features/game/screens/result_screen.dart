import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mental_math_marathon/app/constants.dart';
import 'package:mental_math_marathon/core/services/audio_service.dart';
import 'package:mental_math_marathon/core/services/ad_service.dart';
import 'package:mental_math_marathon/core/utils/extensions.dart';
import 'package:mental_math_marathon/models/game_config.dart';
import 'package:mental_math_marathon/models/session_result.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final SessionResult? result;

  const ResultScreen({super.key, this.result});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _xpDoubled = false;
  bool _xpAdLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playResultMusic();
      final r = widget.result;
      if (r != null) {
        if (r.leveledUp) {
          ref.read(audioServiceProvider).playLevelUp();
          _showLevelUpDialog(r);
        } else if (r.accuracy >= 70) {
          ref.read(audioServiceProvider).playWin();
        } else {
          ref.read(audioServiceProvider).playKeepPracticing();
        }
      }
    });
  }

  void _showLevelUpDialog(SessionResult r) {
    final title = r.newLevel <= AppConstants.levelTitles.length
        ? AppConstants.levelTitles[r.newLevel - 1]
        : 'Legend';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppConstants.warning, AppConstants.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.warning.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'LEVEL UP!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.warning,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Level ${r.newLevel}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onDoubleXp() async {
    setState(() => _xpAdLoading = true);
    final success = await AdService.instance.showRewardedAd();
    setState(() => _xpAdLoading = false);
    if (success && mounted) {
      setState(() => _xpDoubled = true);
      ref.read(audioServiceProvider).playLevelUp();
    }
  }

  void _playAgain() {
    final r = widget.result;
    if (r == null) return;
    ref.read(audioServiceProvider).playStart();
    final config = GameConfig(
      difficulty: r.difficulty,
      operators: ['+', '-'],
      gameMode: r.mode,
    );
    context.go('/game', extra: config);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    if (r == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No results available',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );
    }

    final showConfetti = r.accuracy >= 70;
    final displayedXp = _xpDoubled ? r.totalXp * 2 : r.totalXp;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildHeader(context, r),
                        const SizedBox(height: 32),
                        _buildMainStat(context, r, displayedXp),
                        const SizedBox(height: 32),
                        _buildStatsGrid(context, r, displayedXp),
                        if (!_xpDoubled && r.totalXp > 0) ...[
                          const SizedBox(height: 16),
                          _buildDoubleXpButton(),
                        ],
                        const Spacer(),
                        _buildActions(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showConfetti)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.35,
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/lottie/Confetti.json',
                  fit: BoxFit.fill,
                  repeat: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SessionResult r) {
    final isGood = r.accuracy >= 70;
    return Column(
      children: [
        if (isGood)
          SizedBox(
            width: 220,
            height: 220,
            child: Lottie.asset('assets/lottie/Trophy.json'),
          )
        else
          const BoxingAnimation(width: 250, height: 220),
        const SizedBox(height: 16),
        Text(
          isGood ? 'Great Job!' : 'Keep Practicing!',
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${r.mode.toUpperCase()} • ${r.difficulty.toUpperCase()}',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMainStat(BuildContext context, SessionResult r, int displayedXp) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryBlue.withValues(alpha: 0.1),
              AppConstants.secondaryNightBlue.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              '${r.cph}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryBlue,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Calculations Per Hour',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '${r.totalQuestions} questions in ${r.elapsedSeconds.round().toHms}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[500]),
            ),
            if (_xpDoubled)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: AppConstants.warning),
                    SizedBox(width: 6),
                    Text(
                      'XP DOUBLED!',
                      style: TextStyle(
                        color: AppConstants.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, SessionResult r, int displayedXp) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ResultStatCard(
                label: 'Accuracy',
                value: '${r.accuracy.toStringAsFixed(0)}%',
                color: r.accuracy >= 70 ? AppConstants.success : AppConstants.error,
                icon: Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ResultStatCard(
                label: 'Level',
                value: '${r.newLevel}',
                color: AppConstants.primaryBlue,
                icon: Icons.stars_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ResultStatCard(
                label: 'Correct',
                value: '${r.correctCount}',
                color: AppConstants.success,
                icon: Icons.check_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ResultStatCard(
                label: 'Wrong',
                value: '${r.wrongCount}',
                color: AppConstants.error,
                icon: Icons.close_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ResultStatCard(
                label: 'Best Streak',
                value: '${r.bestStreak}',
                color: AppConstants.warning,
                icon: Icons.local_fire_department_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ResultStatCard(
                label: 'XP Earned',
                value: '+$displayedXp',
                color: AppConstants.secondaryNightBlue,
                icon: Icons.bolt_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoubleXpButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _xpAdLoading ? null : _onDoubleXp,
        icon: _xpAdLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome_rounded, size: 18),
        label: Text(_xpAdLoading ? 'Loading Ad...' : 'Double XP (Watch Ad)'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          foregroundColor: AppConstants.warning,
          side: BorderSide(color: AppConstants.warning.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _playAgain,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Play Again'),
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
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(audioServiceProvider).playHome();
              ref.read(audioServiceProvider).playMenuMusic();
              AdService.instance.onReturnHome();
              context.go('/home');
            },
            icon: const Icon(Icons.home_rounded),
            label: const Text('Back to Home'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(audioServiceProvider).playStatistics();
              ref.read(audioServiceProvider).playMenuMusic();
              context.go('/statistics');
            },
            icon: const Icon(Icons.bar_chart_rounded),
            label: const Text('Your Progress'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class BoxingAnimation extends ConsumerStatefulWidget {
  final double width;
  final double height;
  const BoxingAnimation({super.key, this.width = 220, this.height = 220});

  @override
  ConsumerState<BoxingAnimation> createState() => BoxingAnimationState();
}

class BoxingAnimationState extends ConsumerState<BoxingAnimation> {
  late AudioPlayer _audioPlayer;
  final _random = Random();

  static const _tapSounds = [
    'sounds/sound/0.wav',
    'sounds/sound/1.wav',
    'sounds/sound/2.wav',
    'sounds/sound/3.wav',
    'sounds/sound/4.wav',
    'sounds/sound/8.wav',
    'sounds/sound/9.wav',
    'sounds/sound/15.wav',
    'sounds/sound/20.wav',
    'sounds/sound/42.wav',
    'sounds/sound/69.wav',
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          usageType: AndroidUsageType.game,
          contentType: AndroidContentType.sonification,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTapSound() async {
    if (!ref.read(audioServiceProvider).isEnabled) return;
    final path = _tapSounds[_random.nextInt(_tapSounds.length)];
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path));
      await _audioPlayer.setPlaybackRate(1.0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _playTapSound,
      child: SizedBox(
        width: widget.width,
        height: widget.width * 1080 / 1384,
        child: Image.asset(
          isDark
              ? 'assets/images/BoxingBlack_15x.webp'
              : 'assets/images/BoxingWhite_15x.webp',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ResultStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ResultStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
