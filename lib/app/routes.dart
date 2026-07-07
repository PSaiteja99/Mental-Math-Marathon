import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_math_marathon/core/services/audio_service.dart';
import 'package:mental_math_marathon/models/game_config.dart';
import 'package:mental_math_marathon/models/session_result.dart';
import 'package:mental_math_marathon/providers/tab_reset_provider.dart';
import 'package:mental_math_marathon/features/home/screens/home_screen.dart';
import 'package:mental_math_marathon/features/splash/screens/splash_screen.dart';
import 'package:mental_math_marathon/features/game/screens/game_screen.dart';
import 'package:mental_math_marathon/features/game/screens/countdown_screen.dart';
import 'package:mental_math_marathon/features/game/screens/pause_screen.dart';
import 'package:mental_math_marathon/features/game/screens/result_screen.dart';
import 'package:mental_math_marathon/features/statistics/screens/statistics_screen.dart';
import 'package:mental_math_marathon/features/achievements/screens/achievements_screen.dart';
import 'package:mental_math_marathon/features/settings/screens/settings_screen.dart';
import 'package:mental_math_marathon/features/leaderboard/screens/leaderboard_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/game',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => GameScreen(config: state.extra as GameConfig?),
      ),
      GoRoute(
        path: '/game/countdown',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CountdownScreen(),
      ),
      GoRoute(
        path: '/game/pause',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          fullscreenDialog: true,
          child: const PauseScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/game/result',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ResultScreen(result: state.extra as SessionResult?),
      ),
      GoRoute(
        path: '/leaderboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/achievements',
                builder: (context, state) => const AchievementsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.read(audioServiceProvider);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              audio.playHome();
            case 1:
              audio.playStatistics();
            case 2:
              audio.playAchievements();
            case 3:
              audio.playSettings();
          }
          ref.read(tabResetProvider.notifier).reset(index);
          navigationShell.goBranch(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded), label: 'Achievements'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
