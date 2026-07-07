import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_math_marathon/data/models/user_stats_model.dart';
import 'package:mental_math_marathon/providers/stats_provider.dart';

final homeStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  ref.watch(homeStatsRefreshProvider);
  final db = ref.read(localDatabaseProvider);
  return db.getUserStats();
});
