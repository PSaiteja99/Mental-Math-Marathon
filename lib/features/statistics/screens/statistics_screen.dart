import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../app/constants.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../providers/tab_reset_provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/accuracy_chart.dart';
import '../widgets/cph_chart.dart';
import '../widgets/streak_chart.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  final _scrollController = ScrollController();
  final _accuracyKey = GlobalKey();
  final _cphKey = GlobalKey();
  final _streakKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
    ref.read(audioServiceProvider).playStatisticsCards();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<int>>(tabResetProvider, (prev, next) {
      if (prev != null && prev[1] != next[1]) {
        _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
    final asyncData = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: asyncData.when(
        data: (data) => SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: RepaintBoundary(
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Lottie.asset('assets/lottie/Growth.json'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.1,
                  children: [
                    StatCard(
                      label: 'Total Questions',
                      value: '${data.stats.totalQuestions}',
                      icon: Icons.calculate_rounded,
                      color: AppConstants.error,
                      onTap: () => ref.read(audioServiceProvider).playStatisticsCards(),
                    ),
                    StatCard(
                      label: 'Accuracy',
                      value: '${data.stats.accuracy.toStringAsFixed(1)}%',
                      icon: Icons.track_changes_rounded,
                      color: AppConstants.success,
                      onTap: () => _scrollTo(_accuracyKey),
                    ),
                    StatCard(
                      label: 'Best CPH',
                      value: '${data.stats.bestCph}',
                      icon: Icons.speed_rounded,
                      color: AppConstants.primaryBlue,
                      onTap: () => _scrollTo(_cphKey),
                    ),
                    StatCard(
                      label: 'Best Streak',
                      value: '${data.stats.bestStreak}',
                      icon: Icons.local_fire_department_rounded,
                      color: AppConstants.warning,
                      onTap: () => _scrollTo(_streakKey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (data.accuracyHistory.isNotEmpty) ...[
                Padding(
                  key: _accuracyKey,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AccuracyChart(
                        accuracyHistory: data.accuracyHistory,
                        labels: data.sessionLabels,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  key: _cphKey,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CphChart(
                        cphHistory: data.cphHistory,
                        labels: data.sessionLabels,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  key: _streakKey,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: StreakChart(
                        streakHistory: data.streakHistory,
                        labels: data.sessionLabels,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (data.recentSessions.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Recent Sessions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                ...data.recentSessions.take(10).map((session) => Card(
                  child: ListTile(
                    onTap: () => ref.read(audioServiceProvider).playRecentSessions(),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${session.totalQuestions}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      '${session.mode} - ${session.difficulty}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${session.cph} CPH \u2022 ${session.accuracy.toStringAsFixed(1)}% acc',
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${session.xpEarned} XP',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(session.startTime),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('Failed to load statistics', style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
