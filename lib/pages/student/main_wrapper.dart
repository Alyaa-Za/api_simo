import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/ui/app_color.dart';
import '../../core/token_manager.dart';
import '../../core/theme/language_provider.dart';
import '../../widgets/side_bar.dart';
import 'applications/applications_screen.dart';
import 'explore/explore_screen.dart';
import 'internship/internship_screen.dart';
import 'profile/profile_screen.dart';
import '../../widgets/floating_nav_bar.dart';
import 'student_home_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  void _jumpToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      StudentHomeScreen(onSeeAllPressed: () => _jumpToTab(1)),
      const ExploreScreen(),
      const InternshipScreen(),
      const ApplicationsScreen(),
      const StudentProfileScreen(),
    ];

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        endDrawer: (_currentIndex == 4) ? const StudentSettingsSideBar() : null,

        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.primaryBlue,
          elevation: 0,
          centerTitle: true,

          automaticallyImplyLeading: false,

          actions: [
            if (_currentIndex == 4)
              Builder(builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              }),
            const SizedBox(width: 10),
          ],

          title: _currentIndex == 0
              ? _buildHomeHeader(isAr)
              : Text(
              _getPageTitle(isAr),
              style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17
              )
          ),
        ),

        body: pages[_currentIndex],

        bottomNavigationBar: FloatingNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }

  Widget _buildHomeHeader(bool isAr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAr ? 'مرحباً بك،' : 'Welcome,',
                style: GoogleFonts.tajawal(fontSize: 11, color: Colors.white70)),
            FutureBuilder<String?>(
              future: TokenManager.getName(),
              builder: (context, snapshot) {
                String name = snapshot.data ?? (isAr ? "تحميل.." : "Loading..");
                return Text(
                    name,
                    style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)
                );
              },
            ),
          ],
        ),
        Container(
          height: 38, width: 38,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5)
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.account_circle, color: Colors.white, size: 25),
            ),
          ),
        ),
      ],
    );
  }

  String _getPageTitle(bool isAr) {
    switch (_currentIndex) {
      case 1: return isAr ? "استكشاف الفرص" : "Explore Opportunities";
      case 2: return isAr ? "تدريبي الحالي" : "My Internship";
      case 3: return isAr ? "طلبات التقديم" : "Applications";
      case 4: return isAr ? "ملفي الشخصي" : "My Profile";
      default: return "";
    }
  }
}
