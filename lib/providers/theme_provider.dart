import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/preferences_datasource.dart';
import 'stats_provider.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(preferencesProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final PreferencesDataSource _prefs;

  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    _load();
  }

  void _load() {
    state = _prefs.darkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setDarkMode(mode == ThemeMode.dark);
  }
}
