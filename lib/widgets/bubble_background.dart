import 'package:flutter/material.dart';

enum BubbleStyle { splash, onboarding, login }

class BubbleData {
  final double size;
  final double dx; // 0.0–1.0
  final double dy; // 0.0–1.0
  final double opacity;
  final double speed;
  final double floatRange;

  const BubbleData({
    required this.size,
    required this.dx,
    required this.dy,
    required this.opacity,
    this.speed = 1.0,
    this.floatRange = 12,
  });
}


class BubbleBackground extends StatefulWidget {
  final Widget child;
  final BubbleStyle style;

  const BubbleBackground({
    super.key,
    required this.child,
    this.style = BubbleStyle.onboarding,
  });

  @override
  State<BubbleBackground> createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<BubbleBackground>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

    static const _splashBubbles = [
    BubbleData(size: 120, dx: 0.05, dy: 0.03,  opacity: 0.30, speed: 0.7, floatRange: 14),
    BubbleData(size: 90,  dx: 0.55, dy: 0.01,  opacity: 0.22, speed: 1.1, floatRange: 10),
    BubbleData(size: 160, dx: 0.25, dy: 0.18,  opacity: 0.18, speed: 0.8, floatRange: 18),
    BubbleData(size: 200, dx: 0.60, dy: 0.30,  opacity: 0.15, speed: 0.6, floatRange: 20),
    BubbleData(size: 130, dx: -0.05,dy: 0.55,  opacity: 0.20, speed: 0.9, floatRange: 14),
    BubbleData(size: 100, dx: 0.80, dy: 0.60,  opacity: 0.25, speed: 1.2, floatRange: 10),
    BubbleData(size: 180, dx: 0.10, dy: 0.78,  opacity: 0.18, speed: 0.7, floatRange: 16),
    BubbleData(size: 140, dx: 0.70, dy: 0.85,  opacity: 0.20, speed: 1.0, floatRange: 12),
    BubbleData(size: 80,  dx: 0.40, dy: 0.92,  opacity: 0.15, speed: 1.3, floatRange: 8),
  ];

  static const _onboardBubbles = [
    BubbleData(size: 220, dx: 0.10, dy: 0.10, opacity: 0.55, speed: 0.6, floatRange: 10),
    BubbleData(size: 190, dx: 0.45, dy: 0.05, opacity: 0.50, speed: 0.8, floatRange: 12),
    BubbleData(size: 200, dx: 0.70, dy: 0.15, opacity: 0.45, speed: 0.7, floatRange: 14),
    BubbleData(size: 230, dx: 0.25, dy: 0.28, opacity: 0.55, speed: 0.65,floatRange: 10),
    BubbleData(size: 210, dx: 0.55, dy: 0.32, opacity: 0.50, speed: 0.75,floatRange: 12),
    BubbleData(size: 180, dx: 0.05, dy: 0.42, opacity: 0.45, speed: 0.85,floatRange: 8),
    BubbleData(size: 200, dx: 0.40, dy: 0.50, opacity: 0.55, speed: 0.70,floatRange: 14),
    BubbleData(size: 100, dx: 0.05, dy: 0.75, opacity: 0.40, speed: 1.0, floatRange: 8),
    BubbleData(size: 110, dx: 0.65, dy: 0.76, opacity: 0.40, speed: 0.9, floatRange: 8),
    BubbleData(size: 70,  dx: 0.20, dy: 0.85, opacity: 0.35, speed: 1.1, floatRange: 6),
    BubbleData(size: 80,  dx: 0.55, dy: 0.88, opacity: 0.35, speed: 1.2, floatRange: 6),
  ];

  static const _loginBubbles = [
    BubbleData(size: 140, dx: -0.05,dy: 0.01,  opacity: 0.20, speed: 0.8, floatRange: 12),
    BubbleData(size: 100, dx: 0.60, dy: 0.02,  opacity: 0.15, speed: 1.0, floatRange: 10),
    BubbleData(size: 160, dx: 0.20, dy: 0.12,  opacity: 0.18, speed: 0.7, floatRange: 14),
    BubbleData(size: 120, dx: 0.75, dy: 0.20,  opacity: 0.20, speed: 0.9, floatRange: 10),
    BubbleData(size: 150, dx: -0.08,dy: 0.65,  opacity: 0.18, speed: 0.75,floatRange: 12),
    BubbleData(size: 130, dx: 0.80, dy: 0.70,  opacity: 0.20, speed: 1.1, floatRange: 10),
    BubbleData(size: 180, dx: 0.30, dy: 0.82,  opacity: 0.15, speed: 0.65,floatRange: 16),
    BubbleData(size: 110, dx: 0.70, dy: 0.88,  opacity: 0.18, speed: 0.9, floatRange: 8),
  ];

  List<BubbleData> get _bubbles {
    switch (widget.style) {
      case BubbleStyle.splash:
        return _splashBubbles;
      case BubbleStyle.onboarding:
        return _onboardBubbles;
      case BubbleStyle.login:
        return _loginBubbles;
    }
  }

  Color _getBubbleColor(double opacity) {
    switch (widget.style) {
      case BubbleStyle.splash:
      case BubbleStyle.login:
        return Colors.white.withOpacity(opacity);
      case BubbleStyle.onboarding:
        return const Color(0xFF90C8F5).withOpacity(opacity);
    }
  }

  Color get _backgroundColor {
    switch (widget.style) {
      case BubbleStyle.splash:
      case BubbleStyle.login:
        return const Color(0xFF4AABF7);
      case BubbleStyle.onboarding:
        return const Color(0xFFF0F4F8);
    }
  }

  @override
  void initState() {
    super.initState();
    final bubbles = _bubbles;

    _controllers = List.generate(bubbles.length, (i) {
      final ms = (6000 / bubbles[i].speed).round();
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: ms),
      )..repeat(reverse: true);
    });

    _anims = List.generate(bubbles.length, (i) {
      return Tween<double>(begin: -1.0, end: 1.0).animate(
        CurvedAnimation(parent: _controllers[i], curve: Curves.easeInOut),
      );
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bubbles = _bubbles;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: _backgroundColor,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          ...List.generate(bubbles.length, (i) {
            return _FloatingBubble(
              animation: _anims[i],
              data: bubbles[i],
              color: _getBubbleColor(bubbles[i].opacity),
              screenW: size.width,
              screenH: size.height,
            );
          }),

          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

class _FloatingBubble extends AnimatedWidget {
  final BubbleData data;
  final Color color;
  final double screenW;
  final double screenH;

  const _FloatingBubble({
    required Animation<double> animation,
    required this.data,
    required this.color,
    required this.screenW,
    required this.screenH,
  }) : super(listenable: animation);

  Animation<double> get _anim => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final offsetY = _anim.value * data.floatRange;

    return Positioned(
      left: data.dx * screenW - data.size / 2,
      top:  data.dy * screenH - data.size / 2 + offsetY,
      child: Container(
        width: data.size,
        height: data.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}