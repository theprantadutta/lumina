import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lumina/core/theme/app_gradients.dart';
import 'package:lumina/shared/widgets/glass_morphism_card.dart';

class PeriodComparisonChart extends StatefulWidget {
  final Map<String, double> currentPeriodData;
  final Map<String, double> previousPeriodData;
  final String currentPeriodLabel;
  final String previousPeriodLabel;
  final String title;
  final String dataType;
  final ComparisonChartType chartType;
  final Duration animationDuration;

  const PeriodComparisonChart({
    super.key,
    required this.currentPeriodData,
    required this.previousPeriodData,
    required this.currentPeriodLabel,
    required this.previousPeriodLabel,
    required this.title,
    this.dataType = 'Value',
    this.chartType = ComparisonChartType.bar,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<PeriodComparisonChart> createState() => _PeriodComparisonChartState();
}

class _PeriodComparisonChartState extends State<PeriodComparisonChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: widget.chartType == ComparisonChartType.bar
                ? _buildBarChart()
                : _buildLineChart(),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 16),
          _buildComparisonSummary(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppGradients.primary.colors.first.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppGradients.primary.colors.first.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.chartType == ComparisonChartType.bar
                    ? Icons.bar_chart
                    : Icons.show_chart,
                size: 14,
                color: AppGradients.primary.colors.first,
              ),
              const SizedBox(width: 6),
              Text(
                widget.chartType == ComparisonChartType.bar ? 'Bar' : 'Line',
                style: TextStyle(
                  color: AppGradients.primary.colors.first,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxValue() * 1.2,
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.spot == null) {
                    _touchedIndex = -1;
                    return;
                  }
                  _touchedIndex = response.spot!.touchedBarGroupIndex;
                });
              },
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Colors.black87,
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final categories = _getCombinedCategories();
                  if (groupIndex >= categories.length) return null;
                  
                  final category = categories[groupIndex];
                  final value = rod.toY;
                  final period = rodIndex == 0 
                      ? widget.currentPeriodLabel 
                      : widget.previousPeriodLabel;
                  
                  return BarTooltipItem(
                    '$category\n$period: ${value.toStringAsFixed(1)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: _buildBottomTitles,
                  reservedSize: 42,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: _buildLeftTitles,
                  reservedSize: 50,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.white24),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: _getMaxValue() / 5,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.white12,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Colors.white12,
                  strokeWidth: 1,
                );
              },
            ),
            barGroups: _buildBarGroups(),
          ),
          duration: const Duration(milliseconds: 300),
        );
      },
    );
  }

  Widget _buildLineChart() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: _getMaxValue() / 5,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.white12,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Colors.white12,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: _buildBottomTitles,
                  reservedSize: 42,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: _buildLeftTitles,
                  reservedSize: 50,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.white24),
            ),
            minX: 0,
            maxX: (_getCombinedCategories().length - 1).toDouble(),
            minY: 0,
            maxY: _getMaxValue() * 1.2,
            lineBarsData: [
              // Current period line
              LineChartBarData(
                spots: _buildCurrentPeriodSpots(),
                isCurved: true,
                gradient: AppGradients.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 6,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: AppGradients.primary.colors.first,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppGradients.primary.colors.first.withValues(alpha: 0.3),
                      AppGradients.primary.colors.last.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Previous period line
              LineChartBarData(
                spots: _buildPreviousPeriodSpots(),
                isCurved: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.white60,
                    Colors.white.withValues(alpha: 0.4),
                  ],
                ),
                barWidth: 2,
                isStrokeCapRound: true,
                dashArray: [5, 5],
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white60,
                    strokeWidth: 2,
                    strokeColor: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 300),
        );
      },
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final categories = _getCombinedCategories();
    
    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == _touchedIndex;
      
      final currentValue = widget.currentPeriodData[category] ?? 0.0;
      final previousValue = widget.previousPeriodData[category] ?? 0.0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: currentValue * _animation.value,
            color: AppGradients.primary.colors.first,
            width: isTouched ? 20 : 16,
            borderRadius: BorderRadius.circular(4),
            gradient: AppGradients.primary,
          ),
          BarChartRodData(
            toY: previousValue * _animation.value,
            color: Colors.white60,
            width: isTouched ? 18 : 14,
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [Colors.white60, Colors.white.withValues(alpha: 0.4)],
            ),
          ),
        ],
        barsSpace: 4,
      );
    }).toList();
  }

  List<FlSpot> _buildCurrentPeriodSpots() {
    final categories = _getCombinedCategories();
    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final value = widget.currentPeriodData[category] ?? 0.0;
      return FlSpot(index.toDouble(), value * _animation.value);
    }).toList();
  }

  List<FlSpot> _buildPreviousPeriodSpots() {
    final categories = _getCombinedCategories();
    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final value = widget.previousPeriodData[category] ?? 0.0;
      return FlSpot(index.toDouble(), value * _animation.value);
    }).toList();
  }

  Widget _buildBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    final categories = _getCombinedCategories();
    final index = value.toInt();
    
    if (index < 0 || index >= categories.length) {
      return Container();
    }

    final category = categories[index];
    final shortName = category.length > 8 
        ? '${category.substring(0, 6)}..' 
        : category;

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Transform.rotate(
        angle: -0.3,
        child: Text(shortName, style: style),
      ),
    );
  }

  Widget _buildLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    return Text(
      value.toStringAsFixed(0),
      style: style,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          widget.currentPeriodLabel,
          AppGradients.primary.colors.first,
          isSolid: true,
        ),
        _buildLegendItem(
          widget.previousPeriodLabel,
          Colors.white60,
          isSolid: false,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, {required bool isSolid}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
          child: isSolid ? null : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.5),
              border: Border.all(color: color, width: 1),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonSummary() {
    final currentTotal = widget.currentPeriodData.values
        .fold<double>(0.0, (sum, value) => sum + value);
    final previousTotal = widget.previousPeriodData.values
        .fold<double>(0.0, (sum, value) => sum + value);
    
    final difference = currentTotal - previousTotal;
    final percentageChange = previousTotal != 0 
        ? (difference / previousTotal) * 100 
        : 0.0;
    
    final isPositive = difference >= 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Period Comparison',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isPositive ? '+' : ''}${difference.toStringAsFixed(1)} ${widget.dataType.toLowerCase()} '
                  '(${isPositive ? '+' : ''}${percentageChange.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getCombinedCategories() {
    final allCategories = <String>{};
    allCategories.addAll(widget.currentPeriodData.keys);
    allCategories.addAll(widget.previousPeriodData.keys);
    return allCategories.toList()..sort();
  }

  double _getMaxValue() {
    final allValues = <double>[];
    allValues.addAll(widget.currentPeriodData.values);
    allValues.addAll(widget.previousPeriodData.values);
    return allValues.isEmpty ? 10.0 : allValues.reduce((a, b) => a > b ? a : b);
  }
}

enum ComparisonChartType {
  bar,
  line;

  String get displayName {
    switch (this) {
      case ComparisonChartType.bar:
        return 'Bar Chart';
      case ComparisonChartType.line:
        return 'Line Chart';
    }
  }
}

class PeriodComparisonView extends StatefulWidget {
  final String userId;
  final DateTime currentStartDate;
  final DateTime currentEndDate;
  final DateTime previousStartDate;
  final DateTime previousEndDate;
  final String currentPeriodLabel;
  final String previousPeriodLabel;

  const PeriodComparisonView({
    super.key,
    required this.userId,
    required this.currentStartDate,
    required this.currentEndDate,
    required this.previousStartDate,
    required this.previousEndDate,
    required this.currentPeriodLabel,
    required this.previousPeriodLabel,
  });

  @override
  State<PeriodComparisonView> createState() => _PeriodComparisonViewState();
}

class _PeriodComparisonViewState extends State<PeriodComparisonView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  ComparisonChartType _chartType = ComparisonChartType.bar;
  
  Map<String, double> _currentMoodData = {};
  Map<String, double> _previousMoodData = {};
  Map<String, double> _currentJournalData = {};
  Map<String, double> _previousJournalData = {};
  Map<String, double> _currentActivityData = {};
  Map<String, double> _previousActivityData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadComparisonData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadComparisonData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        // Mock current period mood data
        _currentMoodData = {
          'Happy': 8.5,
          'Content': 7.2,
          'Neutral': 6.0,
          'Sad': 3.2,
          'Anxious': 2.8,
          'Ecstatic': 9.1,
          'Angry': 2.1,
          'Depressed': 1.8,
        };
        
        // Mock previous period mood data
        _previousMoodData = {
          'Happy': 7.1,
          'Content': 6.8,
          'Neutral': 5.5,
          'Sad': 4.1,
          'Anxious': 3.5,
          'Ecstatic': 7.8,
          'Angry': 2.9,
          'Depressed': 2.4,
        };
        
        // Mock journal data
        _currentJournalData = {
          'Daily': 12,
          'Gratitude': 8,
          'Reflection': 6,
          'Goal Setting': 4,
          'Stream of Consciousness': 3,
        };
        
        _previousJournalData = {
          'Daily': 9,
          'Gratitude': 6,
          'Reflection': 5,
          'Goal Setting': 2,
          'Stream of Consciousness': 4,
        };
        
        // Mock activity data
        _currentActivityData = {
          'Exercise': 15,
          'Social Time': 12,
          'Work': 8,
          'Relaxation': 10,
          'Creative': 6,
          'Learning': 4,
        };
        
        _previousActivityData = {
          'Exercise': 10,
          'Social Time': 14,
          'Work': 12,
          'Relaxation': 8,
          'Creative': 4,
          'Learning': 3,
        };
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading comparison data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Comparing periods...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildControls(),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppGradients.primary.colors.first,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Mood Trends'),
              Tab(text: 'Journal Activity'),
              Tab(text: 'Activities'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildComparisonTab(
                _currentMoodData,
                _previousMoodData,
                'Mood Comparison',
                'Average Mood Score',
              ),
              _buildComparisonTab(
                _currentJournalData,
                _previousJournalData,
                'Journal Template Usage',
                'Entry Count',
              ),
              _buildComparisonTab(
                _currentActivityData,
                _previousActivityData,
                'Activity Tracking',
                'Activity Hours',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comparing',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.currentPeriodLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'vs ${widget.previousPeriodLabel}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                _buildChartTypeButton(
                  ComparisonChartType.bar,
                  Icons.bar_chart,
                ),
                _buildChartTypeButton(
                  ComparisonChartType.line,
                  Icons.show_chart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeButton(ComparisonChartType type, IconData icon) {
    final isSelected = _chartType == type;
    
    return GestureDetector(
      onTap: () => setState(() => _chartType = type),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppGradients.primary.colors.first.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected 
              ? AppGradients.primary.colors.first 
              : Colors.white60,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildComparisonTab(
    Map<String, double> currentData,
    Map<String, double> previousData,
    String title,
    String dataType,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PeriodComparisonChart(
        currentPeriodData: currentData,
        previousPeriodData: previousData,
        currentPeriodLabel: widget.currentPeriodLabel,
        previousPeriodLabel: widget.previousPeriodLabel,
        title: title,
        dataType: dataType,
        chartType: _chartType,
      ),
    );
  }
}