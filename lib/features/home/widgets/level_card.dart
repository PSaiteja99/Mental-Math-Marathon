import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mental_math_marathon/app/constants.dart';

class LevelCard extends StatefulWidget {
  final int level;
  final int totalXp;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.totalXp,
    this.onTap,
  });

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _glowAnimation;

  int get _baseXp {
    final idx = (widget.level - 1).clamp(0, AppConstants.levelThresholds.length - 1);
    return AppConstants.levelThresholds[idx];
  }

  int get _targetXp {
    final idx = widget.level.clamp(0, AppConstants.levelThresholds.length);
    if (idx >= AppConstants.levelThresholds.length) return _baseXp;
    return AppConstants.levelThresholds[idx];
  }

  double get _progress {
    final range = _targetXp - _baseXp;
    if (range == 0) return 1.0;
    return ((widget.totalXp - _baseXp) / range).clamp(0.0, 1.0);
  }

  String get _title {
    final idx = (widget.level - 1).clamp(0, AppConstants.levelTitles.length - 1);
    return AppConstants.levelTitles[idx];
  }

  bool get _isMax => widget.level >= AppConstants.levelThresholds.length;

  String _formatXp(int xp) {
    if (xp >= 1000000) return '${(xp / 1000000).toStringAsFixed(1)}M';
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}K';
    return xp.toString();
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _glowAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppConstants.primaryBlue.withValues(alpha: 0.25),
                    AppConstants.secondaryNightBlue.withValues(alpha: 0.45),
                  ]
                : [
                    AppConstants.primaryBlue.withValues(alpha: 0.07),
                    AppConstants.secondaryNightBlue.withValues(alpha: 0.12),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, _) => _LevelBadge(
                level: widget.level,
                glowValue: _glowAnimation.value,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: AppConstants.warning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _GradientProgressBar(
                    progress: _progress,
                    isDark: isDark,
                    shimmerController: _animController,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _isMax
                            ? 'MAX LEVEL'
                            : '${_formatXp(widget.totalXp)} / ${_formatXp(_targetXp)} XP',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (!_isMax)
                        Text(
                          '${(_progress * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppConstants.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final double glowValue;

  const _LevelBadge({
    required this.level,
    required this.glowValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppConstants.primaryBlue, AppConstants.secondaryNightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryBlue.withValues(alpha: 0.3 * glowValue),
            blurRadius: 8 + 8 * glowValue,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'LV',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Text(
            '$level',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientProgressBar extends StatelessWidget {
  final double progress;
  final bool isDark;
  final AnimationController shimmerController;

  const _GradientProgressBar({
    required this.progress,
    required this.isDark,
    required this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, fillValue, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final fillWidth = constraints.maxWidth * fillValue;
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 14,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    if (fillWidth > 1)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: fillWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00E676), Color(0xFF2979FF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2979FF).withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: shimmerController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _ShimmerPainter(
                                  shimmerOffset: shimmerController.value,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double shimmerOffset;

  const _ShimmerPainter({required this.shimmerOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.6),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: [
          (shimmerOffset - 0.3).clamp(0.0, 1.0),
          shimmerOffset.clamp(0.0, 1.0),
          (shimmerOffset + 0.3).clamp(0.0, 1.0),
        ],
        transform: const GradientRotation(-math.pi / 6),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return oldDelegate.shimmerOffset != shimmerOffset;
  }
}
