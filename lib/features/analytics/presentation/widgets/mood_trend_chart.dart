import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lumina/core/theme/app_gradients.dart';
import 'package:lumina/features/mood/data/services/mood_service.dart';
import 'package:lumina/shared/models/mood_entry.dart';
import 'package:lumina/shared/widgets/glass_morphism_card.dart';

class MoodTrendChart extends StatefulWidget {
  final List<MoodTrendPoint> trendData;
  final String title;
  final Duration animationDuration;

  const MoodTrendChart({
    super.key,
    required this.trendData,
    this.title = 'Mood Trends',
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<MoodTrendChart> createState() => _MoodTrendChartState();
}

class _MoodTrendChartState extends State<MoodTrendChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _touchedIndex;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trendData.isEmpty) {
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
            height: 250,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LineChart(
                  _buildChartData(),
                  duration: const Duration(milliseconds: 300),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 2,
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
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: _buildBottomTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2,
            getTitlesWidget: _buildLeftTitles,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white24),
      ),
      minX: 0,
      maxX: widget.trendData.length.toDouble() - 1,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: _buildSpots(),
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
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                touchResponse == null ||
                touchResponse.lineBarSpots == null) {
              _touchedIndex = null;
              return;
            }
            _touchedIndex = touchResponse.lineBarSpots!.first.spotIndex;
          });
        },
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              const FlLine(
                color: Colors.white,
                strokeWidth: 2,
              ),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 8,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: AppGradients.primary.colors.first,
                ),
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.black87,
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              final date = widget.trendData[flSpot.x.toInt()].date;
              final mood = flSpot.y;
              return LineTooltipItem(
                '${_formatDate(date)}\nMood: ${mood.toStringAsFixed(1)}/10',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    return widget.trendData
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final data = entry.value;
          return FlSpot(
            index.toDouble(),
            data.averageMood * _animation.value,
          );
        })
        .toList();
  }

  Widget _buildBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    
    final index = value.toInt();
    if (index < 0 || index >= widget.trendData.length) {
      return Container();
    }
    
    final date = widget.trendData[index].date;
    final text = _formatDateShort(date);
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget _buildLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Low';
        break;
      case 5:
        text = 'Neutral';
        break;
      case 10:
        text = 'High';
        break;
      default:
        return Container();
    }
    
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Average Mood', AppGradients.primary.colors.first),
        _buildLegendItem('Entries: ${widget.trendData.length}', Colors.white70),
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
            shape: BoxShape.circle,
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

  Widget _buildEmptyState() {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Data Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your mood to see trends here',
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  String _formatDateShort(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }
}

class MoodDistributionChart extends StatefulWidget {
  final Map<MoodType, int> moodCounts;
  final Duration animationDuration;

  const MoodDistributionChart({
    super.key,
    required this.moodCounts,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<MoodDistributionChart> createState() => _MoodDistributionChartState();
}

class _MoodDistributionChartState extends State<MoodDistributionChart>
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.moodCounts.isEmpty) {
      return _buildEmptyState();
    }

    return GlassMorphismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Distribution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _buildPieChartSections(),
                  ),
                  duration: const Duration(milliseconds: 300),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildMoodLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = widget.moodCounts.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) return [];

    return widget.moodCounts.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final moodEntry = entry.value;
      final mood = moodEntry.key;
      final count = moodEntry.value;
      final percentage = (count / total) * 100;
      final isTouched = index == _touchedIndex;
      
      return PieChartSectionData(
        color: mood.color,
        value: count.toDouble() * _animation.value,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 80 : 70,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  Widget _buildMoodLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: widget.moodCounts.entries.map((entry) {
        final mood = entry.key;
        final count = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: mood.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${mood.displayName} ($count)',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Mood Data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your moods to see distribution here',
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
}