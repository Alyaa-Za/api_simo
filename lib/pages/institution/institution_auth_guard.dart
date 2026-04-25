import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import 'institution_home_screen.dart';
import 'opportunities/manage_opportunities.dart';
import 'applicants/applicant_request.dart';
import 'Evaluation/active_intern.dart';
import 'profile/profile_screen.dart';
import 'settings/InstitutionSettings.dart';

class InstitutionMainWrapper extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const InstitutionMainWrapper({super.key, this.profile});

  @override
  State<InstitutionMainWrapper> createState() =>
      _InstitutionMainWrapperState();
}

class _InstitutionMainWrapperState extends State<InstitutionMainWrapper> {
  int _currentIndex = 0;

  bool _showSettings = false;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    final String currentStatus =
        widget.profile?['status'] ?? 'pending_approval';

    _pages = [
      const InstitutionDashboard(),
      ManageOpportunities(accountStatus: currentStatus),
      const ApplicantsRequests(),
      const ActiveInternsList(),
      InstitutionProfile(profile: widget.profile),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),

        appBar: _buildAppBar(),

        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),

            _buildFloatingNavBar(),

            if (_showSettings)
              GestureDetector(
                onTap: () => setState(() => _showSettings = false),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showSettings ? 1 : 0,
                  child: Container(
                    color: Colors.black54,
                  ),
                ),
              ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,

              left: _showSettings
                  ? 0
                  : -MediaQuery.of(context).size.width * 0.85,

              top: 0,
              bottom: 0,

              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Material(
                  color: Colors.white,
                  elevation: 20,
                  child: const InstitutionSettingsSideBar(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    bool isHome = _currentIndex == 0;
    bool isProfile = _currentIndex == 4;

    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,

      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
      ),

      title: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            isHome
                ? Text(
              'مرحباً بك',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
                : Text(
              _getPageTitle(),
              style: GoogleFonts.tajawal(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            if (isProfile)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      _showSettings = true;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 1:
        return "إدارة الفرص";
      case 2:
        return "طلبات المتقدمين";
      case 3:
        return "المتابعة والتقييم";
      case 4:
        return "الملف الشخصي";
      default:
        return "";
    }
  }

  Widget _buildFloatingNavBar() {
    return Positioned(
      bottom: 25,
      left: 20,
      right: 20,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, Icons.dashboard_rounded),
            _navItem(1, Icons.business_center_rounded),
            _navItem(2, Icons.group_add_rounded),
            _navItem(3, Icons.people_alt_rounded),
            _navItem(4, Icons.account_circle_rounded),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white60,
        size: 28,
      ),
    );
  }
}