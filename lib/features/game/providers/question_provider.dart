import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_math_marathon/domain/entities/question.dart';
import 'package:mental_math_marathon/features/game/providers/game_provider.dart';

final currentQuestionProvider = Provider.autoDispose<Question?>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.currentQuestion;
});
