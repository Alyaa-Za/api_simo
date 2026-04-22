import 'package:flutter/material.dart';
import '../core/ui/app_color.dart';

class FloatingNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(5, (index) => AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    ));
    _controllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(covariant FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryBlueDark]),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: [
            _navItem(0, Icons.home),
            _navItem(1, Icons.search),
            _navItem(2, Icons.description),
            _navItem(3, Icons.work),
            _navItem(4, Icons.person),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(int index, IconData icon) {
    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: _controllers[index],
        builder: (context, child) {
          final scale = 1.0 + _controllers[index].value * 0.2;
          final opacity = 1.0 - _controllers[index].value * 0.3;
          return Transform.scale(
            scale: scale,
            child: Icon(icon, color: Colors.white.withOpacity(opacity), size: 24 + _controllers[index].value * 4),
          );
        },
      ),
      label: '',
    );
  }
}