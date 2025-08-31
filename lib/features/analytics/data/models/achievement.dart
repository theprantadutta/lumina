import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

@JsonSerializable()
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final AchievementCategory category;
  final int targetValue;
  final int currentProgress;
  final bool isUnlocked;
  final bool isNotified;
  final DateTime? unlockedAt;
  final DateTime? createdAt;
  final int tier;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final IconData? customIcon;
  final int iconCodePoint;
  final String iconFontFamily;
  final String? reward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.targetValue,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.isNotified = false,
    this.unlockedAt,
    this.createdAt,
    this.tier = 1,
    this.customIcon,
    this.iconCodePoint = 0,
    this.iconFontFamily = 'MaterialIcons',
    this.reward,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}

enum AchievementType {
  streak,
  milestone,
  frequency,
  improvement,
  exploration,
  social,
  wellness;

  String get displayName {
    switch (this) {
      case AchievementType.streak:
        return 'Streak';
      case AchievementType.milestone:
        return 'Milestone';
      case AchievementType.frequency:
        return 'Frequency';
      case AchievementType.improvement:
        return 'Improvement';
      case AchievementType.exploration:
        return 'Exploration';
      case AchievementType.social:
        return 'Social';
      case AchievementType.wellness:
        return 'Wellness';
    }
  }

  Color get color {
    switch (this) {
      case AchievementType.streak:
        return Colors.orange;
      case AchievementType.milestone:
        return Colors.purple;
      case AchievementType.frequency:
        return Colors.blue;
      case AchievementType.improvement:
        return Colors.green;
      case AchievementType.exploration:
        return Colors.teal;
      case AchievementType.social:
        return Colors.pink;
      case AchievementType.wellness:
        return Colors.indigo;
    }
  }

  IconData get icon {
    switch (this) {
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.milestone:
        return Icons.flag;
      case AchievementType.frequency:
        return Icons.repeat;
      case AchievementType.improvement:
        return Icons.trending_up;
      case AchievementType.exploration:
        return Icons.explore;
      case AchievementType.social:
        return Icons.people;
      case AchievementType.wellness:
        return Icons.spa;
    }
  }
}

enum AchievementCategory {
  moodTracking,
  journaling,
  consistency,
  wellbeing,
  insights,
  engagement;

  String get displayName {
    switch (this) {
      case AchievementCategory.moodTracking:
        return 'Mood Tracking';
      case AchievementCategory.journaling:
        return 'Journaling';
      case AchievementCategory.consistency:
        return 'Consistency';
      case AchievementCategory.wellbeing:
        return 'Well-being';
      case AchievementCategory.insights:
        return 'Insights';
      case AchievementCategory.engagement:
        return 'Engagement';
    }
  }
}

@JsonSerializable()
class UserProgress {
  final String userId;
  final List<Achievement> unlockedAchievements;
  final List<Achievement> inProgressAchievements;
  final int totalPoints;
  final int currentLevel;
  final int currentLevelProgress;
  final int nextLevelRequirement;
  final Map<AchievementCategory, int> categoryProgress;
  final DateTime? lastUpdated;

  const UserProgress({
    required this.userId,
    this.unlockedAchievements = const [],
    this.inProgressAchievements = const [],
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.currentLevelProgress = 0,
    this.nextLevelRequirement = 100,
    this.categoryProgress = const {},
    this.lastUpdated,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);

  Map<String, dynamic> toJson() => _$UserProgressToJson(this);
}

class AchievementDefinitions {
  static List<Achievement> get defaultAchievements => [
    // Mood Tracking Achievements
    Achievement(
      id: 'first_mood',
      title: 'First Steps',
      description: 'Log your first mood entry',
      type: AchievementType.milestone,
      category: AchievementCategory.moodTracking,
      targetValue: 1,
      tier: 1,
      iconCodePoint: Icons.mood.codePoint,
      reward: '+10 XP',
    ),
    Achievement(
      id: 'mood_week_streak',
      title: 'Week Warrior',
      description: 'Track your mood for 7 consecutive days',
      type: AchievementType.streak,
      category: AchievementCategory.moodTracking,
      targetValue: 7,
      tier: 2,
      iconCodePoint: Icons.local_fire_department.codePoint,
      reward: '+50 XP',
    ),
    Achievement(
      id: 'mood_month_streak',
      title: 'Month Master',
      description: 'Track your mood for 30 consecutive days',
      type: AchievementType.streak,
      category: AchievementCategory.moodTracking,
      targetValue: 30,
      tier: 4,
      iconCodePoint: Icons.local_fire_department.codePoint,
      reward: '+200 XP',
    ),
    Achievement(
      id: 'mood_100',
      title: 'Century Club',
      description: 'Log 100 mood entries',
      type: AchievementType.milestone,
      category: AchievementCategory.moodTracking,
      targetValue: 100,
      tier: 3,
      iconCodePoint: Icons.celebration.codePoint,
      reward: '+100 XP',
    ),

    // Journaling Achievements
    Achievement(
      id: 'first_journal',
      title: 'Dear Diary',
      description: 'Write your first journal entry',
      type: AchievementType.milestone,
      category: AchievementCategory.journaling,
      targetValue: 1,
      tier: 1,
      iconCodePoint: Icons.book.codePoint,
      reward: '+15 XP',
    ),
    Achievement(
      id: 'journal_week_streak',
      title: 'Weekly Writer',
      description: 'Journal for 7 consecutive days',
      type: AchievementType.streak,
      category: AchievementCategory.journaling,
      targetValue: 7,
      tier: 2,
      iconCodePoint: Icons.edit.codePoint,
      reward: '+60 XP',
    ),
    Achievement(
      id: 'long_entry',
      title: 'Storyteller',
      description: 'Write a journal entry with 500+ words',
      type: AchievementType.milestone,
      category: AchievementCategory.journaling,
      targetValue: 500,
      tier: 2,
      iconCodePoint: Icons.article.codePoint,
      reward: '+40 XP',
    ),
    Achievement(
      id: 'gratitude_master',
      title: 'Gratitude Master',
      description: 'Log 50 gratitude items',
      type: AchievementType.milestone,
      category: AchievementCategory.journaling,
      targetValue: 50,
      tier: 3,
      iconCodePoint: Icons.favorite.codePoint,
      reward: '+80 XP',
    ),

    // Consistency Achievements
    Achievement(
      id: 'daily_double',
      title: 'Daily Double',
      description: 'Log both mood and journal on the same day',
      type: AchievementType.frequency,
      category: AchievementCategory.consistency,
      targetValue: 1,
      tier: 1,
      iconCodePoint: Icons.check_circle.codePoint,
      reward: '+20 XP',
    ),
    Achievement(
      id: 'consistency_king',
      title: 'Consistency King',
      description: 'Complete daily double for 14 days',
      type: AchievementType.streak,
      category: AchievementCategory.consistency,
      targetValue: 14,
      tier: 3,
      iconCodePoint: Icons.stars.codePoint,
      reward: '+150 XP',
    ),

    // Well-being Achievements
    Achievement(
      id: 'mood_improver',
      title: 'Mood Improver',
      description: 'Increase average mood by 2 points over a week',
      type: AchievementType.improvement,
      category: AchievementCategory.wellbeing,
      targetValue: 2,
      tier: 3,
      iconCodePoint: Icons.trending_up.codePoint,
      reward: '+100 XP',
    ),
    Achievement(
      id: 'happy_week',
      title: 'Happy Week',
      description: 'Maintain mood above 7 for 7 consecutive days',
      type: AchievementType.streak,
      category: AchievementCategory.wellbeing,
      targetValue: 7,
      tier: 3,
      iconCodePoint: Icons.sentiment_very_satisfied.codePoint,
      reward: '+120 XP',
    ),

    // Exploration Achievements
    Achievement(
      id: 'template_explorer',
      title: 'Template Explorer',
      description: 'Try all 5 journal templates',
      type: AchievementType.exploration,
      category: AchievementCategory.engagement,
      targetValue: 5,
      tier: 2,
      iconCodePoint: Icons.explore.codePoint,
      reward: '+70 XP',
    ),
    Achievement(
      id: 'mood_spectrum',
      title: 'Mood Spectrum',
      description: 'Experience all 8 mood types',
      type: AchievementType.exploration,
      category: AchievementCategory.moodTracking,
      targetValue: 8,
      tier: 2,
      iconCodePoint: Icons.palette.codePoint,
      reward: '+60 XP',
    ),

    // Insights Achievements
    Achievement(
      id: 'insight_seeker',
      title: 'Insight Seeker',
      description: 'Generate your first insight',
      type: AchievementType.milestone,
      category: AchievementCategory.insights,
      targetValue: 1,
      tier: 1,
      iconCodePoint: Icons.lightbulb.codePoint,
      reward: '+25 XP',
    ),
    Achievement(
      id: 'pattern_master',
      title: 'Pattern Master',
      description: 'Unlock 10 different insights',
      type: AchievementType.milestone,
      category: AchievementCategory.insights,
      targetValue: 10,
      tier: 4,
      iconCodePoint: Icons.psychology.codePoint,
      reward: '+180 XP',
    ),
  ];

  static int getPointsForTier(int tier) {
    switch (tier) {
      case 1:
        return 25;
      case 2:
        return 50;
      case 3:
        return 100;
      case 4:
        return 200;
      case 5:
        return 400;
      default:
        return 25;
    }
  }

  static int getLevelRequirement(int level) {
    return level * 100 + (level - 1) * 50; // Exponential growth
  }
}
