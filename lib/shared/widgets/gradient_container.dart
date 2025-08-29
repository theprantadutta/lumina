import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GradientContainer({
    super.key,
    required this.child,
    required this.gradient,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

class AnimatedGradientContainer extends StatefulWidget {
  final Widget child;
  final List<Gradient> gradients;
  final Duration duration;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const AnimatedGradientContainer({
    super.key,
    required this.child,
    required this.gradients,
    this.duration = const Duration(seconds: 3),
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.boxShadow,
  });

  @override
  State<AnimatedGradientContainer> createState() =>
      _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends State<AnimatedGradientContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.gradients.length;
        });
        _controller.reset();
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentGradient = widget.gradients[_currentIndex];
        final nextGradient = widget
            .gradients[(_currentIndex + 1) % widget.gradients.length];

        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: _lerpGradient(
              currentGradient,
              nextGradient,
              _animation.value,
            ),
            borderRadius: widget.borderRadius,
            border: widget.border,
            boxShadow: widget.boxShadow,
          ),
          child: widget.child,
        );
      },
    );
  }

  Gradient _lerpGradient(Gradient a, Gradient b, double t) {
    if (a is LinearGradient && b is LinearGradient) {
      return LinearGradient(
        begin: AlignmentGeometry.lerp(a.begin, b.begin, t)!,
        end: AlignmentGeometry.lerp(a.end, b.end, t)!,
        colors: _lerpColorList(a.colors, b.colors, t),
        stops: a.stops != null && b.stops != null
            ? _lerpStops(a.stops!, b.stops!, t)
            : null,
      );
    }
    return LinearGradient(
      colors: [
        Color.lerp(Colors.blue, Colors.purple, t)!,
        Color.lerp(Colors.purple, Colors.pink, t)!,
      ],
    );
  }

  List<Color> _lerpColorList(List<Color> a, List<Color> b, double t) {
    final length = a.length > b.length ? a.length : b.length;
    return List.generate(length, (index) {
      final colorA = index < a.length ? a[index] : a.last;
      final colorB = index < b.length ? b[index] : b.last;
      return Color.lerp(colorA, colorB, t)!;
    });
  }

  List<double> _lerpStops(List<double> a, List<double> b, double t) {
    final length = a.length > b.length ? a.length : b.length;
    return List.generate(length, (index) {
      final stopA = index < a.length ? a[index] : a.last;
      final stopB = index < b.length ? b[index] : b.last;
      return stopA + (stopB - stopA) * t;
    });
  }
}