import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumina/shared/models/mood_entry.dart';
import 'package:lumina/shared/models/journal_entry.dart';

part 'analytics_models.freezed.dart';
part 'analytics_models.g.dart';

@freezed
sealed class MoodStatistics with _$MoodStatistics {
  const factory MoodStatistics({
    required int totalEntries,
    required double averageMood,
    required double highestMood,
    required double lowestMood,
    MoodType? mostFrequentMood,
    required Map<MoodType, int> moodDistribution,
    required double moodVariability,
    required int daysTracked,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
  }) = _MoodStatistics;

  factory MoodStatistics.fromJson(Map<String, Object?> json) =>
      _$MoodStatisticsFromJson(json);
}

@freezed
sealed class JournalStatistics with _$JournalStatistics {
  const factory JournalStatistics({
    required int totalEntries,
    required double averageWordsPerEntry,
    required int totalGratitudeEntries,
    required double writingFrequency, // 0.0 to 1.0
    required int currentStreak,
    required int longestStreak,
    required Map<JournalTemplate, int> templateUsage,
    required int totalWords,
    required int daysWithEntries,
  }) = _JournalStatistics;

  factory JournalStatistics.fromJson(Map<String, Object?> json) =>
      _$JournalStatisticsFromJson(json);
}

@freezed
sealed class MoodTrendPoint with _$MoodTrendPoint {
  const factory MoodTrendPoint({
    required DateTime date,
    required double averageMood,
    required int entryCount,
    MoodType? dominantMood,
  }) = _MoodTrendPoint;

  factory MoodTrendPoint.fromJson(Map<String, Object?> json) =>
      _$MoodTrendPointFromJson(json);
}

// UserProgress is already defined in achievement.dart, so we won't redefine it here

enum TrendPeriod {
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case TrendPeriod.daily:
        return 'Daily';
      case TrendPeriod.weekly:
        return 'Weekly';
      case TrendPeriod.monthly:
        return 'Monthly';
    }
  }
}