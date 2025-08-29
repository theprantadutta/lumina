import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumina/core/theme/app_gradients.dart';
import 'package:lumina/shared/models/mood_entry.dart';
import 'package:lumina/shared/widgets/glass_morphism_card.dart';

class MoodSelector extends StatefulWidget {
  final MoodType? selectedMood;
  final Function(MoodType) onMoodSelected;
  final bool isEnabled;

  const MoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
    this.isEnabled = true,
  });

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector>
    with TickerProviderStateMixin {
  late AnimationController _selectionController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'How are you feeling?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          _buildMoodGrid(),
        ],
      ),
    );
  }

  Widget _buildMoodGrid() {
    const moods = MoodType.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final mood = moods[index];
        final isSelected = widget.selectedMood == mood;
        return _buildMoodBubble(mood, isSelected);
      },
    );
  }

  Widget _buildMoodBubble(MoodType mood, bool isSelected) {
    return AnimatedBuilder(
      animation: isSelected ? _selectionController : _pulseController,
      builder: (context, child) {
        final animation = isSelected ? _scaleAnimation : _pulseAnimation;
        return Transform.scale(
          scale: animation.value,
          child: GestureDetector(
            onTap: widget.isEnabled ? () => _handleMoodTap(mood) : null,
            child: AnimatedMoodBubble(
              mood: mood,
              isSelected: isSelected,
              isEnabled: widget.isEnabled,
            ),
          ),
        );
      },
    );
  }

  void _handleMoodTap(MoodType mood) {
    if (!widget.isEnabled) return;
    
    HapticFeedback.lightImpact();
    _selectionController.forward().then((_) {
      _selectionController.reverse();
    });
    
    widget.onMoodSelected(mood);
  }
}

class AnimatedMoodBubble extends StatefulWidget {
  final MoodType mood;
  final bool isSelected;
  final bool isEnabled;

  const AnimatedMoodBubble({
    super.key,
    required this.mood,
    required this.isSelected,
    this.isEnabled = true,
  });

  @override
  State<AnimatedMoodBubble> createState() => _AnimatedMoodBubbleState();
}

class _AnimatedMoodBubbleState extends State<AnimatedMoodBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: widget.mood.color.withValues(alpha: 0.6),
      end: widget.mood.color,
    ).animate(_controller);

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedMoodBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.mood.color.withValues(alpha: 0.4),
                      blurRadius: 20 * _glowAnimation.value,
                      spreadRadius: 5 * _glowAnimation.value,
                    ),
                  ]
                : null,
          ),
          child: GlassMorphismCard(
            borderRadius: 40,
            color: _colorAnimation.value ?? widget.mood.color.withValues(alpha: 0.6),
            opacity: widget.isSelected ? 0.3 : 0.1,
            blur: widget.isSelected ? 20 : 10,
            child: Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.mood.emoji,
                    style: TextStyle(
                      fontSize: widget.isSelected ? 32 : 28,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.mood.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class IntensitySlider extends StatefulWidget {
  final int value;
  final Function(int) onChanged;
  final MoodType? selectedMood;
  final bool isEnabled;

  const IntensitySlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.selectedMood,
    this.isEnabled = true,
  });

  @override
  State<IntensitySlider> createState() => _IntensitySliderState();
}

class _IntensitySliderState extends State<IntensitySlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedMood == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GlassMorphismCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Intensity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.value}/10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: widget.selectedMood?.color,
                    inactiveTrackColor: widget.selectedMood?.color.withValues(alpha: 0.3),
                    thumbColor: widget.selectedMood?.color,
                    overlayColor: widget.selectedMood?.color.withValues(alpha: 0.1),
                    trackHeight: 6.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  ),
                  child: Slider(
                    value: widget.value.toDouble(),
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    onChanged: widget.isEnabled
                        ? (value) {
                            HapticFeedback.selectionClick();
                            widget.onChanged(value.round());
                            _controller.forward().then((_) => _controller.reverse());
                          }
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mild',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Intense',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}