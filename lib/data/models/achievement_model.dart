import 'package:mental_math_marathon/domain/entities/achievement.dart';

class AchievementModel extends Achievement {
  const AchievementModel({
    required String id,
    required String title,
    required String description,
    required AchievementType type,
    required int threshold,
    required String icon,
    bool isUnlocked = false,
    DateTime? unlockedAt,
  }) : super(
          id: id,
          title: title,
          description: description,
          type: type,
          threshold: threshold,
          icon: icon,
          isUnlocked: isUnlocked,
          unlockedAt: unlockedAt,
        );

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: AchievementType.values.byName(json['type'] as String),
      threshold: json['threshold'] as int,
      icon: json['icon'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'threshold': threshold,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory AchievementModel.fromEntity(Achievement entity) {
    return AchievementModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      type: entity.type,
      threshold: entity.threshold,
      icon: entity.icon,
      isUnlocked: entity.isUnlocked,
      unlockedAt: entity.unlockedAt,
    );
  }

  @override
  AchievementModel copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      type: type,
      threshold: threshold,
      icon: icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
