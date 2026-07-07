import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:mental_math_marathon/app/constants.dart';
import 'package:mental_math_marathon/data/models/achievement_model.dart';
import 'package:mental_math_marathon/data/models/session_model.dart';
import 'package:mental_math_marathon/data/models/user_stats_model.dart';

class LocalDatabase {
  final SharedPreferences _prefs;

  LocalDatabase(this._prefs);

  // ---------------------------------------------------------------------------
  // UserStats
  // ---------------------------------------------------------------------------

  UserStatsModel getUserStats() {
    return UserStatsModel(
      totalQuestions: _prefs.getInt(AppConstants.keyTotalQuestions) ?? 0,
      correctAnswers: _prefs.getInt(AppConstants.keyCorrectAnswers) ?? 0,
      wrongAnswers: _prefs.getInt(AppConstants.keyWrongAnswers) ?? 0,
      bestCph: _prefs.getInt(AppConstants.keyBestCph) ?? 0,
      bestStreak: _prefs.getInt(AppConstants.keyBestStreak) ?? 0,
      totalXp: _prefs.getInt(AppConstants.keyTotalXp) ?? 0,
      currentLevel: _prefs.getInt(AppConstants.keyCurrentLevel) ?? 1,
    );
  }

  Future<void> saveUserStats(UserStatsModel stats) async {
    await _prefs.setInt(AppConstants.keyTotalQuestions, stats.totalQuestions);
    await _prefs.setInt(AppConstants.keyCorrectAnswers, stats.correctAnswers);
    await _prefs.setInt(AppConstants.keyWrongAnswers, stats.wrongAnswers);
    await _prefs.setInt(AppConstants.keyBestCph, stats.bestCph);
    await _prefs.setInt(AppConstants.keyBestStreak, stats.bestStreak);
    await _prefs.setInt(AppConstants.keyTotalXp, stats.totalXp);
    await _prefs.setInt(AppConstants.keyCurrentLevel, stats.currentLevel);
  }

  // ---------------------------------------------------------------------------
  // Sessions
  // ---------------------------------------------------------------------------

  List<SessionModel> getSessions() {
    final raw = _prefs.getString(AppConstants.keySessions);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSessions(List<SessionModel> sessions) async {
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _prefs.setString(AppConstants.keySessions, encoded);
  }

  Future<void> addSession(SessionModel session) async {
    final sessions = getSessions();
    sessions.add(session);
    await saveSessions(sessions);
  }

  // ---------------------------------------------------------------------------
  // Achievements
  // ---------------------------------------------------------------------------

  List<AchievementModel> getAchievements() {
    final raw = _prefs.getString(AppConstants.keyAchievements);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAchievements(List<AchievementModel> achievements) async {
    final encoded =
        jsonEncode(achievements.map((a) => a.toJson()).toList());
    await _prefs.setString(AppConstants.keyAchievements, encoded);
  }

  Future<void> addAchievement(AchievementModel achievement) async {
    final achievements = getAchievements();
    achievements.add(achievement);
    await saveAchievements(achievements);
  }

  // ---------------------------------------------------------------------------
  // High Scores
  // ---------------------------------------------------------------------------

  Map<String, int> getHighScores() {
    final raw = _prefs.getString(AppConstants.keyHighScores);
    if (raw == null || raw.isEmpty) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  Future<void> saveHighScores(Map<String, int> scores) async {
    final encoded = jsonEncode(scores);
    await _prefs.setString(AppConstants.keyHighScores, encoded);
  }

  Future<void> saveHighScore(String mode, int score) async {
    final scores = getHighScores();
    final current = scores[mode] ?? 0;
    if (score > current) {
      scores[mode] = score;
      await saveHighScores(scores);
    }
  }
}