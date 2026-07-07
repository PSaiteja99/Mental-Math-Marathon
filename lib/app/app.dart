import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/audio_service.dart';
import '../features/achievements/widgets/achievement_popup.dart';
import '../features/settings/providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import 'constants.dart';
import 'routes.dart';
import 'theme.dart';

/// Syncs audio service enabled state with settings
final _audioSyncProvider = Provider<void>((ref) {
  final settings = ref.watch(settingsProvider);
  final audio = ref.watch(audioServiceProvider);
  audio.setEnabled(settings.soundEnabled);
  audio.setMusicEnabled(settings.musicEnabled);
});

class MentalMathsMarathonApp extends ConsumerStatefulWidget {
  const MentalMathsMarathonApp({super.key});

  @override
  ConsumerState<MentalMathsMarathonApp> createState() => _MentalMathsMarathonAppState();
}

class _MentalMathsMarathonAppState extends ConsumerState<MentalMathsMarathonApp>
    with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      audio.pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      audio.resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(_audioSyncProvider);
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const AchievementPopupLayer(),
          ],
        );
      },
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
