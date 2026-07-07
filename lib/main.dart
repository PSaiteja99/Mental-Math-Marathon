import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'core/services/crazy_games_sdk_service.dart';
import 'providers/stats_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final prefs = await SharedPreferences.getInstance();
    await NotificationService().init();
    runApp(_buildApp(prefs));
  } catch (e) {
    debugPrint('Init error: $e');
    final prefs = await SharedPreferences.getInstance();
    runApp(_buildApp(prefs));
  }
}

Widget _buildApp(SharedPreferences prefs) {
  final sdk = CrazyGamesSdkService.instance;
  sdk.init();
  sdk.gameLoadingStart();

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MentalMathsMarathonApp(),
  );
}
