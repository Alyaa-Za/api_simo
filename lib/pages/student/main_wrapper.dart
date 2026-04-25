import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/ui/app_color.dart';
import '../../core/token_manager.dart';
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
    final List<Widget> pages = [
      StudentHomeScreen(onSeeAllPressed: () => _jumpToTab(1)),
      const ExploreScreen(),
      const InternshipScreen(),
      const ApplicationsScreen(),
      const StudentProfileScreen(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),

        endDrawer: _currentIndex == 4 ? const StudentSettingsSideBar() : null,

        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          centerTitle: true,
          actions: [
            if (_currentIndex == 4)
              Builder(builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                );
              })
          ],
          title: _currentIndex == 0
              ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مرحباً بك،', style: GoogleFonts.tajawal(fontSize: 11, color: Colors.white70)),
                  FutureBuilder<String?>(
                    future: TokenManager.getName(),
                    builder: (context, snapshot) {
                      String name = snapshot.data ?? "جارِ التحميل..";
                      return Text(
                          name,
                          style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)
                      );
                    },
                  ),
                ],
              ),
              Container(
                height: 42, width: 42,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.5)
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.business, color: Colors.white),
                  ),
                ),
              ),
            ],
          )
              : Text(
              _getPageTitle(),
              style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)
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

  String _getPageTitle() {
    switch (_currentIndex) {
      case 1: return "استكشاف الفرص";
      case 2: return "تدريبي الحالي";
      case 3: return "طلبات التقديم";
      case 4: return "ملفي الشخصي";
      default: return "";
    }
  }
}
