import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_math_marathon/data/models/achievement_model.dart';
import '../providers/achievements_provider.dart';

class AchievementPopupLayer extends ConsumerWidget {
  const AchievementPopupLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyUnlocked = ref.watch(recentlyUnlockedProvider);
    if (recentlyUnlocked.isEmpty) return const SizedBox.shrink();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final a in recentlyUnlocked)
            _DelayedPopup(
              key: ValueKey(a.id),
              index: recentlyUnlocked.indexOf(a),
              achievement: a,
              onDismiss: () => ref.read(recentlyUnlockedProvider.notifier).dismissAchievement(a.id),
            ),
        ],
      ),
    );
  }
}

class _DelayedPopup extends StatefulWidget {
  final int index;
  final AchievementModel achievement;
  final VoidCallback onDismiss;

  const _DelayedPopup({
    required this.index,
    required this.achievement,
    required this.onDismiss, required ValueKey<String> key,
  });

  @override
  State<_DelayedPopup> createState() => _DelayedPopupState();
}

class _DelayedPopupState extends State<_DelayedPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) {
        setState(() => _ready = true);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: Transform.translate(
              offset: Offset((_animation.value - 1) * 300, 0),
              child: child,
            ),
          );
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Text(widget.achievement.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Achievement Unlocked!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.achievement.title,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: widget.onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
