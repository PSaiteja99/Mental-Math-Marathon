import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../../providers/tab_reset_provider.dart';
import '../providers/achievements_provider.dart';
import '../widgets/badge_card.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playAchievements();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabReset = ref.watch(tabResetProvider);
    ref.listen<List<int>>(tabResetProvider, (prev, next) {
      if (prev != null && prev[2] != next[2]) {
        _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
    final achievements = ref.watch(achievementsProvider);
    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final total = achievements.length;
    final progress = total > 0 ? unlocked / total : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryBlue.withValues(alpha: 0.1),
                  AppConstants.secondaryNightBlue.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ChampionAnimation(key: ValueKey('champion_${tabReset[2]}')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ProgressRing(
                      progress: progress,
                      size: 80,
                      strokeWidth: 7,
                      color: AppConstants.primaryBlue,
                      centerText: '$unlocked/$total',
                      centerTextStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievements',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            unlocked == total
                                ? 'All achievements unlocked!'
                                : '$unlocked of $total achievements unlocked',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              unlocked == total
                                  ? AppConstants.success
                                  : AppConstants.primaryBlue,
                            ),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                return BadgeCard(achievement: achievements[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChampionAnimation extends StatelessWidget {
  const _ChampionAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          isDark
              ? 'assets/images/Champion_dark.webp'
              : 'assets/images/Champion_light.webp',
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}


