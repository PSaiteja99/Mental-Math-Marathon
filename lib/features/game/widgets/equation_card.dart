import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_math_marathon/app/constants.dart';
import 'package:mental_math_marathon/features/game/providers/question_provider.dart';

class EquationCard extends ConsumerWidget {
  final bool? lastCorrect;
  final int? hintDigit;

  const EquationCard({super.key, this.lastCorrect, this.hintDigit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = ref.watch(currentQuestionProvider);
    final overlayColor = lastCorrect != null
        ? (lastCorrect! ? AppConstants.success : AppConstants.error)
            .withValues(alpha: 0.5)
        : Colors.transparent;

    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        return Card(
          margin: isLandscape
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
              : const EdgeInsets.all(24),
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: Stack(
              key: ValueKey('${question?.equation ?? 'empty'}_$hintDigit'),
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isLandscape ? 8 : 48,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isLandscape ? 8 : 48,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: overlayColor,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isLandscape ? 8 : 28,
                    horizontal: 24,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          question?.equation ?? 'Please Quit',
                          textAlign: TextAlign.center,
                          style: isLandscape
                              ? Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                  )
                              : Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                  ),
                        ),
                        if (hintDigit != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppConstants.warning.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lightbulb_rounded,
                                  size: 16,
                                  color: AppConstants.warning,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Hint: contains digit $hintDigit',
                                  style: const TextStyle(
                                    color: AppConstants.warning,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
