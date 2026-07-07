import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mental_math_marathon/data/datasources/preferences_datasource.dart';
import 'package:mental_math_marathon/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'ThemeModeNotifier defaults to dark mode when no preference is saved',
    () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();

      final prefs = PreferencesDataSource(sp);
      final notifier = ThemeModeNotifier(prefs);

      expect(notifier.state, ThemeMode.dark);
    },
  );
}