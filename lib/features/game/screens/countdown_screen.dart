import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_math_marathon/app/constants.dart';
import 'package:mental_math_marathon/core/services/audio_service.dart';

class CountdownScreen extends ConsumerStatefulWidget {
  const CountdownScreen({super.key});

  @override
  ConsumerState<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends ConsumerState<CountdownScreen>
    with SingleTickerProviderStateMixin {
  int _count = 3;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _startCountdown();
  }

  void _startCountdown() {
    _showNumber();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_count > 1) {
        setState(() => _count--);
        _showNumber();
      } else {
        timer.cancel();
        context.go('/game');
      }
    });
  }

  void _showNumber() {
    _animController.reset();
    _animController.forward();
    ref.read(audioServiceProvider).playCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            );
          },
          child: Text(
            _count > 0 ? '$_count' : 'GO!',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 120,
              fontWeight: FontWeight.bold,
              color: _count > 0
                  ? Theme.of(context).colorScheme.primary
                  : AppConstants.success,
            ),
          ),
        ),
      ),
    );
  }
}
