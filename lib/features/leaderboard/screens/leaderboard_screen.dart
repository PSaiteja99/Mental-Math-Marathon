import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: asyncData.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  children: data.entries.map((entry) {
                    return _LeaderboardCard(entry: entry);
                  }).toList(),
                ),
              ),
              if (data.topSessions.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Top Sessions by CPH',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                ...data.topSessions.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final session = entry.value;
                  return Card(
                    child: ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: idx < 3
                              ? [AppConstants.warning, Colors.grey, AppConstants.error][idx]
                                  .withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: idx < 3
                                  ? [AppConstants.warning, Colors.grey, AppConstants.error][idx]
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        '${session.cph} CPH',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${session.mode} \u2022 ${session.difficulty} \u2022 ${session.totalQuestions} questions',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        '${session.accuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppConstants.success,
                        ),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('Failed to load leaderboard', style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const _LeaderboardCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final valueColor = entry.label == 'Highest CPH'
        ? AppConstants.warning
        : entry.label == 'Longest Streak'
            ? AppConstants.error
            : entry.label == 'Most in Session'
                ? AppConstants.primaryBlue
                : AppConstants.success;

    return Card(
      elevation: 0,
      color: valueColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: valueColor.withValues(alpha: 0.2), width: 1),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              entry.value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (entry.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                entry.subtitle!,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: entry.progress,
                backgroundColor: Colors.grey.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(valueColor),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
