import 'package:flutter/material.dart';
import 'package:lumina/core/theme/app_colors.dart';
import 'package:lumina/core/theme/app_gradients.dart';

class BeautifulBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BeautifulBottomNavItem> items;

  const BeautifulBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<BeautifulBottomNav> createState() => _BeautifulBottomNavState();
}

class _BeautifulBottomNavState extends State<BeautifulBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _itemControllers;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _itemControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    
    // Start the selected item animation
    if (widget.currentIndex < _itemControllers.length) {
      _itemControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(BeautifulBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reset old animation
      if (oldWidget.currentIndex < _itemControllers.length) {
        _itemControllers[oldWidget.currentIndex].reverse();
      }
      // Start new animation
      if (widget.currentIndex < _itemControllers.length) {
        _itemControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == widget.currentIndex;
          
          return Expanded(
            child: _buildNavItem(item, index, isSelected),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(BeautifulBottomNavItem item, int index, bool isSelected) {
    final animation = _itemControllers[index];
    
    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with background
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 48 : 36,
                  height: isSelected ? 48 : 36,
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? AppGradients.primary 
                        : LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.3),
                              Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.1),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(isSelected ? 14 : 10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryPurple.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Transform.scale(
                    scale: 1.0 + (animation.value * 0.05),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected 
                          ? Colors.white 
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: isSelected ? 22 : 20,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 11 : 9,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BeautifulBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BeautifulBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}