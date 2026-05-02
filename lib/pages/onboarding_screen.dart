import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../widgets/bubble_background.dart';
import '../../../core/theme/language_provider.dart';
import '../../../core/theme/theme_provider.dart';
import 'login_screen.dart';

class _PageData {
  final String titleAr, titleEn;
  final String descAr, descEn;
  final IconData icon;

  const _PageData({
    required this.titleAr, required this.titleEn,
    required this.descAr, required this.descEn,
    required this.icon,
  });
}

const List<_PageData> _pages = [
  _PageData(
    titleAr: 'اكتشف الفرص', titleEn: 'Discover Opportunities',
    descAr: 'اكتشف أفضل فرص التدريب التي توفرها المؤسسات الرائدة',
    descEn: 'Discover the best training opportunities from leading institutions',
    icon: Icons.search_rounded,
  ),
  _PageData(
    titleAr: 'تقدم بطلبك بسهولة', titleEn: 'Apply Easily',
    descAr: 'أرسل طلباتك ببضع نقرات فقط',
    descEn: 'Send your applications with just a few clicks',
    icon: Icons.send_rounded,
  ),
  _PageData(
    titleAr: 'تتبع تقدمك', titleEn: 'Track Your Progress',
    descAr: 'تابع مسيرتك في التدريب من البداية إلى النهاية',
    descEn: 'Track your training journey from start to finish',
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
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
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
    final langProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        // ── [تعديل مَسْطرة] ── جعل لون الخلفية يتبع الثيم الحقيقي للجهاز
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Container(
          // في اللايت نعطيها لون ناعم مائل للزرقة، وفي الدارك تظل سوداء بالكامل
          color: isDark ? null : const Color(0xFFF4F7FF),
          child: BubbleBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _circleBtn(isDark ? Icons.light_mode : Icons.dark_mode,
                                    () => themeProvider.toggleTheme(!isDark)
                            ),
                            const SizedBox(width: 8),
                            _circleBtn(Icons.language,
                                    () => langProvider.changeLanguage(isAr ? 'en' : 'ar'),
                                label: isAr ? "EN" : "AR"
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _toLogin,
                          child: Text(isAr ? 'تخطي' : 'Skip',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF3D9BF0)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemCount: _pages.length,
                      itemBuilder: (_, i) => _OnboardPage(data: _pages[i], isAr: isAr, isDark: isDark),
                    ),
                  ),

                  _Dots(count: _pages.length, current: _current),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: _BigButton(
                      label: _current == _pages.length - 1 ? (isAr ? 'ابدأ' : 'Start') : (isAr ? 'التالي' : 'Next'),
                      onTap: _next,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, {String? label}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: const Color(0xFF3D9BF0).withOpacity(0.1), shape: BoxShape.circle),
      child: Center(
        child: label != null
            ? Text(label, style: const TextStyle(color: Color(0xFF3D9BF0), fontWeight: FontWeight.bold, fontSize: 11))
            : Icon(icon, color: const Color(0xFF3D9BF0), size: 18),
      ),
    ),
  );
}

class _OnboardPage extends StatelessWidget {
  final _PageData data;
  final bool isAr;
  final bool isDark;

  const _OnboardPage({required this.data, required this.isAr, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Stack(
            alignment: Alignment.center,
            children: [Icon(data.icon, size: 72, color: const Color(0xFF3D9BF0))],
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
                Text(isAr ? data.titleAr : data.titleEn,
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(isAr ? data.descAr : data.descEn,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: isDark ? Colors.white60 : const Color(0xFF7A8599), height: 1.6),
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
          width: isActive ? 24 : 8, height: 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3D9BF0) : const Color(0xFFBBD6F0),
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
        width: double.infinity, height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF3D9BF0), borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF3D9BF0).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}
