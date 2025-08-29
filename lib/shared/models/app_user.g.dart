// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      preferences: json['preferences'] == null
          ? const UserPreferences()
          : UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>,
            ),
      stats: json['stats'] == null
          ? const UserStats()
          : UserStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoURL': instance.photoURL,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'preferences': instance.preferences,
      'stats': instance.stats,
    };

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
  Map<String, dynamic> json,
) => _$UserPreferencesImpl(
  enableNotifications: json['enableNotifications'] as bool? ?? true,
  enableHapticFeedback: json['enableHapticFeedback'] as bool? ?? true,
  themeMode:
      $enumDecodeNullable(_$ThemeModeEnumMap, json['themeMode']) ??
      ThemeMode.system,
  languageCode: json['languageCode'] as String? ?? 'en',
  enableInsights: json['enableInsights'] as bool? ?? true,
  enableSocialFeatures: json['enableSocialFeatures'] as bool? ?? false,
  moodReminderTime: json['moodReminderTime'] == null
      ? const TimeOfDay(hour: 9, minute: 0)
      : TimeOfDay.fromJson(json['moodReminderTime'] as Map<String, dynamic>),
  selectedMoodFactors:
      (json['selectedMoodFactors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$UserPreferencesImplToJson(
  _$UserPreferencesImpl instance,
) => <String, dynamic>{
  'enableNotifications': instance.enableNotifications,
  'enableHapticFeedback': instance.enableHapticFeedback,
  'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
  'languageCode': instance.languageCode,
  'enableInsights': instance.enableInsights,
  'enableSocialFeatures': instance.enableSocialFeatures,
  'moodReminderTime': instance.moodReminderTime,
  'selectedMoodFactors': instance.selectedMoodFactors,
};

const _$ThemeModeEnumMap = {
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
  ThemeMode.system: 'system',
};

_$UserStatsImpl _$$UserStatsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsImpl(
      totalMoodEntries: (json['totalMoodEntries'] as num?)?.toInt() ?? 0,
      totalJournalEntries: (json['totalJournalEntries'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      averageMood: (json['averageMood'] as num?)?.toDouble() ?? 0.0,
      lastEntryDate: json['lastEntryDate'] == null
          ? null
          : DateTime.parse(json['lastEntryDate'] as String),
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$UserStatsImplToJson(_$UserStatsImpl instance) =>
    <String, dynamic>{
      'totalMoodEntries': instance.totalMoodEntries,
      'totalJournalEntries': instance.totalJournalEntries,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'averageMood': instance.averageMood,
      'lastEntryDate': instance.lastEntryDate?.toIso8601String(),
      'achievements': instance.achievements,
    };

_$TimeOfDayImpl _$$TimeOfDayImplFromJson(Map<String, dynamic> json) =>
    _$TimeOfDayImpl(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
    );

Map<String, dynamic> _$$TimeOfDayImplToJson(_$TimeOfDayImpl instance) =>
    <String, dynamic>{'hour': instance.hour, 'minute': instance.minute};
