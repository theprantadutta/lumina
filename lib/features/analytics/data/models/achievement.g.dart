// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$AchievementTypeEnumMap, json['type']),
  category: $enumDecode(_$AchievementCategoryEnumMap, json['category']),
  targetValue: (json['targetValue'] as num).toInt(),
  currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
  isUnlocked: json['isUnlocked'] as bool? ?? false,
  isNotified: json['isNotified'] as bool? ?? false,
  unlockedAt: json['unlockedAt'] == null
      ? null
      : DateTime.parse(json['unlockedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  tier: (json['tier'] as num?)?.toInt() ?? 1,
  iconCodePoint: (json['iconCodePoint'] as num?)?.toInt() ?? 0,
  iconFontFamily: json['iconFontFamily'] as String? ?? 'MaterialIcons',
  reward: json['reward'] as String?,
);

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'category': _$AchievementCategoryEnumMap[instance.category]!,
      'targetValue': instance.targetValue,
      'currentProgress': instance.currentProgress,
      'isUnlocked': instance.isUnlocked,
      'isNotified': instance.isNotified,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'tier': instance.tier,
      'iconCodePoint': instance.iconCodePoint,
      'iconFontFamily': instance.iconFontFamily,
      'reward': instance.reward,
    };

const _$AchievementTypeEnumMap = {
  AchievementType.streak: 'streak',
  AchievementType.milestone: 'milestone',
  AchievementType.frequency: 'frequency',
  AchievementType.improvement: 'improvement',
  AchievementType.exploration: 'exploration',
  AchievementType.social: 'social',
  AchievementType.wellness: 'wellness',
};

const _$AchievementCategoryEnumMap = {
  AchievementCategory.moodTracking: 'moodTracking',
  AchievementCategory.journaling: 'journaling',
  AchievementCategory.consistency: 'consistency',
  AchievementCategory.wellbeing: 'wellbeing',
  AchievementCategory.insights: 'insights',
  AchievementCategory.engagement: 'engagement',
};

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) => UserProgress(
  userId: json['userId'] as String,
  unlockedAchievements:
      (json['unlockedAchievements'] as List<dynamic>?)
          ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  inProgressAchievements:
      (json['inProgressAchievements'] as List<dynamic>?)
          ?.map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
  currentLevel: (json['currentLevel'] as num?)?.toInt() ?? 1,
  currentLevelProgress: (json['currentLevelProgress'] as num?)?.toInt() ?? 0,
  nextLevelRequirement: (json['nextLevelRequirement'] as num?)?.toInt() ?? 100,
  categoryProgress:
      (json['categoryProgress'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$AchievementCategoryEnumMap, k),
          (e as num).toInt(),
        ),
      ) ??
      const {},
  lastUpdated: json['lastUpdated'] == null
      ? null
      : DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$UserProgressToJson(UserProgress instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'unlockedAchievements': instance.unlockedAchievements,
      'inProgressAchievements': instance.inProgressAchievements,
      'totalPoints': instance.totalPoints,
      'currentLevel': instance.currentLevel,
      'currentLevelProgress': instance.currentLevelProgress,
      'nextLevelRequirement': instance.nextLevelRequirement,
      'categoryProgress': instance.categoryProgress.map(
        (k, e) => MapEntry(_$AchievementCategoryEnumMap[k]!, e),
      ),
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
