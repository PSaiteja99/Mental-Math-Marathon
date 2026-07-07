import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Mental Maths Marathon';
  static const String tagline = 'Train your brain. Race against time. Master mental math.';
  static const String version = '1.0.0';

  // Colors
  static const Color primaryBlue = Color(0xFF0000FF);
  static const Color secondaryNightBlue = Color(0xFF003366);
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFD50000);
  static const Color backgroundLight = Color.fromARGB(255, 255, 255, 255);
  static const Color backgroundDark = Color.fromARGB(255, 0, 0, 0);

  // Game
  static const int xpPerCorrect = 10;
  static const int xpPerStreakBonus = 5;

  // Storage Keys
  static const String keyTotalQuestions = 'total_questions';
  static const String keyCorrectAnswers = 'correct_answers';
  static const String keyWrongAnswers = 'wrong_answers';
  static const String keyBestCph = 'best_cph';
  static const String keyBestStreak = 'best_streak';
  static const String keyTotalXp = 'total_xp';
  static const String keyCurrentLevel = 'current_level';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyDarkMode = 'dark_mode';
  static const String keyHighScores = 'high_scores';
  static const String keyAchievements = 'achievements';
  static const String keySessions = 'sessions';
  static const String keyDailyDate = 'daily_date';
  static const String keyDailyDone = 'daily_done';
  static const String keyQuestionCount = 'question_count';
  static const String keyEasyTimeLimit = 'easy_time_limit';
  static const String keyMediumTimeLimit = 'medium_time_limit';
  static const String keyHardTimeLimit = 'hard_time_limit';
  static const String keyGameMode = 'game_mode';
  static const String keyMusicEnabled = 'music_enabled';

  // XP thresholds for levels
  static const List<int> levelThresholds = [
    0, 100, 250, 500, 1000, 2000, 3500, 5000, 7500, 10000,
    15000, 20000, 30000, 40000, 50000, 75000, 100000, 150000, 200000, 300000,
    400000, 500000, 600000, 700000, 800000, 900000, 1000000, 1200000, 1400000, 1600000,
    1800000, 2000000, 2200000, 2400000, 2600000, 2800000, 3000000, 3200000, 3400000, 3600000,
    3800000, 4000000, 4200000, 4400000, 4600000, 4800000, 5000000, 5200000, 5400000, 5600000,
  ];

  static const List<String> levelTitles = [
    'Beginner', 'Novice', 'Apprentice', 'Learner', 'Student',
    'Thinker', 'Solver', 'Calculator', 'Number Cruncher', 'Math Whiz',
    'Arithmetic Ace', 'Speed Demon', 'Quick Mind', 'Brain Booster', 'Math Maven',
    'Equation Expert', 'Mental Mathematician', 'Number Ninja', 'Math Champion', 'Grandmaster',
    'Legend', 'Mythic', 'Godlike', 'Transcendent', 'Infinite',
    'Eternal', 'Cosmic', 'Quantum', 'Singularity', 'Omniscient',
    'Master of Numbers', 'Lord of Logic', 'Emperor of Equations', 'Titan of Thought', 'Genius',
    'Prodigy', 'Virtuoso', 'Phenomenon', 'Prodigious', 'Extraordinary',
    'Incredible', 'Magnificent', 'Splendid', 'Marvelous', 'Astounding',
    'Stupendous', 'Miraculous', 'Phenomenal', 'Transcendent Being', 'Absolute Legend',
  ];
}
