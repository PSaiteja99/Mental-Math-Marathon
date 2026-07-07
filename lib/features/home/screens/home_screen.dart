import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:mental_math_marathon/app/constants.dart';
import 'package:mental_math_marathon/core/services/audio_service.dart';
import 'package:mental_math_marathon/core/widgets/daily_reward_dialog.dart';
import 'package:mental_math_marathon/features/game/screens/result_screen.dart';
import 'package:mental_math_marathon/features/home/providers/home_provider.dart';
import 'package:mental_math_marathon/providers/stats_provider.dart';
import 'package:mental_math_marathon/features/home/widgets/level_card.dart';
import 'package:mental_math_marathon/features/home/widgets/mode_card.dart';
import 'package:mental_math_marathon/features/home/widgets/quick_stats.dart';
import 'package:mental_math_marathon/features/settings/providers/settings_provider.dart';
import 'package:mental_math_marathon/models/game_config.dart';
import 'package:mental_math_marathon/providers/tab_reset_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Set<String> _selectedOperators = {'+', '-'};
  final _scrollController = ScrollController();
  final _progressKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playMenuMusic();
      DailyRewardDialog.showIfAvailable(
        context,
        ref,
        onClaimed: () => ref.read(homeStatsRefreshProvider.notifier).state++,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<int>>(tabResetProvider, (prev, next) {
      if (prev != null && prev[0] != next[0]) {
        _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
    final statsAsync = ref.watch(homeStatsProvider);
    final gs = ref.watch(gameSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              AppConstants.appName,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              AppConstants.tagline,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            Center(
              child: FittedBox(
                child: const BoxingAnimation(
                  width: 450,
                  height: 300,
                ),
              ),
            ),
            const SizedBox(height: 0),
            statsAsync.when(
              data: (stats) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LevelCard(
                  level: stats.currentLevel,
                  totalXp: stats.totalXp,
                  onTap: () {
                    Scrollable.ensureVisible(
                      _progressKey.currentContext!,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SizedBox(),
            ),
            
            const SizedBox(height: 16),
            _SectionTitle(title: 'Game Modes'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _OperatorChip(
                    label: '+',
                    selected: _selectedOperators.contains('+'),
                    onSelected: (_) => _toggleOperator('+'),
                  ),
                  _OperatorChip(
                    label: '-',
                    selected: _selectedOperators.contains('-'),
                    onSelected: (_) => _toggleOperator('-'),
                  ),
                  _OperatorChip(
                    label: '×',
                    selected: _selectedOperators.contains('×'),
                    onSelected: (_) => _toggleOperator('×'),
                  ),
                  _OperatorChip(
                    label: '÷',
                    selected: _selectedOperators.contains('÷'),
                    onSelected: (_) => _toggleOperator('÷'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ModeCard(
              title: 'Easy',
              subtitle: "Let's start this amazing journey!",
              leading: SizedBox(
                width: 80,
                height: 80,
                child: Lottie.asset(
                  'assets/lottie/easy_running.json',
                  fit: BoxFit.contain,
                ),
              ),
              color: AppConstants.success,
              onTap: () => _startGame(
                context,
                ref,
                'easy',
                _selectedOperators.toList(),
                gs.easyTimeLimit,
                gs.questionCount,
              ),
            ),
            ModeCard(
              title: 'Medium',
              subtitle: 'Improve your skills and speed!',
              leading: SizedBox(
                width: 80,
                height: 80,
                child: Lottie.asset(
                  'assets/lottie/medium_running.json',
                  fit: BoxFit.contain,
                ),
              ),
              color: AppConstants.warning,
              onTap: () => _startGame(
                context,
                ref,
                'medium',
                _selectedOperators.toList(),
                gs.mediumTimeLimit,
                gs.questionCount,
              ),
            ),
            ModeCard(
              title: 'Hard',
              subtitle: 'Best of the best! Challenge yourself to the limit!',
              leading: SizedBox(
                width: 80,
                height: 80,
                child: Lottie.asset(
                  'assets/lottie/hard_running.json',
                  fit: BoxFit.contain,
                ),
              ),
              color: AppConstants.error,
              onTap: () => _startGame(
                context,
                ref,
                'hard',
                _selectedOperators.toList(),
                gs.hardTimeLimit,
                gs.questionCount,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:Center(child: Text(
                'Customize game types and audio in Settings',
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.primaryBlue,
                  fontStyle: FontStyle.italic,
                ),
              ),)
            ),
            const SizedBox(height: 16),
            _SectionTitle(key: _progressKey, title: 'Progress'),
            statsAsync.when(
              data: (stats) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuickStats(stats: stats),
              ),
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(
    BuildContext context,
    WidgetRef ref,
    String difficulty,
    List<String> operators,
    int timeLimit,
    int questionCount,
  ) {
    ref.read(audioServiceProvider).playStart();
    final gs = ref.read(gameSettingsProvider);
    final config = GameConfig(
      difficulty: difficulty,
      operators: operators,
      timeLimitSeconds: timeLimit,
      questionCount: questionCount,
      gameMode: gs.gameMode,
    );
    context.go('/game', extra: config);
  }

  void _toggleOperator(String op) {
    ref.read(audioServiceProvider).playClick();
    setState(() {
      if (_selectedOperators.contains(op)) {
        if (_selectedOperators.length > 1) {
          _selectedOperators.remove(op);
        }
      } else {
        _selectedOperators.add(op);
      }
    });
  }

}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _OperatorChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _OperatorChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: selected ? Colors.white : (isDark ? Colors.white70 : null),
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppConstants.primaryBlue,
      checkmarkColor: Colors.white,
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
