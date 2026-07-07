import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_math_marathon/app/constants.dart';
import 'package:mental_math_marathon/core/utils/extensions.dart';
import 'package:mental_math_marathon/features/game/providers/game_provider.dart';

class TimerWidget extends ConsumerStatefulWidget {
  final int totalSeconds;

  const TimerWidget({super.key, required this.totalSeconds});

  const TimerWidget.elapsed({super.key}) : totalSeconds = 0;

  @override
  ConsumerState<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ConsumerState<TimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final displaySeconds = gameState.timeDisplaySeconds;

    if (gameState.isQuestionsMode) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displaySeconds.toHms,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryBlue,
            ),
          ),
          Text(
            'elapsed',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      );
    }

    final total = widget.totalSeconds > 0 ? widget.totalSeconds : 1;
    final progress = (displaySeconds / total).clamp(0.0, 1.0);
    final timerColor = displaySeconds > total * 0.5
        ? AppConstants.success
        : displaySeconds > total * 0.25
            ? AppConstants.warning
            : AppConstants.error;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                    ),
                  ),
                  Text(
                    displaySeconds.toHms,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: timerColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
