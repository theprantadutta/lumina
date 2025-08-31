import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Accessibility service for WCAG compliance
class AccessibilityService {
  /// Check if high contrast is enabled
  static bool get isHighContrastEnabled {
    return WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.highContrast;
  }

  /// Check if bold text is enabled
  static bool get isBoldTextEnabled {
    return WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.boldText;
  }

  /// Check if reduce motion is enabled
  static bool get isReduceMotionEnabled {
    return WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.reduceMotion;
  }

  /// Check if large text is enabled
  static bool get isLargeTextEnabled {
    return WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.accessibleNavigation;
  }

  /// Get appropriate text scale factor
  static double getTextScaleFactor(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaler.scale(14) / 14;
    
    // Ensure minimum readable size
    return textScaleFactor.clamp(0.8, 3.0);
  }

  /// Provide semantic label for mood values
  static String getMoodSemanticLabel(double moodValue) {
    if (moodValue <= 2) {
      return 'Very low mood, value ${moodValue.toStringAsFixed(1)} out of 10';
    } else if (moodValue <= 4) {
      return 'Low mood, value ${moodValue.toStringAsFixed(1)} out of 10';
    } else if (moodValue <= 6) {
      return 'Neutral mood, value ${moodValue.toStringAsFixed(1)} out of 10';
    } else if (moodValue <= 8) {
      return 'Good mood, value ${moodValue.toStringAsFixed(1)} out of 10';
    } else {
      return 'Excellent mood, value ${moodValue.toStringAsFixed(1)} out of 10';
    }
  }

  /// Provide semantic label for dates
  static String getDateSemanticLabel(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today, ${_formatDateForSemantic(date)}';
    } else if (difference == 1) {
      return 'Yesterday, ${_formatDateForSemantic(date)}';
    } else if (difference < 7) {
      return '$difference days ago, ${_formatDateForSemantic(date)}';
    } else {
      return _formatDateForSemantic(date);
    }
  }

  /// Format date for semantic reading
  static String _formatDateForSemantic(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    
    String dayWithSuffix;
    if (day >= 11 && day <= 13) {
      dayWithSuffix = '${day}th';
    } else {
      switch (day % 10) {
        case 1:
          dayWithSuffix = '${day}st';
          break;
        case 2:
          dayWithSuffix = '${day}nd';
          break;
        case 3:
          dayWithSuffix = '${day}rd';
          break;
        default:
          dayWithSuffix = '${day}th';
      }
    }
    
    return '$month $dayWithSuffix, $year';
  }

  /// Provide haptic feedback based on mood value
  static void provideMoodHapticFeedback(double moodValue) {
    if (moodValue <= 3) {
      HapticFeedback.heavyImpact();
    } else if (moodValue <= 7) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  /// Get appropriate animation duration based on reduce motion setting
  static Duration getAnimationDuration({
    Duration normal = const Duration(milliseconds: 300),
    Duration reduced = const Duration(milliseconds: 100),
  }) {
    return isReduceMotionEnabled ? reduced : normal;
  }

  /// Check if color contrast is sufficient for WCAG AA
  static bool hasGoodContrast(Color foreground, Color background) {
    final luminance1 = foreground.computeLuminance();
    final luminance2 = background.computeLuminance();
    
    final ratio = (luminance1 > luminance2)
        ? (luminance1 + 0.05) / (luminance2 + 0.05)
        : (luminance2 + 0.05) / (luminance1 + 0.05);
    
    return ratio >= 4.5; // WCAG AA standard
  }

  /// Get high contrast color variants
  static Color getHighContrastColor(Color original, {bool isDark = false}) {
    if (!isHighContrastEnabled) return original;
    
    return isDark ? Colors.white : Colors.black;
  }

  /// Announce important changes to screen readers
  static void announceToScreenReader(String message, BuildContext context) {
    if (Navigator.maybeOf(context) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 100), // Very brief
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Accessible button widget with proper semantics
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? tooltip;
  final bool isEnabled;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.tooltip,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: tooltip,
      button: true,
      enabled: isEnabled,
      child: Tooltip(
        message: tooltip ?? semanticLabel,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 44.0,
                minHeight: 44.0,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Accessible slider for mood input
class AccessibleMoodSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int divisions;

  const AccessibleMoodSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1.0,
    this.max = 10.0,
    this.divisions = 9,
  });

  @override
  State<AccessibleMoodSlider> createState() => _AccessibleMoodSliderState();
}

class _AccessibleMoodSliderState extends State<AccessibleMoodSlider> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mood rating slider',
      hint: 'Swipe left to decrease, right to increase. Current value: ${AccessibilityService.getMoodSemanticLabel(widget.value)}',
      value: AccessibilityService.getMoodSemanticLabel(widget.value),
      increasedValue: AccessibilityService.getMoodSemanticLabel((widget.value + 1).clamp(widget.min, widget.max)),
      decreasedValue: AccessibilityService.getMoodSemanticLabel((widget.value - 1).clamp(widget.min, widget.max)),
      onIncrease: () {
        final newValue = (widget.value + 1).clamp(widget.min, widget.max);
        widget.onChanged(newValue);
        AccessibilityService.provideMoodHapticFeedback(newValue);
      },
      onDecrease: () {
        final newValue = (widget.value - 1).clamp(widget.min, widget.max);
        widget.onChanged(newValue);
        AccessibilityService.provideMoodHapticFeedback(newValue);
      },
      child: Slider(
        value: widget.value,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        onChanged: (value) {
          widget.onChanged(value);
          AccessibilityService.provideMoodHapticFeedback(value);
        },
        semanticFormatterCallback: (double value) {
          return AccessibilityService.getMoodSemanticLabel(value);
        },
      ),
    );
  }
}

/// Accessible card with proper focus management
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      constraints: const BoxConstraints(
        minHeight: 44.0,
      ),
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Semantics(
        label: semanticLabel,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: cardContent,
          ),
        ),
      );
    }

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// Focus management helper
class FocusHelper {
  /// Focus the next widget in sequence
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Focus the previous widget in sequence
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Unfocus current widget
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Request focus on a specific node
  static void requestFocus(BuildContext context, FocusNode node) {
    FocusScope.of(context).requestFocus(node);
  }
}

/// Accessible text with proper contrast
class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticLabel;

  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScaleFactor = AccessibilityService.getTextScaleFactor(context);
    
    TextStyle effectiveStyle = style ?? theme.textTheme.bodyMedium!;
    
    // Adjust for high contrast mode
    if (AccessibilityService.isHighContrastEnabled) {
      effectiveStyle = effectiveStyle.copyWith(
        color: AccessibilityService.getHighContrastColor(
          effectiveStyle.color ?? theme.textTheme.bodyMedium!.color!,
          isDark: theme.brightness == Brightness.dark,
        ),
      );
    }
    
    // Adjust for bold text
    if (AccessibilityService.isBoldTextEnabled) {
      effectiveStyle = effectiveStyle.copyWith(
        fontWeight: FontWeight.bold,
      );
    }

    return Semantics(
      label: semanticLabel,
      child: Text(
        text,
        style: effectiveStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        textScaler: TextScaler.linear(textScaleFactor),
      ),
    );
  }
}

/// Keyboard navigation helper
class KeyboardNavigationHelper extends StatelessWidget {
  final Widget child;
  final Map<LogicalKeySet, Intent>? shortcuts;

  const KeyboardNavigationHelper({
    super.key,
    required this.child,
    this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    final Map<LogicalKeySet, Intent> defaultShortcuts = {
      LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
      LogicalKeySet(LogicalKeyboardKey.tab): const NextFocusIntent(),
      LogicalKeySet(LogicalKeyboardKey.tab, LogicalKeyboardKey.shift): const PreviousFocusIntent(),
    };

    return Shortcuts(
      shortcuts: {...defaultShortcuts, ...?shortcuts},
      child: Actions(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent intent) {
              // Handle activation
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}