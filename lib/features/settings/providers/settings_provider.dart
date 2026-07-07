import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/datasources/preferences_datasource.dart';
import '../../../providers/stats_provider.dart';

class SettingsState {
  final bool soundEnabled;
  final bool dailyReminderEnabled;
  final bool musicEnabled;

  const SettingsState({
    this.soundEnabled = true,
    this.dailyReminderEnabled = false,
    this.musicEnabled = true,
  });

  SettingsState copyWith({
    bool? soundEnabled,
    bool? dailyReminderEnabled,
    bool? musicEnabled,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier(
      ref.watch(preferencesProvider),
      ref.watch(notificationServiceProvider),
    );
  },
);

class SettingsNotifier extends StateNotifier<SettingsState> {
  final PreferencesDataSource _prefs;
  final NotificationService _notificationService;

  SettingsNotifier(this._prefs, this._notificationService)
    : super(const SettingsState()) {
    _load();
  }

  void _load() {
    state = SettingsState(
      soundEnabled: _prefs.soundEnabled,
      dailyReminderEnabled: _prefs.dailyReminderEnabled,
      musicEnabled: _prefs.musicEnabled,
    );
  }

  Future<void> toggleSound() async {
    final newValue = !state.soundEnabled;
    state = state.copyWith(soundEnabled: newValue);
    await _prefs.setSoundEnabled(newValue);
  }

  Future<void> toggleMusic() async {
    final newValue = !state.musicEnabled;
    state = state.copyWith(musicEnabled: newValue);
    await _prefs.setMusicEnabled(newValue);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    state = state.copyWith(musicEnabled: enabled);
    await _prefs.setMusicEnabled(enabled);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _prefs.setSoundEnabled(enabled);
  }

  Future<void> toggleDailyReminder() async {
    final newValue = !state.dailyReminderEnabled;
    state = state.copyWith(dailyReminderEnabled: newValue);
    await _prefs.setDailyReminderEnabled(newValue);
    if (newValue) {
      await _notificationService.scheduleDailyReminder();
    } else {
      await _notificationService.cancelDailyReminder();
    }
  }

  Future<void> clearAllData() async {
    await _prefs.clearAll();
    state = const SettingsState();
  }
}

// Game settings provider
class GameSettings {
  final int questionCount;
  final int easyTimeLimit;
  final int mediumTimeLimit;
  final int hardTimeLimit;
  final String gameMode;

  const GameSettings({
    this.questionCount = 25,
    this.easyTimeLimit = 60,
    this.mediumTimeLimit = 90,
    this.hardTimeLimit = 120,
    this.gameMode = 'timer',
  });

  GameSettings copyWith({
    int? questionCount,
    int? easyTimeLimit,
    int? mediumTimeLimit,
    int? hardTimeLimit,
    String? gameMode,
  }) {
    return GameSettings(
      questionCount: questionCount ?? this.questionCount,
      easyTimeLimit: easyTimeLimit ?? this.easyTimeLimit,
      mediumTimeLimit: mediumTimeLimit ?? this.mediumTimeLimit,
      hardTimeLimit: hardTimeLimit ?? this.hardTimeLimit,
      gameMode: gameMode ?? this.gameMode,
    );
  }
}

final gameSettingsProvider =
    StateNotifierProvider<GameSettingsNotifier, GameSettings>((ref) {
      return GameSettingsNotifier(ref.watch(preferencesProvider));
    });

class GameSettingsNotifier extends StateNotifier<GameSettings> {
  final PreferencesDataSource _prefs;

  GameSettingsNotifier(this._prefs) : super(const GameSettings()) {
    _load();
  }

  void _load() {
    state = GameSettings(
      questionCount: _prefs.questionCount,
      easyTimeLimit: _prefs.easyTimeLimit,
      mediumTimeLimit: _prefs.mediumTimeLimit,
      hardTimeLimit: _prefs.hardTimeLimit,
      gameMode: _prefs.gameMode,
    );
  }

  Future<void> setQuestionCount(int value) async {
    state = state.copyWith(questionCount: value);
    await _prefs.setQuestionCount(value);
  }

  Future<void> setEasyTimeLimit(int value) async {
    state = state.copyWith(easyTimeLimit: value);
    await _prefs.setEasyTimeLimit(value);
  }

  Future<void> setMediumTimeLimit(int value) async {
    state = state.copyWith(mediumTimeLimit: value);
    await _prefs.setMediumTimeLimit(value);
  }

  Future<void> setHardTimeLimit(int value) async {
    state = state.copyWith(hardTimeLimit: value);
    await _prefs.setHardTimeLimit(value);
  }

  Future<void> setGameMode(String mode) async {
    state = state.copyWith(gameMode: mode);
    await _prefs.setGameMode(mode);
  }
}
