import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_math_marathon/app/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final maxSize = constraints.maxWidth * 0.6;
                final size = maxSize.clamp(100.0, 200.0);
                return ClipOval(
                  child: Image.asset(
                    'assets/images/App_Logo.webp',
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Mental Math Marathon',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
