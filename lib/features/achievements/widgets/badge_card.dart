import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants.dart';
import '../../../core/services/audio_service.dart';
import '../../../data/models/achievement_model.dart';

class BadgeCard extends ConsumerWidget {
  final AchievementModel achievement;

  const BadgeCard({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: () {
        final audio = ref.read(audioServiceProvider);
        if (isUnlocked) {
          audio.playCompletedAchievement();
        } else {
          audio.playPendingAchievement();
        }
      },
      child: Container(
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppConstants.primaryBlue.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? AppConstants.primaryBlue.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Opacity(
                opacity: isUnlocked ? 1.0 : 0.35,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppConstants.primaryBlue.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ),
              if (!isUnlocked)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              achievement.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isUnlocked ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ),
          if (isUnlocked && achievement.unlockedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatDate(achievement.unlockedAt!),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[400],
                ),
              ),
            ),
        ],
      ),
    ),
  );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}';
  }
}
