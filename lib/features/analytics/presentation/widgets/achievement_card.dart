import 'package:flutter/material.dart';
import 'package:lumina/features/analytics/data/models/achievement.dart';
import 'package:lumina/shared/widgets/glass_morphism_card.dart';

class AchievementCard extends StatefulWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final bool showProgress;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.isUnlocked = false,
    this.showProgress = true,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _shineController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
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

    _shineAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOut,
    ));

    // Start animations with a slight delay
    Future.delayed(Duration(milliseconds: (widget.achievement.hashCode % 500)), () {
      if (mounted) {
        _slideController.forward();
        if (widget.isUnlocked) {
          _shineController.repeat(period: const Duration(seconds: 3));
        }
      }
    });
  }

  @override
  void didUpdateWidget(AchievementCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUnlocked && !oldWidget.isUnlocked) {
      _shineController.repeat(period: const Duration(seconds: 3));
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            children: [
              GlassMorphismCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildAchievementIcon(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.achievement.title,
                                style: TextStyle(
                                  color: widget.isUnlocked 
                                      ? Colors.white 
                                      : Colors.white.withValues(alpha: 0.7),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.achievement.description,
                                style: TextStyle(
                                  color: widget.isUnlocked
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildTierBadge(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildProgressSection(),
                    if (widget.achievement.reward != null) ...[
                      const SizedBox(height: 8),
                      _buildRewardSection(),
                    ],
                  ],
                ),
              ),
              if (widget.isUnlocked) _buildShineEffect(),
              if (widget.isUnlocked) _buildUnlockedBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementIcon() {
    final iconData = IconData(
      widget.achievement.iconCodePoint,
      fontFamily: widget.achievement.iconFontFamily,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: widget.isUnlocked
            ? LinearGradient(
                colors: [
                  widget.achievement.type.color,
                  widget.achievement.type.color.withValues(alpha: 0.7),
                ],
              )
            : LinearGradient(
                colors: [
                  Colors.grey.withValues(alpha: 0.3),
                  Colors.grey.withValues(alpha: 0.1),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        border: widget.isUnlocked
            ? Border.all(
                color: widget.achievement.type.color.withValues(alpha: 0.5),
                width: 2,
              )
            : null,
      ),
      child: Icon(
        iconData,
        color: widget.isUnlocked ? Colors.white : Colors.white54,
        size: 28,
      ),
    );
  }

  Widget _buildTierBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getTierColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getTierColor().withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTierIcon(),
            size: 12,
            color: _getTierColor(),
          ),
          const SizedBox(width: 4),
          Text(
            'T${widget.achievement.tier}',
            style: TextStyle(
              color: _getTierColor(),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    if (!widget.showProgress) return Container();

    final progress = widget.achievement.currentProgress;
    final target = widget.achievement.targetValue;
    final progressPercentage = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$progress / $target',
              style: TextStyle(
                color: widget.isUnlocked 
                    ? widget.achievement.type.color 
                    : Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween<double>(begin: 0, end: progressPercentage),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isUnlocked
                            ? [
                                widget.achievement.type.color,
                                widget.achievement.type.color.withValues(alpha: 0.7),
                              ]
                            : [
                                Colors.white60,
                                Colors.white.withValues(alpha: 0.4),
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
    );
  }

  Widget _buildRewardSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 14,
            color: Colors.amber,
          ),
          const SizedBox(width: 6),
          Text(
            widget.achievement.reward!,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShineEffect() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shineAnimation,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [
                    (_shineAnimation.value - 0.3).clamp(0.0, 1.0),
                    _shineAnimation.value.clamp(0.0, 1.0),
                    (_shineAnimation.value + 0.3).clamp(0.0, 1.0),
                  ],
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnlockedBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: widget.achievement.type.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.achievement.type.color.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.check,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getTierColor() {
    switch (widget.achievement.tier) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTierIcon() {
    switch (widget.achievement.tier) {
      case 1:
        return Icons.circle;
      case 2:
        return Icons.hexagon;
      case 3:
        return Icons.diamond;
      case 4:
        return Icons.star;
      case 5:
        return Icons.auto_awesome;
      default:
        return Icons.circle;
    }
  }
}

class AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final Function(Achievement)? onAchievementTap;
  final bool showProgress;
  final int crossAxisCount;

  const AchievementGrid({
    super.key,
    required this.achievements,
    this.onAchievementTap,
    this.showProgress = true,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return AchievementCard(
          achievement: achievement,
          isUnlocked: achievement.isUnlocked,
          showProgress: showProgress,
          onTap: onAchievementTap != null
              ? () => onAchievementTap!(achievement)
              : null,
        );
      },
    );
  }
}

class LevelProgressCard extends StatefulWidget {
  final UserProgress progress;
  final Duration animationDuration;

  const LevelProgressCard({
    super.key,
    required this.progress,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<LevelProgressCard> createState() => _LevelProgressCardState();
}

class _LevelProgressCardState extends State<LevelProgressCard>
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

    final progressPercentage = widget.progress.nextLevelRequirement > 0
        ? widget.progress.currentLevelProgress / widget.progress.nextLevelRequirement
        : 0.0;

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: progressPercentage,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple,
                        Colors.purple.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${widget.progress.currentLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.progress.totalPoints} total points',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${widget.progress.currentLevelProgress}/${widget.progress.nextLevelRequirement}',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Progress to Level ${widget.progress.currentLevel + 1}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.purple,
                              Colors.deepPurple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
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