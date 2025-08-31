import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_user.g.dart';

@JsonSerializable()
class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserPreferences preferences;
  final UserStats stats;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.updatedAt,
    this.preferences = const UserPreferences(),
    this.stats = const UserStats(),
  });

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}

@JsonSerializable()
class UserPreferences {
  final bool enableNotifications;
  final bool enableHapticFeedback;
  final ThemeMode themeMode;
  final String languageCode;
  final bool enableInsights;
  final bool enableSocialFeatures;
  final CustomTimeOfDay moodReminderTime;
  final List<String> selectedMoodFactors;

  const UserPreferences({
    this.enableNotifications = true,
    this.enableHapticFeedback = true,
    this.themeMode = ThemeMode.system,
    this.languageCode = 'en',
    this.enableInsights = true,
    this.enableSocialFeatures = false,
    this.moodReminderTime = const CustomTimeOfDay(hour: 9, minute: 0),
    this.selectedMoodFactors = const [],
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}

@JsonSerializable()
class UserStats {
  final int totalMoodEntries;
  final int totalJournalEntries;
  final int currentStreak;
  final int longestStreak;
  final double averageMood;
  final DateTime? lastEntryDate;
  final List<String> achievements;

  const UserStats({
    this.totalMoodEntries = 0,
    this.totalJournalEntries = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.averageMood = 0.0,
    this.lastEntryDate,
    this.achievements = const [],
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

@JsonSerializable()
class CustomTimeOfDay {
  final int hour;
  final int minute;

  const CustomTimeOfDay({required this.hour, required this.minute});

  factory CustomTimeOfDay.fromJson(Map<String, dynamic> json) =>
      _$CustomTimeOfDayFromJson(json);

  Map<String, dynamic> toJson() => _$CustomTimeOfDayToJson(this);
}
