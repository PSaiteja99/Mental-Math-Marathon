import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mental_math_marathon/app/constants.dart';
import 'package:mental_math_marathon/core/services/crazy_games_sdk_service.dart';

class LoadingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final Widget child;

  const LoadingScreen({
    super.key,
    required this.onComplete,
    required this.child,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    _simulateLoading();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _simulateLoading() async {
    CrazyGamesSdkService.instance.gameLoadingStart();

    final steps = [
      0.05, 0.10, 0.18, 0.25, 0.30, 0.38, 0.42, 0.48, 0.52, 0.58,
      0.62, 0.68, 0.72, 0.78, 0.82, 0.85, 0.88, 0.92, 0.95, 0.98, 1.0,
    ];

    for (final step in steps) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() => _progress = step);
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    CrazyGamesSdkService.instance.gameLoadingStop();
    setState(() => _done = true);
    await _fadeController.reverse();
    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;

    return Scaffold(
      backgroundColor: AppConstants.backgroundDark,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/App_Logo.webp',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.tagline,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 240,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(
                      AppConstants.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
