import 'package:shared_preferences/shared_preferences.dart';

import 'package:mental_math_marathon/app/constants.dart';

class PreferencesDataSource {
  final SharedPreferences _prefs;

  PreferencesDataSource(this._prefs);

  // ---------------------------------------------------------------------------
  // Sound
  // ---------------------------------------------------------------------------

  bool get soundEnabled => _prefs.getBool(AppConstants.keySoundEnabled) ?? true;

  Future<void> setSoundEnabled(bool value) async {
    await _prefs.setBool(AppConstants.keySoundEnabled, value);
  }

  bool get musicEnabled => _prefs.getBool(AppConstants.keyMusicEnabled) ?? true;

  Future<void> setMusicEnabled(bool value) async {
    await _prefs.setBool(AppConstants.keyMusicEnabled, value);
  }

  // ---------------------------------------------------------------------------
  // Dark Mode
  // ---------------------------------------------------------------------------

  bool get darkMode => _prefs.getBool(AppConstants.keyDarkMode) ?? true;

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(AppConstants.keyDarkMode, value);
  }

  // ---------------------------------------------------------------------------
  // Daily Challenge
  // ---------------------------------------------------------------------------

  String? get dailyDate => _prefs.getString(AppConstants.keyDailyDate);

  Future<void> setDailyDate(String value) async {
    await _prefs.setString(AppConstants.keyDailyDate, value);
  }

  bool get dailyDone => _prefs.getBool(AppConstants.keyDailyDone) ?? false;

  Future<void> setDailyDone(bool value) async {
    await _prefs.setBool(AppConstants.keyDailyDone, value);
  }

  // ---------------------------------------------------------------------------
  // Game Settings
  // ---------------------------------------------------------------------------

  int get questionCount => _prefs.getInt(AppConstants.keyQuestionCount) ?? 25;

  Future<void> setQuestionCount(int value) async {
    await _prefs.setInt(AppConstants.keyQuestionCount, value);
  }

  int get easyTimeLimit => _prefs.getInt(AppConstants.keyEasyTimeLimit) ?? 60;

  Future<void> setEasyTimeLimit(int value) async {
    await _prefs.setInt(AppConstants.keyEasyTimeLimit, value);
  }

  int get mediumTimeLimit => _prefs.getInt(AppConstants.keyMediumTimeLimit) ?? 90;

  Future<void> setMediumTimeLimit(int value) async {
    await _prefs.setInt(AppConstants.keyMediumTimeLimit, value);
  }

  int get hardTimeLimit => _prefs.getInt(AppConstants.keyHardTimeLimit) ?? 120;

  Future<void> setHardTimeLimit(int value) async {
    await _prefs.setInt(AppConstants.keyHardTimeLimit, value);
  }

  String get gameMode => _prefs.getString(AppConstants.keyGameMode) ?? 'timer';

  Future<void> setGameMode(String value) async {
    await _prefs.setString(AppConstants.keyGameMode, value);
  }

  bool get dailyReminderEnabled => _prefs.getBool('daily_reminder') ?? false;

  Future<void> setDailyReminderEnabled(bool value) async {
    await _prefs.setBool('daily_reminder', value);
  }

  // ---------------------------------------------------------------------------
  // Clear All
  // ---------------------------------------------------------------------------

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}