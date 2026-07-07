import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_math_marathon/app/constants.dart';
import 'package:mental_math_marathon/core/services/audio_service.dart';
import 'package:mental_math_marathon/features/game/providers/game_provider.dart';

class PauseScreen extends ConsumerStatefulWidget {
  const PauseScreen({super.key});

  @override
  ConsumerState<PauseScreen> createState() => _PauseScreenState();
}

class _PauseScreenState extends ConsumerState<PauseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playPause();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final stats = gameState.stats;

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pause_circle_filled_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Game Paused',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (stats != null) ...[
                  const SizedBox(height: 24),
                  _PauseStatRow(label: 'Correct', value: '${stats.correctCount}'),
                  _PauseStatRow(label: 'Wrong', value: '${stats.wrongCount}'),
                  _PauseStatRow(label: 'Streak', value: '${stats.streak}'),
                  _PauseStatRow(label: 'CPH', value: '${stats.cph}'),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(audioServiceProvider).playClick();
                      ref.read(gameProvider.notifier).resumeGame();
                      context.pop();
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Resume'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(audioServiceProvider).playClick();
                  ref.read(gameProvider.notifier).endGame();
                },
                    icon: const Icon(Icons.exit_to_app_rounded),
                    label: const Text('Quit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.error,
                      side: const BorderSide(color: AppConstants.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
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

class _PauseStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _PauseStatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
