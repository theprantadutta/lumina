import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/core/theme/app_gradients.dart';
import 'package:lumina/features/analytics/presentation/widgets/mood_trend_chart.dart';
import 'package:lumina/features/analytics/presentation/widgets/animated_stat_card.dart';
import 'package:lumina/features/analytics/presentation/widgets/correlation_chart.dart';
import 'package:lumina/features/analytics/presentation/widgets/period_comparison_chart.dart';
import 'package:lumina/features/analytics/presentation/widgets/achievement_card.dart';
import 'package:lumina/features/analytics/data/services/insights_service.dart';
import 'package:lumina/features/analytics/data/services/achievement_service.dart';
import 'package:lumina/features/analytics/data/models/achievement.dart';
import 'package:lumina/features/mood/data/services/mood_service.dart';
import 'package:lumina/features/journal/data/services/journal_service.dart';
import 'package:lumina/shared/models/mood_entry.dart';
import 'package:lumina/shared/widgets/glass_morphism_card.dart';

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

class BeautifulAnalyticsScreen extends ConsumerStatefulWidget {
  const BeautifulAnalyticsScreen({super.key});

  @override
  ConsumerState<BeautifulAnalyticsScreen> createState() => _BeautifulAnalyticsScreenState();
}

class _BeautifulAnalyticsScreenState extends ConsumerState<BeautifulAnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _statsController;
  late AnimationController _refreshController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _refreshAnimation;

  TimePeriod _selectedPeriod = TimePeriod.lastMonth;
  List<Insight> _insights = [];
  MoodStatistics? _moodStats;
  JournalStatistics? _journalStats;
  Map<MoodType, int> _moodDistribution = {};
  UserProgress? _userProgress;
  Map<String, double> _correlationData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeInOut),
    );
    

    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.elasticOut),
    );

    _loadAnalyticsData();
    _pageController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _statsController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Replace with actual user ID from auth
      const userId = 'current-user';

      final period = _getPeriodDates(_selectedPeriod);

      // Initialize services
      final moodService = MoodService();
      final journalService = JournalService();
      final insightsService = InsightsService(moodService, journalService);
      final achievementService = AchievementService();

      // Load data concurrently
      final results = await Future.wait([
        moodService.getMoodStatistics(
          userId: userId,
          startDate: period.start,
          endDate: period.end,
        ),
        journalService.getJournalStatistics(
          userId: userId,
          startDate: period.start,
          endDate: period.end,
        ),
        moodService.getMoodTrends(
          userId: userId,
          startDate: period.start,
          endDate: period.end,
          period: TrendPeriod.daily,
        ),
        insightsService.generateInsights(
          userId: userId,
          startDate: period.start,
          endDate: period.end,
        ),
        achievementService.getUserProgress(userId),
      ]);

      setState(() {
        _moodStats = results[0] as MoodStatistics;
        _journalStats = results[1] as JournalStatistics;
        // _trendData = results[2] as List<MoodTrendPoint>; // Using MoodTrendChart with empty data for demo
        _insights = results[3] as List<Insight>;
        _userProgress = results[4] as UserProgress;
        _isLoading = false;
      });

      _generateCorrelationData();
      _generateMoodDistribution();
      _statsController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading analytics: $e');
    }
  }

  void _generateMoodDistribution() {
    // Mock data for demonstration - in real app would come from _moodStats
    _moodDistribution = {
      MoodType.happy: 15,
      MoodType.content: 12,
      MoodType.neutral: 8,
      MoodType.ecstatic: 5,
      MoodType.sad: 3,
      MoodType.anxious: 2,
      MoodType.angry: 1,
      MoodType.depressed: 1,
    };
  }

  void _generateCorrelationData() {
    // Mock correlation data for demonstration
    _correlationData = {
      'Exercise': 0.85,
      'Sleep Quality': 0.78,
      'Social Time': 0.65,
      'Work Stress': -0.72,
      'Weather': 0.45,
      'Nutrition': 0.58,
      'Screen Time': -0.38,
      'Meditation': 0.82,
    };
  }

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

  Future<void> _refreshData() async {
    _refreshController.forward().then((_) {
      _refreshController.reset();
    });
    await _loadAnalyticsData();
  }

  void _changePeriod(TimePeriod period) {
    if (_selectedPeriod != period) {
      setState(() {
        _selectedPeriod = period;
      });
      _loadAnalyticsData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildAppBar(),
              _buildPeriodSelector(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _buildTabbedContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.analytics_outlined, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Text(
            'Analytics',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          RotationTransition(
            turns: _refreshAnimation,
            child: IconButton(
              onPressed: _refreshData,
              icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Analyzing your data...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: TimePeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => _changePeriod(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  period.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabbedContent() {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              isScrollable: true,
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.onSurface,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Trends'),
                Tab(text: 'Insights'),
                Tab(text: 'Correlations'),
                Tab(text: 'Achievements'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _buildOverviewTab(),
                _buildTrendsTab(),
                _buildInsightsTab(),
                _buildCorrelationsTab(),
                _buildAchievementsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsOverview(),
          const SizedBox(height: 24),
          _buildProgressSection(),
          const SizedBox(height: 24),
          _buildQuickInsights(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return StatCardGrid(
      cards: [
        AnimatedStatCard(
          title: 'Mood Entries',
          value: '${_moodStats?.totalEntries ?? 0}',
          subtitle: 'This ${_selectedPeriod.displayName.toLowerCase()}',
          icon: Icons.mood,
          gradient: AppGradients.primary,
        ),
        AnimatedStatCard(
          title: 'Journal Entries',
          value: '${_journalStats?.totalEntries ?? 0}',
          subtitle: 'Written this period',
          icon: Icons.book,
          gradient: AppGradients.accent,
        ),
        AnimatedStatCard(
          title: 'Average Mood',
          value: '${(_moodStats?.averageMood ?? 0).toStringAsFixed(1)}/10',
          subtitle: 'Overall wellbeing',
          icon: Icons.trending_up,
          gradient: AppGradients.secondary,
        ),
        AnimatedStatCard(
          title: 'Streak Days',
          value: '${_journalStats?.currentStreak ?? 0}',
          subtitle: 'Current journaling streak',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProgressStatCard(
                title: 'Mood Tracking',
                progress: 0.85, // 85%
                progressText: '26 out of 30 days',
                icon: Icons.mood,
                color: AppGradients.primary.colors.first,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProgressStatCard(
                title: 'Journal Entries',
                progress: 0.67, // 67%
                progressText: '20 out of 30 days',
                icon: Icons.book,
                color: AppGradients.accent.colors.first,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildQuickInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Insights',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._insights.take(2).map(_buildInsightCard),
        if (_insights.isEmpty) _buildEmptyInsights(),
      ],
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMoodTrendSection(),
          const SizedBox(height: 24),
          _buildMoodDistributionSection(),
          const SizedBox(height: 24),
          _buildComparisonSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFullInsightsSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCorrelationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CorrelationChart(
            correlationData: _correlationData,
            title: 'Mood Factor Correlations',
            xAxisLabel: 'Factors',
            yAxisLabel: 'Correlation Strength',
          ),
          const SizedBox(height: 24),
          WellnessCorrelationView(
            userId: 'current-user',
            startDate: _getPeriodDates(_selectedPeriod).start,
            endDate: _getPeriodDates(_selectedPeriod).end,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    if (_userProgress == null) {
      return Center(
        child: Text(
          'Loading achievements...',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LevelProgressCard(progress: _userProgress!),
          const SizedBox(height: 24),
          Text(
            'Recent Achievements',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AchievementGrid(
            achievements: _userProgress!.unlockedAchievements.take(6).toList(),
            showProgress: false,
          ),
          const SizedBox(height: 24),
          Text(
            'In Progress',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AchievementGrid(
            achievements: _userProgress!.inProgressAchievements
                .take(4)
                .toList(),
            showProgress: true,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFullInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Insights',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._insights.map(_buildInsightCard),
        if (_insights.isEmpty) _buildEmptyInsights(),
      ],
    );
  }

  Widget _buildInsightCard(Insight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassMorphismCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: insight.type.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                insight.type.icon,
                color: insight.type.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  if (insight.suggestion != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '💡 ${insight.suggestion}',
                      style: TextStyle(
                        color: insight.type.color,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyInsights() {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No insights yet',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep tracking your mood and journaling to see personalized insights',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTrendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Trends',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        MoodTrendChart(trendData: const [], title: 'Mood Over Time'),
      ],
    );
  }

  Widget _buildMoodDistributionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Distribution',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        MoodDistributionChart(moodCounts: _moodDistribution),
      ],
    );
  }

  Widget _buildComparisonSection() {
    final currentPeriod = _getPeriodDates(_selectedPeriod);
    final previousStart = currentPeriod.start.subtract(
      Duration(days: currentPeriod.end.difference(currentPeriod.start).inDays),
    );
    final previousEnd = currentPeriod.start;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Period Comparison',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        PeriodComparisonView(
          userId: 'current-user',
          currentStartDate: currentPeriod.start,
          currentEndDate: currentPeriod.end,
          previousStartDate: previousStart,
          previousEndDate: previousEnd,
          currentPeriodLabel: 'Current ${_selectedPeriod.displayName}',
          previousPeriodLabel: 'Previous ${_selectedPeriod.displayName}',
        ),
      ],
    );
  }


}

