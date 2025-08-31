import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lumina/shared/models/social_models.dart';

class AnimatedReactionSystem extends StatefulWidget {
  final String targetId;
  final List<Reaction> reactions;
  final Function(ReactionType) onReactionTap;
  final Function(String)? onReactionRemove;
  final bool showReactionCount;
  final bool allowMultipleReactions;
  final double size;

  const AnimatedReactionSystem({
    super.key,
    required this.targetId,
    required this.reactions,
    required this.onReactionTap,
    this.onReactionRemove,
    this.showReactionCount = true,
    this.allowMultipleReactions = false,
    this.size = 32.0,
  });

  @override
  State<AnimatedReactionSystem> createState() => _AnimatedReactionSystemState();
}

class _AnimatedReactionSystemState extends State<AnimatedReactionSystem>
    with TickerProviderStateMixin {
  late Map<ReactionType, AnimationController> _animationControllers;
  bool _showReactionPicker = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _initializeAnimationControllers();
  }

  void _initializeAnimationControllers() {
    _animationControllers = {};
    for (final reactionType in ReactionType.values) {
      _animationControllers[reactionType] = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reaction Display
        if (widget.reactions.isNotEmpty) _buildReactionDisplay(),
        
        const SizedBox(height: 8),
        
        // Add Reaction Button
        _buildAddReactionButton(),
      ],
    );
  }

  Widget _buildReactionDisplay() {
    final reactionCounts = <ReactionType, int>{};
    for (final reaction in widget.reactions) {
      reactionCounts[reaction.type] = (reactionCounts[reaction.type] ?? 0) + 1;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: reactionCounts.entries.map((entry) {
        return _buildReactionChip(
          reactionType: entry.key,
          count: entry.value,
        );
      }).toList(),
    );
  }

  Widget _buildReactionChip({
    required ReactionType reactionType,
    required int count,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lottie animation for reaction
          SizedBox(
            width: 20,
            height: 20,
            child: Lottie.asset(
              _getLottieAssetPath(reactionType),
              controller: _animationControllers[reactionType],
              onLoaded: (composition) {
                _animationControllers[reactionType]?.duration = composition.duration;
              },
            ),
          ),
          
          if (widget.showReactionCount) ...[
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddReactionButton() {
    return GestureDetector(
      onTap: _toggleReactionPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _showReactionPicker ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _showReactionPicker ? Colors.blue.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _showReactionPicker ? Icons.close : Icons.add_reaction_outlined,
              size: 16,
              color: _showReactionPicker ? Colors.blue : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              _showReactionPicker ? 'Cancel' : 'React',
              style: TextStyle(
                fontSize: 12,
                color: _showReactionPicker ? Colors.blue : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleReactionPicker() {
    if (_showReactionPicker) {
      _removeOverlay();
    } else {
      _showReactionPicker = true;
      _showReactionPickerOverlay();
    }
  }

  void _showReactionPickerOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy - 60, // Show above the button
        child: ReactionPickerOverlay(
          onReactionSelected: _onReactionSelected,
          onDismiss: _removeOverlay,
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _showReactionPicker = false;
    });
  }

  void _onReactionSelected(ReactionType reactionType) {
    // Trigger animation
    _animationControllers[reactionType]?.forward().then((_) {
      _animationControllers[reactionType]?.reset();
    });

    // Call the callback
    widget.onReactionTap(reactionType);

    // Remove overlay
    _removeOverlay();

    // Show floating reaction animation
    _showFloatingReaction(reactionType);
  }

  void _showFloatingReaction(ReactionType reactionType) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final overlayEntry = OverlayEntry(
      builder: (context) => FloatingReactionAnimation(
        reactionType: reactionType,
        startPosition: Offset(
          position.dx + renderBox.size.width / 2,
          position.dy,
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Remove after animation completes
    Future.delayed(const Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });
  }

  String _getLottieAssetPath(ReactionType reactionType) {
    switch (reactionType) {
      case ReactionType.heart:
        return 'assets/lottie/reaction_heart.json';
      case ReactionType.supportive:
        return 'assets/lottie/reaction_supportive.json';
      case ReactionType.inspiring:
        return 'assets/lottie/reaction_inspiring.json';
      case ReactionType.celebrate:
        return 'assets/lottie/reaction_celebrate.json';
      case ReactionType.empathy:
        return 'assets/lottie/reaction_empathy.json';
      case ReactionType.strength:
        return 'assets/lottie/reaction_strength.json';
    }
  }
}

class ReactionPickerOverlay extends StatefulWidget {
  final Function(ReactionType) onReactionSelected;
  final VoidCallback onDismiss;

  const ReactionPickerOverlay({
    super.key,
    required this.onReactionSelected,
    required this.onDismiss,
  });

  @override
  State<ReactionPickerOverlay> createState() => _ReactionPickerOverlayState();
}

class _ReactionPickerOverlayState extends State<ReactionPickerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
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
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ReactionType.values.map((reactionType) {
                      return _buildReactionButton(reactionType);
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReactionButton(ReactionType reactionType) {
    return GestureDetector(
      onTap: () => widget.onReactionSelected(reactionType),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: Lottie.asset(
              _getLottieAssetPath(reactionType),
              repeat: false,
            ),
          ),
        ),
      ),
    );
  }

  String _getLottieAssetPath(ReactionType reactionType) {
    switch (reactionType) {
      case ReactionType.heart:
        return 'assets/lottie/reaction_heart.json';
      case ReactionType.supportive:
        return 'assets/lottie/reaction_supportive.json';
      case ReactionType.inspiring:
        return 'assets/lottie/reaction_inspiring.json';
      case ReactionType.celebrate:
        return 'assets/lottie/reaction_celebrate.json';
      case ReactionType.empathy:
        return 'assets/lottie/reaction_empathy.json';
      case ReactionType.strength:
        return 'assets/lottie/reaction_strength.json';
    }
  }
}

class FloatingReactionAnimation extends StatefulWidget {
  final ReactionType reactionType;
  final Offset startPosition;

  const FloatingReactionAnimation({
    super.key,
    required this.reactionType,
    required this.startPosition,
  });

  @override
  State<FloatingReactionAnimation> createState() => _FloatingReactionAnimationState();
}

class _FloatingReactionAnimationState extends State<FloatingReactionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: Offset(
        widget.startPosition.dx + (50 - 100 * (0.5)), // Random horizontal drift
        widget.startPosition.dy - 100, // Float upward
      ),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx - 20,
          top: _positionAnimation.value.dy - 20,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Lottie.asset(
                  _getLottieAssetPath(widget.reactionType),
                  repeat: false,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLottieAssetPath(ReactionType reactionType) {
    switch (reactionType) {
      case ReactionType.heart:
        return 'assets/lottie/reaction_heart.json';
      case ReactionType.supportive:
        return 'assets/lottie/reaction_supportive.json';
      case ReactionType.inspiring:
        return 'assets/lottie/reaction_inspiring.json';
      case ReactionType.celebrate:
        return 'assets/lottie/reaction_celebrate.json';
      case ReactionType.empathy:
        return 'assets/lottie/reaction_empathy.json';
      case ReactionType.strength:
        return 'assets/lottie/reaction_strength.json';
    }
  }
}

// Helper widget for batch reactions (like Instagram/Facebook)
class BatchReactionAnimation extends StatefulWidget {
  final List<ReactionType> reactions;
  final Offset startPosition;
  final VoidCallback? onComplete;

  const BatchReactionAnimation({
    super.key,
    required this.reactions,
    required this.startPosition,
    this.onComplete,
  });

  @override
  State<BatchReactionAnimation> createState() => _BatchReactionAnimationState();
}

class _BatchReactionAnimationState extends State<BatchReactionAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _positionAnimations;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startStaggeredAnimations();
  }

  void _initializeAnimations() {
    _controllers = [];
    _positionAnimations = [];
    _scaleAnimations = [];
    _opacityAnimations = [];

    for (int i = 0; i < widget.reactions.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );
      _controllers.add(controller);

      // Stagger positions in a circle pattern
      final angle = (2 * math.pi / widget.reactions.length) * i;
      final radius = 60.0;
      final endPosition = Offset(
        widget.startPosition.dx + radius * math.cos(angle),
        widget.startPosition.dy + radius * math.sin(angle) - 50,
      );

      _positionAnimations.add(
        Tween<Offset>(
          begin: widget.startPosition,
          end: endPosition,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.elasticOut,
        )),
      );

      _scaleAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
          ),
        ),
      );

      _opacityAnimations.add(
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 30),
          TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 40),
          TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
        ]).animate(controller),
      );
    }
  }

  void _startStaggeredAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].forward().then((_) {
            if (i == _controllers.length - 1) {
              widget.onComplete?.call();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.reactions.length, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Positioned(
              left: _positionAnimations[index].value.dx - 20,
              top: _positionAnimations[index].value.dy - 20,
              child: Transform.scale(
                scale: _scaleAnimations[index].value,
                child: Opacity(
                  opacity: _opacityAnimations[index].value,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Lottie.asset(
                      _getLottieAssetPath(widget.reactions[index]),
                      repeat: false,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _getLottieAssetPath(ReactionType reactionType) {
    switch (reactionType) {
      case ReactionType.heart:
        return 'assets/lottie/reaction_heart.json';
      case ReactionType.supportive:
        return 'assets/lottie/reaction_supportive.json';
      case ReactionType.inspiring:
        return 'assets/lottie/reaction_inspiring.json';
      case ReactionType.celebrate:
        return 'assets/lottie/reaction_celebrate.json';
      case ReactionType.empathy:
        return 'assets/lottie/reaction_empathy.json';
      case ReactionType.strength:
        return 'assets/lottie/reaction_strength.json';
    }
  }
}