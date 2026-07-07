import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_math_marathon/app/constants.dart';
import 'package:mental_math_marathon/core/services/daily_reward_service.dart';
import 'package:mental_math_marathon/core/services/ad_service.dart';
import 'package:mental_math_marathon/core/services/audio_service.dart';

class DailyRewardDialog extends ConsumerStatefulWidget {
  final VoidCallback? onClaimed;

  const DailyRewardDialog({super.key, this.onClaimed});

  static Future<void> showIfAvailable(BuildContext context, WidgetRef ref, {VoidCallback? onClaimed}) async {
    final service = DailyRewardService.instance;
    final canClaim = await service.canClaimToday();
    if (canClaim && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DailyRewardDialog(onClaimed: onClaimed),
      );
    }
  }

  @override
  ConsumerState<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends ConsumerState<DailyRewardDialog>
    with SingleTickerProviderStateMixin {
  DailyReward? _reward;
  bool _loading = false;
  bool _claimed = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _claim({bool doubled = false}) async {
    setState(() => _loading = true);
    ref.read(audioServiceProvider).playLevelUp();
    final reward = await DailyRewardService.instance.claimReward(doubled: doubled);
    if (mounted) {
      setState(() {
        _reward = reward;
        _claimed = true;
        _loading = false;
      });
      widget.onClaimed?.call();
    }
  }

  Future<void> _claimDoubled() async {
    final shown = await AdService.instance.showRewardedAd();
    if (shown) {
      _claim(doubled: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _claimed,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      );
    }

    if (_reward != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppConstants.warning, AppConstants.primaryBlue],
              ),
            ),
            child: const Icon(Icons.celebration_rounded, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('Daily Reward Claimed!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('+${_reward!.xp} XP',
            style: const TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: AppConstants.warning),
          ),
          if (_reward!.doubled)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('DOUBLED!', style: TextStyle(
                color: AppConstants.warning, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          const SizedBox(height: 8),
          Text('Day ${_reward!.day} • ${_reward!.label}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text('Streak: ${_reward!.streak} day${_reward!.streak == 1 ? '' : 's'}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Awesome!'),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppConstants.warning, AppConstants.primaryBlue],
            ),
          ),
          child: const Icon(Icons.card_giftcard_rounded, size: 32, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text('Daily Reward',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Come back every day for bonus XP!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _claim(),
            icon: const Icon(Icons.touch_app_rounded),
            label: const Text('Claim Reward'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _claimDoubled,
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text('Double Reward (Watch Ad)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.warning,
              side: BorderSide(color: AppConstants.warning.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Maybe Later'),
        ),
      ],
    );
  }
}
