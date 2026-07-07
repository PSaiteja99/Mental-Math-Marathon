import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/constants.dart';
import '../../../core/services/audio_service.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/tab_reset_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/setting_tile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playSettings();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<int>>(tabResetProvider, (prev, next) {
      if (prev != null && prev[3] != next[3]) {
        _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
    final settings = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const Center(
            child: _SettingsAnimation(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 1.2,
              ),
            ),
          ),
          SettingTile(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: 'Toggle dark theme',
            trailing: Switch.adaptive(
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(audioServiceProvider).playToggle();
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          SettingTile(
            icon: Icons.volume_up_rounded,
            title: 'Sound Effects',
            subtitle: 'Enable sound effects',
            trailing: Switch.adaptive(
              value: settings.soundEnabled,
              onChanged: (_) {
                ref.read(settingsProvider.notifier).toggleSound();
              },
            ),
          ),
          SettingTile(
            icon: Icons.music_note_rounded,
            title: 'Background Music',
            subtitle: 'Play menu and game BGM',
            trailing: Switch.adaptive(
              value: settings.musicEnabled,
              onChanged: (value) {
                ref.read(audioServiceProvider).playToggle();
                ref.read(settingsProvider.notifier).setMusicEnabled(value);
                ref.read(audioServiceProvider).setMusicEnabled(value);
              },
            ),
          ),
          SettingTile(
            icon: Icons.notifications_rounded,
            title: 'Daily Challenge Reminder',
            subtitle: 'Get reminded to play daily',
            trailing: Switch.adaptive(
              value: settings.dailyReminderEnabled,
              onChanged: (_) {
                ref.read(audioServiceProvider).playToggle();
                ref.read(settingsProvider.notifier).toggleDailyReminder();
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'GAME',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 1.2,
              ),
            ),
          ),
          _GameSettingsCard(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'ABOUT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 1.2,
              ),
            ),
          ),
          SettingTile(
            icon: Icons.info_outline_rounded,
            title: 'Version',
            subtitle: AppConstants.version,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),
          SettingTile(
            icon: Icons.star_rounded,
            title: 'Rate the App',
            subtitle: 'Share your feedback',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              ref.read(audioServiceProvider).playClick();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rate us on the Play Store!')),
              );
            },
          ),
          SettingTile(
            icon: Icons.code_rounded,
            title: 'Credits',
            subtitle: 'Built with Flutter',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              ref.read(audioServiceProvider).playClick();
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.version,
                applicationLegalese: '\u00A9 2026 Mental Maths Marathon',
                children: [
                  const Text(
                    'Built with Flutter & Riverpod.\n'
                    'Icons by Material Design.\n'
                    'Charts by fl_chart.',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'DATA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 1.2,
              ),
            ),
          ),
          SettingTile(
            icon: Icons.delete_forever_rounded,
            title: 'Clear All Data',
            subtitle: 'Reset your progress',
            iconColor: AppConstants.error,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              ref.read(audioServiceProvider).playClick();
              _showClearDataDialog(context, ref);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'Settings > Apps > Mental Math Marathon > Storage > Clear All Data',
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(audioServiceProvider).playClick();
              Navigator.of(ctx).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _GameSettingsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gs = ref.watch(gameSettingsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.timer_rounded,
                    color: AppConstants.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Game Settings',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Number of Questions',
                  style: TextStyle(fontSize: 14),
                ),
                Switch.adaptive(
                  value: gs.gameMode == 'timer',
                  onChanged: (v) {
                    ref.read(audioServiceProvider).playToggle();
                    ref
                        .read(gameSettingsProvider.notifier)
                        .setGameMode(v ? 'timer' : 'questions');
                  },
                ),
                const Text('Time Limit', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              gs.gameMode == 'questions'
                  ? 'Solve fixed number of questions, time counts up from 00:00:00'
                  : 'Solve within time limit, time counts down to 00:00:00. Unlimited questions',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            if (gs.gameMode != 'timer') ...[
              const SizedBox(height: 20),
              _SliderRow(
                label: 'Questions per Game',
                value: gs.questionCount.toDouble(),
                min: 5,
                max: 100,
                divisions: 19,
                displayValue: '${gs.questionCount}',
                onChanged: (v) {
                  ref.read(audioServiceProvider).playToggle();
                  ref
                      .read(gameSettingsProvider.notifier)
                      .setQuestionCount(v.round());
                },
              ),
            ],
            if (gs.gameMode == 'timer') ...[
              const Divider(height: 24),
              _SliderRow(
                label: 'Easy Time Limit',
                value: gs.easyTimeLimit.toDouble(),
                min: 15,
                max: 300,
                divisions: 19,
                displayValue: '${gs.easyTimeLimit}s',
                onChanged: (v) {
                  ref.read(audioServiceProvider).playToggle();
                  ref
                      .read(gameSettingsProvider.notifier)
                      .setEasyTimeLimit(v.round());
                },
              ),
              _SliderRow(
                label: 'Medium Time Limit',
                value: gs.mediumTimeLimit.toDouble(),
                min: 15,
                max: 300,
                divisions: 19,
                displayValue: '${gs.mediumTimeLimit}s',
                onChanged: (v) {
                  ref.read(audioServiceProvider).playToggle();
                  ref
                      .read(gameSettingsProvider.notifier)
                      .setMediumTimeLimit(v.round());
                },
              ),
              _SliderRow(
                label: 'Hard Time Limit',
                value: gs.hardTimeLimit.toDouble(),
                min: 15,
                max: 300,
                divisions: 19,
                displayValue: '${gs.hardTimeLimit}s',
                onChanged: (v) {
                  ref.read(audioServiceProvider).playToggle();
                  ref
                      .read(gameSettingsProvider.notifier)
                      .setHardTimeLimit(v.round());
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsAnimation extends StatelessWidget {
  const _SettingsAnimation();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark ? 'assets/images/SettingsBlack.webp' : 'assets/images/SettingsWhite.webp',
      width: 220,
      height: 220,
      fit: BoxFit.contain,
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(
              displayValue,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppConstants.primaryBlue,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppConstants.primaryBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
