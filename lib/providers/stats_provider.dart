import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/local_database.dart';
import '../data/datasources/preferences_datasource.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main.dart ProviderScope');
});

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase(ref.watch(sharedPreferencesProvider));
});

final preferencesProvider = Provider<PreferencesDataSource>((ref) {
  return PreferencesDataSource(ref.watch(sharedPreferencesProvider));
});

final homeStatsRefreshProvider = StateProvider<int>((ref) => 0);