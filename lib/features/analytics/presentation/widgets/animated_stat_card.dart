import 'package:flutter/material.dart';
import 'package:lumina/core/theme/app_gradients.dart';
import 'package:lumina/shared/widgets/glass_morphism_card.dart';

class AnimatedStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final Gradient? gradient;
  final Duration animationDuration;
  final VoidCallback? onTap;

  const AnimatedStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.gradient,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.onTap,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _counterController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<int> _counterAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _counterController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration.inMilliseconds + 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Parse numeric value for counter animation
    final numericValue = _parseNumericValue(widget.value);
    _counterAnimation = IntTween(
      begin: 0,
      end: numericValue,
    ).animate(CurvedAnimation(
      parent: _counterController,
      curve: Curves.easeOut,
    ));

    // Start animations with a slight delay
    Future.delayed(Duration(milliseconds: (widget.hashCode % 500)), () {
      if (mounted) {
        _slideController.forward();
        _counterController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  int _parseNumericValue(String value) {
    final cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleanedValue) ?? 0;
  }

  String _formatCounterValue(int value) {
    final originalValue = widget.value;
    if (originalValue.contains('%')) {
      return '$value%';
    } else if (originalValue.contains('k')) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    } else if (originalValue.contains('days')) {
      return '$value days';
    } else if (originalValue.contains('entries')) {
      return '$value entries';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: GlassMorphismCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: widget.gradient ?? AppGradients.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    if (widget.onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _counterAnimation,
                  builder: (context, child) {
                    return Text(
                      _parseNumericValue(widget.value) > 0
                          ? _formatCounterValue(_counterAnimation.value)
                          : widget.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatCardGrid extends StatelessWidget {
  final List<AnimatedStatCard> cards;
  final int crossAxisCount;
  final double spacing;

  const StatCardGrid({
    super.key,
    required this.cards,
    this.crossAxisCount = 2,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.1,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }
}

class ProgressStatCard extends StatefulWidget {
  final String title;
  final double progress; // 0.0 to 1.0
  final String progressText;
  final IconData icon;
  final Color? color;
  final Duration animationDuration;

  const ProgressStatCard({
    super.key,
    required this.title,
    required this.progress,
    required this.progressText,
    required this.icon,
    this.color,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<ProgressStatCard> createState() => _ProgressStatCardState();
}

class _ProgressStatCardState extends State<ProgressStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    Future.delayed(Duration(milliseconds: (widget.hashCode % 300)), () {
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
    final color = widget.color ?? AppGradients.primary.colors.first;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GlassMorphismCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.progressText,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color,
                              color.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrendIndicator extends StatelessWidget {
  final double value;
  final String label;
  final bool isPositive;
  final Duration animationDuration;

  const TrendIndicator({
    super.key,
    required this.value,
    required this.label,
    required this.isPositive,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: animationDuration,
      tween: Tween<double>(begin: 0, end: value),
      curve: Curves.elasticOut,
      builder: (context, animatedValue, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${animatedValue.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}