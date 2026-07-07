enum AchievementType {
  calculations,
  cph,
  streak,
  accuracy,
  level,
  special,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int threshold;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.threshold,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
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

class AchievementDefinitions {
  static final List<Achievement> all = [
    // Calculations
    Achievement(
      id: 'first_calc',
      title: 'First Step',
      description: 'Solve your first calculation',
      type: AchievementType.calculations,
      threshold: 1,
      icon: '\u{1F3AF}',
    ),
    Achievement(
      id: 'calc_100',
      title: 'Century',
      description: 'Solve 100 calculations',
      type: AchievementType.calculations,
      threshold: 100,
      icon: '\u{1F4AF}',
    ),
    Achievement(
      id: 'calc_500',
      title: 'Half Grand',
      description: 'Solve 500 calculations',
      type: AchievementType.calculations,
      threshold: 500,
      icon: '\u{1F525}',
    ),
    Achievement(
      id: 'calc_1000',
      title: 'Grandmaster',
      description: 'Solve 1000 calculations',
      type: AchievementType.calculations,
      threshold: 1000,
      icon: '\u{1F451}',
    ),
    Achievement(
      id: 'calc_10000',
      title: 'Legendary',
      description: 'Solve 10000 calculations',
      type: AchievementType.calculations,
      threshold: 10000,
      icon: '\u{1F31F}',
    ),
    // Streak
    Achievement(
      id: 'streak_5',
      title: 'Streak Starter',
      description: 'Get a streak of 5',
      type: AchievementType.streak,
      threshold: 5,
      icon: '\u26A1',
    ),
    Achievement(
      id: 'streak_10',
      title: 'On Fire',
      description: 'Get a 10 streak',
      type: AchievementType.streak,
      threshold: 10,
      icon: '\u{1F525}',
    ),
    Achievement(
      id: 'streak_25',
      title: 'Unstoppable',
      description: 'Get a 25 streak',
      type: AchievementType.streak,
      threshold: 25,
      icon: '\u{1F4AA}',
    ),
    Achievement(
      id: 'streak_50',
      title: 'Invincible',
      description: 'Get a 50 streak',
      type: AchievementType.streak,
      threshold: 50,
      icon: '\u{1F6E1}\uFE0F',
    ),
    Achievement(
      id: 'streak_100',
      title: 'Perfect',
      description: 'Get a 100 streak',
      type: AchievementType.streak,
      threshold: 100,
      icon: '\u{1F3C6}',
    ),
    // CPH
    Achievement(
      id: 'cph_100',
      title: 'Getting Started',
      description: 'Reach 100 CPH',
      type: AchievementType.cph,
      threshold: 100,
      icon: '\u{1F680}',
    ),
    Achievement(
      id: 'cph_500',
      title: 'Speedster',
      description: 'Reach 500 CPH',
      type: AchievementType.cph,
      threshold: 500,
      icon: '\u26A1',
    ),
    Achievement(
      id: 'cph_1000',
      title: 'Lightning',
      description: 'Reach 1000 CPH',
      type: AchievementType.cph,
      threshold: 1000,
      icon: '\u{1F4A8}',
    ),
    // Level
    Achievement(
      id: 'level_5',
      title: 'Apprentice',
      description: 'Reach level 5',
      type: AchievementType.level,
      threshold: 5,
      icon: '\u{1F4D6}',
    ),
    Achievement(
      id: 'level_10',
      title: 'Calculator',
      description: 'Reach level 10',
      type: AchievementType.level,
      threshold: 10,
      icon: '\u{1F9EE}',
    ),
    Achievement(
      id: 'level_25',
      title: 'Mathematician',
      description: 'Reach level 25',
      type: AchievementType.level,
      threshold: 25,
      icon: '\u{1F4D0}',
    ),
    Achievement(
      id: 'level_50',
      title: 'Grandmaster',
      description: 'Reach level 50',
      type: AchievementType.level,
      threshold: 50,
      icon: '\u{1F451}',
    ),
    // XP
    Achievement(
      id: 'total_xp_1000',
      title: 'Thousand Club',
      description: 'Earn 1000 total XP',
      type: AchievementType.calculations,
      threshold: 1000,
      icon: '\u{1F31F}',
    ),
    Achievement(
      id: 'total_xp_10000',
      title: 'XP Grinder',
      description: 'Earn 10000 total XP',
      type: AchievementType.calculations,
      threshold: 10000,
      icon: '\u{1F48E}',
    ),
    Achievement(
      id: 'total_xp_100000',
      title: 'XP Legend',
      description: 'Earn 100000 total XP',
      type: AchievementType.calculations,
      threshold: 100000,
      icon: '\u{1F984}',
    ),
    // Accuracy
    Achievement(
      id: 'accuracy_100',
      title: 'Perfect Game',
      description: 'Achieve 100% accuracy in a session',
      type: AchievementType.accuracy,
      threshold: 100,
      icon: '\u{1F3AF}',
    ),
  ];
}
