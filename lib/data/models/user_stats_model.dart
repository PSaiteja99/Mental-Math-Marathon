import 'package:mental_math_marathon/domain/entities/user_stats.dart';

class UserStatsModel extends UserStats {
  const UserStatsModel({
    super.totalQuestions,
    super.correctAnswers,
    super.wrongAnswers,
    super.bestCph,
    super.bestStreak,
    super.totalXp,
    super.currentLevel,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      wrongAnswers: json['wrongAnswers'] as int? ?? 0,
      bestCph: json['bestCph'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
      currentLevel: json['currentLevel'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'bestCph': bestCph,
      'bestStreak': bestStreak,
      'totalXp': totalXp,
      'currentLevel': currentLevel,
    };
  }

  @override
  UserStatsModel copyWith({
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    int? bestCph,
    int? bestStreak,
    int? totalXp,
    int? currentLevel,
  }) {
    return UserStatsModel(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      bestCph: bestCph ?? this.bestCph,
      bestStreak: bestStreak ?? this.bestStreak,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }

  factory UserStatsModel.initial() {
    return const UserStatsModel(
      totalQuestions: 0,
      correctAnswers: 0,
      wrongAnswers: 0,
      bestCph: 0,
      bestStreak: 0,
      totalXp: 0,
      currentLevel: 1,
    );
  }

  factory UserStatsModel.fromEntity(UserStats entity) {
    return UserStatsModel(
      totalQuestions: entity.totalQuestions,
      correctAnswers: entity.correctAnswers,
      wrongAnswers: entity.wrongAnswers,
      bestCph: entity.bestCph,
      bestStreak: entity.bestStreak,
      totalXp: entity.totalXp,
      currentLevel: entity.currentLevel,
    );
  }
}
