import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/bubble_background.dart';
import 'login_screen.dart';

class _PageData {
  final String title;
  final String description;
  final IconData icon;

  const _PageData({
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<_PageData> _pages = [
  _PageData(
    title: 'اكتشف الفرص',
    description: 'اكتشف أفضل فرص التدريب التي توفرها المؤسسات الرائدة',
    icon: Icons.search_rounded,
  ),
  _PageData(
    title: 'تقدم بطلبك بسهولة',
    description: 'أرسل طلباتك ببضع نقرات فقط',
    icon: Icons.send_rounded,
  ),
  _PageData(
    title: 'تتبع تقدمك',
    description: 'تابع مسيرتك في التدريب من البداية إلى النهاية',
    icon: Icons.track_changes_rounded,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _current = 0;

  void _next() {
    if (_current < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      _toLogin();
    }
  }

  void _toLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BubbleBackground(
        style: BubbleStyle.onboarding,
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip ──────────────────────────────────────
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20, top: 12),
                  child: TextButton(
                    onPressed: _toLogin,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3D9BF0),
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _OnboardPage(data: _pages[i]),
                ),
              ),

              _Dots(count: _pages.length, current: _current),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: _BigButton(
                  label: _current == _pages.length - 1
                      ? 'Get Started'
                      : 'Next',
                  onTap: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _OnboardPage extends StatelessWidget {
  final _PageData data;

  const _OnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                data.icon,
                size: 72,
                color: const Color(0xFF3D9BF0),
              ),
            ],
          ),
        ),

        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  data.title,
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  data.description,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF7A8599),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
class _Dots extends StatelessWidget {
  final int count;
  final int current;

  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF3D9BF0)
                : const Color(0xFFBBD6F0),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _BigButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF3D9BF0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D9BF0).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}