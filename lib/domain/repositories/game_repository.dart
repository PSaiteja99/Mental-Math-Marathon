import 'package:mental_math_marathon/data/models/session_model.dart';

abstract class GameRepository {
  Future<void> saveSession(SessionModel session);
  Map<String, int> getHighScores();
  Future<void> saveHighScore(String mode, int score);
}
