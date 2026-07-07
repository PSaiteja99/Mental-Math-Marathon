import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_math_marathon/app/constants.dart';
import 'package:mental_math_marathon/core/services/audio_service.dart';
import 'package:mental_math_marathon/domain/entities/user_stats.dart';

class QuickStats extends ConsumerWidget {
  final UserStats stats;

  const QuickStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void playSound() => ref.read(audioServiceProvider).playProgress();
    final cards = [
      _StatCard(
        label: 'Total Questions',
        value: '${stats.totalQuestions}',
        icon: Icons.calculate_rounded,
        color: AppConstants.error,
        gradientColors: const [Color(0xFFB71C1C), Color(0xFFC62828)],
        onTap: playSound,
      ),
      _StatCard(
        label: 'Best CPH',
        value: '${stats.bestCph}',
        icon: Icons.speed_rounded,
        color: AppConstants.primaryBlue,
        gradientColors: const [Color(0xFF1A237E), Color(0xFF283593)],
        onTap: playSound,
      ),
      _StatCard(
        label: 'Best Streak',
        value: '${stats.bestStreak}',
        icon: Icons.local_fire_department_rounded,
        color: AppConstants.warning,
        gradientColors: const [Color(0xFFE65100), Color(0xFFF57F17)],
        onTap: playSound,
      ),
      _StatCard(
        label: 'Level',
        value: '${stats.currentLevel}',
        icon: Icons.auto_awesome,
        color: AppConstants.success,
        gradientColors: const [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        onTap: playSound,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        children: cards,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isDark
                  ? [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)]
                  : gradientColors.map((c) => c.withValues(alpha: 0.08)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
