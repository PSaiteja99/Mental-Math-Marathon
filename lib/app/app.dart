import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/audio_service.dart';
import '../core/services/crazy_games_sdk_service.dart';
import '../core/widgets/loading_screen.dart';
import '../features/achievements/widgets/achievement_popup.dart';
import '../features/settings/providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import 'constants.dart';
import 'routes.dart';
import 'theme.dart';

final _audioSyncProvider = Provider<void>((ref) {
  final settings = ref.watch(settingsProvider);
  final audio = ref.watch(audioServiceProvider);
  audio.setEnabled(settings.soundEnabled);
  audio.setMusicEnabled(settings.musicEnabled);
});

class MentalMathsMarathonApp extends ConsumerStatefulWidget {
  const MentalMathsMarathonApp({super.key});

  @override
  ConsumerState<MentalMathsMarathonApp> createState() =>
      _MentalMathsMarathonAppState();
}

class _MentalMathsMarathonAppState
    extends ConsumerState<MentalMathsMarathonApp> with WidgetsBindingObserver {
  bool _loadingDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audio = ref.read(audioServiceProvider);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      audio.pauseMusic();
      CrazyGamesSdkService.instance.gameplayStop();
    } else if (state == AppLifecycleState.resumed) {
      audio.resumeMusic();
    }
  }

  void _onLoadingComplete() {
    setState(() => _loadingDone = true);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(_audioSyncProvider);
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      builder: (context, child) {
        final app = Stack(
          children: [
            child!,
            const AchievementPopupLayer(),
          ],
        );
        if (!_loadingDone) {
          return LoadingScreen(
            onComplete: _onLoadingComplete,
            child: app,
          );
        }
        return app;
      },
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
