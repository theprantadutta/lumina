import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lumina/core/theme/app_gradients.dart';
import 'package:lumina/shared/widgets/glass_morphism_card.dart';

class CorrelationChart extends StatefulWidget {
  final Map<String, double> correlationData;
  final String title;
  final String xAxisLabel;
  final String yAxisLabel;
  final Duration animationDuration;

  const CorrelationChart({
    super.key,
    required this.correlationData,
    required this.title,
    this.xAxisLabel = 'Factors',
    this.yAxisLabel = 'Correlation',
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<CorrelationChart> createState() => _CorrelationChartState();
}

class _CorrelationChartState extends State<CorrelationChart>
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
    
    Future.delayed(const Duration(milliseconds: 300), () {
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
    if (widget.correlationData.isEmpty) {
      return _buildEmptyState();
    }

    return GlassMorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return BarChart(
                  _buildBarChartData(),
                  duration: const Duration(milliseconds: 300),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildCorrelationLegend(),
        ],
      ),
    );
  }

  BarChartData _buildBarChartData() {
    final sortedData = widget.correlationData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 1.0,
      minY: -1.0,
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
            final factor = sortedData[groupIndex].key;
            final correlation = rod.toY;
            final strength = _getCorrelationStrength(correlation);
            return BarTooltipItem(
              '$factor\n${correlation.toStringAsFixed(2)} ($strength)',
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
            getTitlesWidget: (value, meta) => _buildBottomTitles(value, sortedData),
            reservedSize: 42,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 0.25,
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
        horizontalInterval: 0.25,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: value == 0 ? Colors.white38 : Colors.white12,
            strokeWidth: value == 0 ? 2 : 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.white12,
            strokeWidth: 1,
          );
        },
      ),
      barGroups: _buildBarGroups(sortedData),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<MapEntry<String, double>> sortedData) {
    return sortedData.asMap().entries.map((entry) {
      final index = entry.key;
      final correlation = entry.value.value;
      final isTouched = index == _touchedIndex;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: correlation * _animation.value,
            color: _getCorrelationColor(correlation),
            width: isTouched ? 20 : 16,
            borderRadius: BorderRadius.circular(4),
            gradient: correlation > 0
                ? LinearGradient(
                    colors: [
                      AppGradients.primary.colors.first,
                      AppGradients.primary.colors.last,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )
                : LinearGradient(
                    colors: [
                      Colors.red.withValues(alpha: 0.7),
                      Colors.red,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildBottomTitles(double value, List<MapEntry<String, double>> sortedData) {
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    final index = value.toInt();
    if (index < 0 || index >= sortedData.length) {
      return Container();
    }

    final factor = sortedData[index].key;
    final shortName = factor.length > 8 ? '${factor.substring(0, 6)}..' : factor;

    return SideTitleWidget(
      axisSide: AxisSide.bottom,
      child: Transform.rotate(
        angle: -0.5,
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

    String text;
    switch (value) {
      case -1:
        text = '-1.0';
        break;
      case -0.5:
        text = '-0.5';
        break;
      case 0:
        text = '0';
        break;
      case 0.5:
        text = '0.5';
        break;
      case 1:
        text = '1.0';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  Widget _buildCorrelationLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correlation Strength',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildLegendItem('Strong Positive (>0.7)', AppGradients.primary.colors.first),
            _buildLegendItem('Moderate Positive (0.3-0.7)', AppGradients.primary.colors.first.withValues(alpha: 0.7)),
            _buildLegendItem('Weak/None (-0.3-0.3)', Colors.white60),
            _buildLegendItem('Moderate Negative (<-0.3)', Colors.red.withValues(alpha: 0.7)),
            _buildLegendItem('Strong Negative (<-0.7)', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.scatter_plot_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Correlation Data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Need more data to analyze correlations',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getCorrelationColor(double correlation) {
    if (correlation > 0.7) {
      return AppGradients.primary.colors.first;
    } else if (correlation > 0.3) {
      return AppGradients.primary.colors.first.withValues(alpha: 0.7);
    } else if (correlation > -0.3) {
      return Colors.white60;
    } else if (correlation > -0.7) {
      return Colors.red.withValues(alpha: 0.7);
    } else {
      return Colors.red;
    }
  }

  String _getCorrelationStrength(double correlation) {
    if (correlation.abs() > 0.7) {
      return 'Strong';
    } else if (correlation.abs() > 0.3) {
      return 'Moderate';
    } else {
      return 'Weak';
    }
  }
}

class WellnessCorrelationView extends StatefulWidget {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const WellnessCorrelationView({
    super.key,
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<WellnessCorrelationView> createState() => _WellnessCorrelationViewState();
}

class _WellnessCorrelationViewState extends State<WellnessCorrelationView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  Map<String, double> _moodFactorCorrelations = {};
  Map<String, double> _timeOfDayCorrelations = {};
  Map<String, double> _weatherCorrelations = {};
  Map<String, double> _activityCorrelations = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCorrelationData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCorrelationData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _moodFactorCorrelations = {
          'Exercise': 0.85,
          'Sleep Quality': 0.78,
          'Social Time': 0.65,
          'Work Stress': -0.72,
          'Weather': 0.45,
          'Nutrition': 0.58,
          'Screen Time': -0.38,
          'Meditation': 0.82,
        };
        
        _timeOfDayCorrelations = {
          'Morning (6-9)': 0.42,
          'Mid-Morning (9-12)': 0.65,
          'Afternoon (12-15)': 0.38,
          'Evening (15-18)': 0.28,
          'Night (18-21)': -0.15,
          'Late Night (21-24)': -0.45,
        };
        
        _weatherCorrelations = {
          'Sunny': 0.78,
          'Partly Cloudy': 0.32,
          'Cloudy': -0.15,
          'Rainy': -0.58,
          'Stormy': -0.72,
          'Snowy': -0.28,
        };
        
        _activityCorrelations = {
          'Outdoor Walk': 0.88,
          'Reading': 0.62,
          'Cooking': 0.55,
          'Gaming': -0.25,
          'Cleaning': 0.35,
          'Shopping': 0.18,
          'Commuting': -0.42,
          'Meeting': -0.38,
        };
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading correlation data: $e');
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
              'Analyzing correlations...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppGradients.primary.colors.first,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Factors'),
              Tab(text: 'Time of Day'),
              Tab(text: 'Weather'),
              Tab(text: 'Activities'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCorrelationTab(
                _moodFactorCorrelations,
                'Mood Factor Correlations',
                'Factors',
                'Mood Impact',
              ),
              _buildCorrelationTab(
                _timeOfDayCorrelations,
                'Time of Day Correlations',
                'Time Period',
                'Mood Level',
              ),
              _buildCorrelationTab(
                _weatherCorrelations,
                'Weather Correlations',
                'Weather Type',
                'Mood Impact',
              ),
              _buildCorrelationTab(
                _activityCorrelations,
                'Activity Correlations',
                'Activity Type',
                'Mood Impact',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCorrelationTab(
    Map<String, double> data,
    String title,
    String xLabel,
    String yLabel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CorrelationChart(
            correlationData: data,
            title: title,
            xAxisLabel: xLabel,
            yAxisLabel: yLabel,
          ),
          const SizedBox(height: 24),
          _buildInsightsSection(data, title),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(Map<String, double> data, String title) {
    final positiveFactors = data.entries
        .where((e) => e.value > 0.5)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final negativeFactors = data.entries
        .where((e) => e.value < -0.3)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return GlassMorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Insights',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (positiveFactors.isNotEmpty) ...[
            Text(
              'Mood Boosters',
              style: TextStyle(
                color: AppGradients.primary.colors.first,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...positiveFactors.take(3).map((factor) => 
              _buildInsightItem(
                factor.key,
                factor.value,
                Icons.trending_up,
                AppGradients.primary.colors.first,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          if (negativeFactors.isNotEmpty) ...[
            const Text(
              'Mood Challenges',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...negativeFactors.take(3).map((factor) => 
              _buildInsightItem(
                factor.key,
                factor.value,
                Icons.trending_down,
                Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightItem(String factor, double correlation, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              factor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            correlation > 0 ? '+${correlation.toStringAsFixed(2)}' : correlation.toStringAsFixed(2),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}