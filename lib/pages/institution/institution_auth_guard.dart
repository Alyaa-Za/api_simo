import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';
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
  State<InstitutionMainWrapper> createState() => InstitutionMainWrapperState();
}

class InstitutionMainWrapperState extends State<InstitutionMainWrapper> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  void jumpToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    final String currentStatus = widget.profile?['status'] ?? 'pending_approval';
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
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // القائمة الجانبية مَسْطرة ملان العين
        endDrawer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: const InstitutionSettings(),
        ),

        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,

          // ── [تثبيت اللون الأزرق مَسْطرة] ──
          // حذفنا شرط isDark لكي يظل التدرج اللوني ثابتاً في كل الأوضاع
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.splashGradient, // يظل أزرق دائماً كما طلبتِ
            ),
          ),

          // أيقونة اللوجو (تظهر في الهوم فقط)
          leading: _currentIndex == 0
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24)
              ),
              child: ClipOval(child: Image.asset('assets/images/logo.png', fit: BoxFit.cover)),
            ),
          )
              : null,

          title: Text(
            _currentIndex == 0 ? (isAr ? 'مرحباً بك' : 'Welcome') : _getPageTitle(isAr),
            style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),

          actions: [
            if (_currentIndex == 4)
              Builder(
                builder: (innerContext) => IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 26),
                  onPressed: () {
                    Scaffold.of(innerContext).openEndDrawer();
                  },
                ),
              ),
            const SizedBox(width: 10),
          ],
        ),

        body: Stack(
          children: [
            IndexedStack(index: _currentIndex, children: _pages),
            _buildFloatingNavBar(),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(bool isAr) {
    switch (_currentIndex) {
      case 1: return isAr ? "إدارة الفرص" : "Opportunities";
      case 2: return isAr ? "طلبات المتقدمين" : "Applications";
      case 3: return isAr ? "المتابعة والتقييم" : "Evaluation";
      case 4: return isAr ? "الملف الشخصي" : "My Profile";
      default: return "";
    }
  }

  Widget _buildFloatingNavBar() {
    return Positioned(
      bottom: 25, left: 20, right: 20,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
            gradient: AppColors.buttonGradient, // يظل التدرج الأزرق ثابتاً
            borderRadius: BorderRadius.circular(35),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15)]
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
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
            shape: BoxShape.circle
        ),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.white60, size: 26),
      ),
    );
  }
}
