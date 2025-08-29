import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    required String displayName,
    String? photoURL,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(UserPreferences()) UserPreferences preferences,
    @Default(UserStats()) UserStats stats,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(true) bool enableNotifications,
    @Default(true) bool enableHapticFeedback,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default('en') String languageCode,
    @Default(true) bool enableInsights,
    @Default(false) bool enableSocialFeatures,
    @Default(TimeOfDay(hour: 9, minute: 0)) TimeOfDay moodReminderTime,
    @Default([]) List<String> selectedMoodFactors,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    @Default(0) int totalMoodEntries,
    @Default(0) int totalJournalEntries,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0.0) double averageMood,
    DateTime? lastEntryDate,
    @Default([]) List<String> achievements,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
}

enum ThemeMode {
  light,
  dark,
  system,
}

@freezed
class TimeOfDay with _$TimeOfDay {
  const factory TimeOfDay({
    required int hour,
    required int minute,
  }) = _TimeOfDay;

  factory TimeOfDay.fromJson(Map<String, dynamic> json) =>
      _$TimeOfDayFromJson(json);
}