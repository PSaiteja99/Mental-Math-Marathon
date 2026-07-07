import 'package:mental_math_marathon/data/datasources/local_database.dart';
import 'package:mental_math_marathon/data/models/session_model.dart';
import 'package:mental_math_marathon/domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final LocalDatabase _db;

  GameRepositoryImpl(this._db);

  @override
  Future<void> saveSession(SessionModel session) async {
    await _db.addSession(session);
  }

  @override
  Map<String, int> getHighScores() {
    return _db.getHighScores();
  }

  @override
  Future<void> saveHighScore(String mode, int score) async {
    await _db.saveHighScore(mode, score);
  }
}
