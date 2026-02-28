import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lumina/features/analytics/data/services/insights_service.dart';
import 'package:lumina/features/analytics/data/services/achievement_service.dart';
import 'package:lumina/features/analytics/data/models/achievement.dart';
import 'package:lumina/features/mood/data/services/mood_service.dart';
import 'package:lumina/features/journal/data/services/journal_service.dart';
import 'package:lumina/shared/models/mood_entry.dart';
import 'package:lumina/shared/models/journal_entry.dart';

part 'analytics_providers.g.dart';

// Service providers (renamed to avoid conflict with mood_providers.dart)
@Riverpod(keepAlive: true)
MoodService analyticsMoodService(Ref ref) => MoodService();

@Riverpod(keepAlive: true)
JournalService journalService(Ref ref) => JournalService();

@Riverpod(keepAlive: true)
InsightsService insightsService(Ref ref) {
  final moodService = ref.watch(analyticsMoodServiceProvider);
  final journalService = ref.watch(journalServiceProvider);
  return InsightsService(moodService, journalService);
}

@Riverpod(keepAlive: true)
AchievementService achievementService(Ref ref) => AchievementService();

// Data providers
@riverpod
Future<UserProgress> userProgress(Ref ref, String userId) async {
  final achievementService = ref.watch(achievementServiceProvider);
  return await achievementService.getUserProgress(userId);
}

@riverpod
Future<MoodStatistics> analyticsMoodStatistics(Ref ref, AnalyticsRequest request) async {
  final moodService = ref.watch(analyticsMoodServiceProvider);
  return await moodService.getMoodStatistics(
    userId: request.userId,
    startDate: request.startDate,
    endDate: request.endDate,
  );
}

@riverpod
Future<JournalStatistics> journalStatistics(Ref ref, AnalyticsRequest request) async {
  final journalService = ref.watch(journalServiceProvider);
  return await journalService.getJournalStatistics(
    userId: request.userId,
    startDate: request.startDate,
    endDate: request.endDate,
  );
}

@riverpod
Future<List<MoodTrendPoint>> analyticsMoodTrends(Ref ref, MoodTrendRequest request) async {
  final moodService = ref.watch(analyticsMoodServiceProvider);
  return await moodService.getMoodTrends(
    userId: request.userId,
    startDate: request.startDate,
    endDate: request.endDate,
    period: request.period,
  );
}

@riverpod
Future<List<Insight>> insights(Ref ref, AnalyticsRequest request) async {
  final insightsService = ref.watch(insightsServiceProvider);
  return await insightsService.generateInsights(
    userId: request.userId,
    startDate: request.startDate,
    endDate: request.endDate,
  );
}

@riverpod
Future<List<Achievement>> newAchievements(Ref ref, AchievementCheckRequest request) async {
  final achievementService = ref.watch(achievementServiceProvider);
  return await achievementService.checkForNewAchievements(
    userId: request.userId,
    recentMoodEntries: request.recentMoodEntries,
    recentJournalEntries: request.recentJournalEntries,
    additionalData: request.additionalData,
  );
}

// State providers for analytics dashboard
@riverpod
class SelectedPeriod extends _$SelectedPeriod {
  @override
  TimePeriod build() => TimePeriod.lastMonth;
  void update(TimePeriod period) => state = period;
}

@riverpod
class CurrentAnalyticsTab extends _$CurrentAnalyticsTab {
  @override
  int build() => 0;
  void set(int value) => state = value;
}

// Computed providers
@riverpod
AnalyticsRequest currentAnalyticsRequest(Ref ref) {
  const userId = 'current-user'; // TODO: Get from auth
  final period = ref.watch(selectedPeriodProvider);
  final dates = _getPeriodDates(period);

  return AnalyticsRequest(
    userId: userId,
    startDate: dates.start,
    endDate: dates.end,
  );
}

@riverpod
MoodTrendRequest currentMoodTrendRequest(Ref ref) {
  const userId = 'current-user'; // TODO: Get from auth
  final period = ref.watch(selectedPeriodProvider);
  final dates = _getPeriodDates(period);

  return MoodTrendRequest(
    userId: userId,
    startDate: dates.start,
    endDate: dates.end,
    period: TrendPeriod.daily,
  );
}

@riverpod
Future<DashboardData> dashboardData(Ref ref) async {
  final analyticsRequest = ref.watch(currentAnalyticsRequestProvider);
  final trendRequest = ref.watch(currentMoodTrendRequestProvider);

  // Load all data concurrently
  final results = await Future.wait([
    ref.watch(analyticsMoodStatisticsProvider(analyticsRequest).future),
    ref.watch(journalStatisticsProvider(analyticsRequest).future),
    ref.watch(analyticsMoodTrendsProvider(trendRequest).future),
    ref.watch(insightsProvider(analyticsRequest).future),
    ref.watch(userProgressProvider(analyticsRequest.userId).future),
  ]);

  return DashboardData(
    moodStats: results[0] as MoodStatistics,
    journalStats: results[1] as JournalStatistics,
    trendData: results[2] as List<MoodTrendPoint>,
    insights: results[3] as List<Insight>,
    userProgress: results[4] as UserProgress,
  );
}

// Watch providers for real-time updates
@riverpod
Stream<List<MoodEntry>> moodEntriesStream(Ref ref, String userId) {
  final moodService = ref.watch(analyticsMoodServiceProvider);
  return moodService.getMoodEntriesStream(userId: userId);
}

@riverpod
Stream<List<JournalEntry>> journalEntriesStream(Ref ref, String userId) {
  final journalService = ref.watch(journalServiceProvider);
  return journalService.getJournalEntriesStream(userId: userId);
}

// Helper function to get period dates
({DateTime start, DateTime end}) _getPeriodDates(TimePeriod period) {
  final now = DateTime.now();
  switch (period) {
    case TimePeriod.lastWeek:
      return (start: now.subtract(const Duration(days: 7)), end: now);
    case TimePeriod.lastMonth:
      return (start: now.subtract(const Duration(days: 30)), end: now);
    case TimePeriod.lastThreeMonths:
      return (start: now.subtract(const Duration(days: 90)), end: now);
    case TimePeriod.lastYear:
      return (start: now.subtract(const Duration(days: 365)), end: now);
  }
}

// Request classes
class AnalyticsRequest {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const AnalyticsRequest({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsRequest &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => userId.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}

class MoodTrendRequest extends AnalyticsRequest {
  final TrendPeriod period;

  const MoodTrendRequest({
    required super.userId,
    required super.startDate,
    required super.endDate,
    required this.period,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is MoodTrendRequest &&
          runtimeType == other.runtimeType &&
          period == other.period;

  @override
  int get hashCode => super.hashCode ^ period.hashCode;
}

class AchievementCheckRequest {
  final String userId;
  final List<MoodEntry>? recentMoodEntries;
  final List<JournalEntry>? recentJournalEntries;
  final Map<String, dynamic>? additionalData;

  const AchievementCheckRequest({
    required this.userId,
    this.recentMoodEntries,
    this.recentJournalEntries,
    this.additionalData,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementCheckRequest &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

class DashboardData {
  final MoodStatistics moodStats;
  final JournalStatistics journalStats;
  final List<MoodTrendPoint> trendData;
  final List<Insight> insights;
  final UserProgress userProgress;

  const DashboardData({
    required this.moodStats,
    required this.journalStats,
    required this.trendData,
    required this.insights,
    required this.userProgress,
  });
}

// Enum for time periods
enum TimePeriod {
  lastWeek,
  lastMonth,
  lastThreeMonths,
  lastYear;

  String get displayName {
    switch (this) {
      case TimePeriod.lastWeek:
        return '7D';
      case TimePeriod.lastMonth:
        return '30D';
      case TimePeriod.lastThreeMonths:
        return '3M';
      case TimePeriod.lastYear:
        return '1Y';
    }
  }
}
