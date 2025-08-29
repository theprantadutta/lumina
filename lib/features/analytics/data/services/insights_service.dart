import 'package:flutter/material.dart';
import 'package:lumina/features/mood/data/services/mood_service.dart';
import 'package:lumina/features/journal/data/services/journal_service.dart';
import 'package:lumina/shared/models/mood_entry.dart';
import 'package:lumina/shared/models/journal_entry.dart';

class InsightsService {
  final MoodService _moodService;
  final JournalService _journalService;

  InsightsService(this._moodService, this._journalService);

  Future<List<Insight>> generateInsights({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final insights = <Insight>[];
    
    try {
      // Get mood and journal data
      final moodEntries = await _moodService.getMoodEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      
      final journalEntries = await _journalService.getJournalEntries(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Generate various insights
      insights.addAll(await _generateMoodInsights(moodEntries));
      insights.addAll(await _generateJournalInsights(journalEntries));
      insights.addAll(await _generatePatternInsights(moodEntries, journalEntries));
      insights.addAll(await _generateStreakInsights(moodEntries, journalEntries));
      insights.addAll(await _generateCorrelationInsights(moodEntries));

      // Sort by priority and relevance
      insights.sort((a, b) => b.priority.compareTo(a.priority));
      
      return insights.take(10).toList(); // Return top 10 insights
    } catch (e) {
      throw Exception('Failed to generate insights: $e');
    }
  }

  Future<List<Insight>> _generateMoodInsights(List<MoodEntry> entries) async {
    final insights = <Insight>[];
    
    if (entries.isEmpty) return insights;

    // Average mood insight
    final averageMood = entries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.mood.baseIntensity,
    ) / entries.length;

    if (averageMood >= 7) {
      insights.add(Insight(
        id: 'mood_positive',
        title: 'Great Mood Trend! 🌟',
        description: 'Your average mood has been ${averageMood.toStringAsFixed(1)}/10. Keep up the positive momentum!',
        type: InsightType.positive,
        priority: 8,
        actionable: true,
        suggestion: 'Continue with activities that boost your mood, like the ones you\'ve been doing.',
      ));
    } else if (averageMood <= 4) {
      insights.add(Insight(
        id: 'mood_concern',
        title: 'Mood Support Needed',
        description: 'Your mood has been averaging ${averageMood.toStringAsFixed(1)}/10 recently.',
        type: InsightType.warning,
        priority: 9,
        actionable: true,
        suggestion: 'Consider talking to someone you trust or trying mood-boosting activities.',
      ));
    }

    // Mood consistency insight
    final moodVariability = _calculateMoodVariability(entries);
    if (moodVariability < 2.0) {
      insights.add(Insight(
        id: 'mood_stable',
        title: 'Stable Mood Pattern',
        description: 'Your mood has been quite consistent lately, which is a sign of emotional balance.',
        type: InsightType.neutral,
        priority: 5,
      ));
    } else if (moodVariability > 4.0) {
      insights.add(Insight(
        id: 'mood_variable',
        title: 'Fluctuating Moods',
        description: 'Your mood has been quite variable recently. This might indicate stress or life changes.',
        type: InsightType.warning,
        priority: 7,
        actionable: true,
        suggestion: 'Try to identify patterns or triggers that might be causing mood swings.',
      ));
    }

    // Most common mood insight
    final moodCounts = <MoodType, int>{};
    for (final entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }
    
    final mostCommonMood = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b);
        
    if (mostCommonMood.value > entries.length * 0.4) {
      insights.add(Insight(
        id: 'mood_dominant',
        title: 'Dominant Mood: ${mostCommonMood.key.displayName}',
        description: 'You\'ve felt ${mostCommonMood.key.displayName.toLowerCase()} ${((mostCommonMood.value / entries.length) * 100).toInt()}% of the time.',
        type: mostCommonMood.key.baseIntensity >= 6 ? InsightType.positive : InsightType.neutral,
        priority: 6,
      ));
    }

    return insights;
  }

  Future<List<Insight>> _generateJournalInsights(List<JournalEntry> entries) async {
    final insights = <Insight>[];
    
    if (entries.isEmpty) return insights;

    // Writing frequency insight
    final daysWithEntries = entries.map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day)).toSet().length;
    final totalDays = DateTime.now().difference(entries.last.timestamp).inDays + 1;
    final writingFrequency = daysWithEntries / totalDays;

    if (writingFrequency >= 0.8) {
      insights.add(Insight(
        id: 'journal_frequent',
        title: 'Excellent Journaling Habit! ✍️',
        description: 'You\'ve been journaling ${(writingFrequency * 100).toInt()}% of days. Great consistency!',
        type: InsightType.positive,
        priority: 7,
      ));
    } else if (writingFrequency <= 0.3) {
      insights.add(Insight(
        id: 'journal_infrequent',
        title: 'Room for More Journaling',
        description: 'You\'ve journaled ${(writingFrequency * 100).toInt()}% of days. More frequent writing could help.',
        type: InsightType.neutral,
        priority: 4,
        actionable: true,
        suggestion: 'Try setting a daily reminder to write for just 5 minutes.',
      ));
    }

    // Word count insights
    final totalWords = entries.fold<int>(0, (sum, entry) => sum + entry.content.split(' ').length);
    final averageWords = totalWords / entries.length;

    if (averageWords >= 200) {
      insights.add(Insight(
        id: 'journal_detailed',
        title: 'Detailed Reflections',
        description: 'Your journal entries average ${averageWords.toInt()} words. You\'re great at self-reflection!',
        type: InsightType.positive,
        priority: 5,
      ));
    }

    // Gratitude insights
    final gratitudeCount = entries.fold<int>(0, (sum, entry) => sum + entry.gratitudeList.length);
    if (gratitudeCount > 0) {
      insights.add(Insight(
        id: 'gratitude_practice',
        title: 'Gratitude Practice Active',
        description: 'You\'ve noted $gratitudeCount things you\'re grateful for. Gratitude boosts wellbeing!',
        type: InsightType.positive,
        priority: 6,
      ));
    }

    // Template usage insight
    final templateCounts = <JournalTemplate, int>{};
    for (final entry in entries) {
      templateCounts[entry.template] = (templateCounts[entry.template] ?? 0) + 1;
    }
    
    final mostUsedTemplate = templateCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b);
        
    insights.add(Insight(
      id: 'template_preference',
      title: 'Favorite Template: ${mostUsedTemplate.key.displayName}',
      description: 'You prefer ${mostUsedTemplate.key.displayName.toLowerCase()} journaling (${mostUsedTemplate.value} entries).',
      type: InsightType.neutral,
      priority: 3,
    ));

    return insights;
  }

  Future<List<Insight>> _generatePatternInsights(List<MoodEntry> moodEntries, List<JournalEntry> journalEntries) async {
    final insights = <Insight>[];

    // Day of week patterns
    final moodByDayOfWeek = <int, List<double>>{};
    for (final entry in moodEntries) {
      final dayOfWeek = entry.timestamp.weekday;
      moodByDayOfWeek.putIfAbsent(dayOfWeek, () => []).add(entry.mood.baseIntensity.toDouble());
    }

    if (moodByDayOfWeek.isNotEmpty) {
      final avgMoodByDay = moodByDayOfWeek.map((day, moods) {
        final avg = moods.reduce((a, b) => a + b) / moods.length;
        return MapEntry(day, avg);
      });

      final bestDay = avgMoodByDay.entries.reduce((a, b) => a.value > b.value ? a : b);
      final worstDay = avgMoodByDay.entries.reduce((a, b) => a.value < b.value ? a : b);

      if ((bestDay.value - worstDay.value) > 2.0) {
        final dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        insights.add(Insight(
          id: 'day_pattern',
          title: 'Weekly Mood Pattern',
          description: 'Your mood is typically best on ${dayNames[bestDay.key]} and lowest on ${dayNames[worstDay.key]}.',
          type: InsightType.neutral,
          priority: 6,
          actionable: true,
          suggestion: 'Plan enjoyable activities for ${dayNames[worstDay.key]} to boost your mood.',
        ));
      }
    }

    // Time-based patterns
    final moodByHour = <int, List<double>>{};
    for (final entry in moodEntries) {
      final hour = entry.timestamp.hour;
      moodByHour.putIfAbsent(hour, () => []).add(entry.mood.baseIntensity.toDouble());
    }

    return insights;
  }

  Future<List<Insight>> _generateStreakInsights(List<MoodEntry> moodEntries, List<JournalEntry> journalEntries) async {
    final insights = <Insight>[];

    // Journal streak
    final journalStreak = _calculateJournalStreak(journalEntries);
    if (journalStreak >= 7) {
      insights.add(Insight(
        id: 'journal_streak',
        title: '🔥 ${journalStreak}-Day Journal Streak!',
        description: 'You\'ve been journaling consistently for $journalStreak days. Amazing dedication!',
        type: InsightType.positive,
        priority: 8,
      ));
    } else if (journalStreak >= 3) {
      insights.add(Insight(
        id: 'journal_streak_building',
        title: 'Building a Journal Streak',
        description: 'You\'re on a $journalStreak-day journaling streak. Keep it going!',
        type: InsightType.positive,
        priority: 6,
      ));
    }

    // Mood tracking streak
    final moodStreak = _calculateMoodStreak(moodEntries);
    if (moodStreak >= 14) {
      insights.add(Insight(
        id: 'mood_streak',
        title: '📊 ${moodStreak}-Day Mood Tracking!',
        description: 'You\'ve tracked your mood for $moodStreak consecutive days!',
        type: InsightType.positive,
        priority: 7,
      ));
    }

    return insights;
  }

  Future<List<Insight>> _generateCorrelationInsights(List<MoodEntry> entries) async {
    final insights = <Insight>[];

    // Factor correlation analysis
    final factorMoodCorrelations = <String, List<double>>{};
    
    for (final entry in entries) {
      for (final factor in entry.factors) {
        factorMoodCorrelations.putIfAbsent(factor, () => []).add(entry.mood.baseIntensity.toDouble());
      }
    }

    // Find factors that correlate with positive moods
    final positiveFactors = <String>[];
    final negativeFactors = <String>[];

    factorMoodCorrelations.forEach((factor, moods) {
      if (moods.length >= 3) { // Need at least 3 data points
        final avgMood = moods.reduce((a, b) => a + b) / moods.length;
        if (avgMood >= 7.0) {
          positiveFactors.add(factor);
        } else if (avgMood <= 4.0) {
          negativeFactors.add(factor);
        }
      }
    });

    if (positiveFactors.isNotEmpty) {
      insights.add(Insight(
        id: 'positive_factors',
        title: 'Mood Boosters Identified',
        description: 'These activities seem to boost your mood: ${positiveFactors.take(3).join(", ")}',
        type: InsightType.positive,
        priority: 8,
        actionable: true,
        suggestion: 'Try to incorporate these activities more often in your routine.',
      ));
    }

    if (negativeFactors.isNotEmpty) {
      insights.add(Insight(
        id: 'negative_factors',
        title: 'Potential Mood Downers',
        description: 'These factors might be affecting your mood negatively: ${negativeFactors.take(2).join(", ")}',
        type: InsightType.warning,
        priority: 7,
        actionable: true,
        suggestion: 'Consider ways to minimize or cope better with these factors.',
      ));
    }

    return insights;
  }

  double _calculateMoodVariability(List<MoodEntry> entries) {
    if (entries.length < 2) return 0.0;
    
    final mean = entries.fold<double>(0.0, (sum, entry) => sum + entry.mood.baseIntensity) / entries.length;
    final variance = entries.fold<double>(0.0, (sum, entry) {
      final diff = entry.mood.baseIntensity - mean;
      return sum + (diff * diff);
    }) / entries.length;
    
    return variance; // Return variance as a measure of variability
  }

  int _calculateJournalStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;

    final sortedEntries = List<JournalEntry>.from(entries)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 0;
    DateTime? lastDate;

    for (final entry in sortedEntries) {
      final entryDate = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);

      if (lastDate == null) {
        lastDate = entryDate;
        streak = 1;
      } else {
        final daysDifference = lastDate.difference(entryDate).inDays;
        if (daysDifference == 1) {
          streak++;
          lastDate = entryDate;
        } else if (daysDifference > 1) {
          break;
        }
      }
    }

    return streak;
  }

  int _calculateMoodStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;

    final sortedEntries = List<MoodEntry>.from(entries)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 0;
    DateTime? lastDate;

    for (final entry in sortedEntries) {
      final entryDate = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);

      if (lastDate == null) {
        lastDate = entryDate;
        streak = 1;
      } else {
        final daysDifference = lastDate.difference(entryDate).inDays;
        if (daysDifference == 1) {
          streak++;
          lastDate = entryDate;
        } else if (daysDifference > 1) {
          break;
        }
      }
    }

    return streak;
  }
}

class Insight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final int priority; // 1-10, 10 being highest priority
  final bool actionable;
  final String? suggestion;
  final DateTime createdAt;

  Insight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    this.actionable = false,
    this.suggestion,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

enum InsightType {
  positive,
  neutral,
  warning,
  achievement,
}

extension InsightTypeExtension on InsightType {
  String get displayName {
    switch (this) {
      case InsightType.positive:
        return 'Great News';
      case InsightType.neutral:
        return 'Insight';
      case InsightType.warning:
        return 'Attention';
      case InsightType.achievement:
        return 'Achievement';
    }
  }

  Color get color {
    switch (this) {
      case InsightType.positive:
        return const Color(0xFF10B981);
      case InsightType.neutral:
        return const Color(0xFF6B7280);
      case InsightType.warning:
        return const Color(0xFFF59E0B);
      case InsightType.achievement:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData get icon {
    switch (this) {
      case InsightType.positive:
        return Icons.celebration_outlined;
      case InsightType.neutral:
        return Icons.lightbulb_outline;
      case InsightType.warning:
        return Icons.warning_amber_outlined;
      case InsightType.achievement:
        return Icons.emoji_events_outlined;
    }
  }
}