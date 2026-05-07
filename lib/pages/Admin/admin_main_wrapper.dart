import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/token_manager.dart';
import '../../../core/api/api_s.dart';
import '../login_screen.dart';
import 'admin_dashboard.dart';
import 'manage_institution.dart';
import 'admin_applicants_request.dart';
import 'internship_monitor.dart';
import 'manage_student.dart';
import 'admin_complaints_screen.dart';

class AdminMainWrapper extends StatefulWidget {
  const AdminMainWrapper({super.key});

  @override
  State<AdminMainWrapper> createState() => AdminMainWrapperState();
}

class AdminMainWrapperState extends State<AdminMainWrapper> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  void jumpToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminDashboard(),
      const ManageInstitutions(), // 1
      const AdminManageStudents(), // 2
      const AdminRequestsScreen(), // 3
      const InternshipMonitor(), // 4
      const AdminComplaintsScreen(), // 5
    ];
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        endDrawer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.82,
          child: Drawer(
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  decoration: const BoxDecoration(
                    gradient: AppColors.splashGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 70, width: 70,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 35),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isAr ? "لوحة تحكم الإدارة" : "Admin Control Panel",
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      Text(
                        isAr ? "نظام TrainEx" : "TrainEx System",
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                _sectionTitle(isAr ? "التفضيلات والنظام" : "Preferences & System", isDark),

                _drawerItem(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  isAr ? "الوضع الليلي" : "Dark Mode",
                  isDark,
                  trailing: Switch(
                    value: isDark,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (val) => themeProvider.toggleTheme(val),
                  ),
                ),

                _drawerItem(
                  Icons.language_rounded,
                  isAr ? "اللغة: العربية" : "Language: English",
                  isDark,
                  onTap: () => langProvider.changeLanguage(isAr ? 'en' : 'ar'),
                ),

                _drawerItem(
                  Icons.info_outline_rounded,
                  isAr ? "عن التطبيق" : "About App",
                  isDark,
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context, isAr, isDark);
                  },
                ),

                const Spacer(),

                const Divider(height: 1, indent: 20, endIndent: 20),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutConfirm(context, isAr, isDark);
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                  title: Text(
                    isAr ? "تسجيل الخروج" : "Logout",
                    style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),

        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: const [SizedBox.shrink()],
          centerTitle: false,
          backgroundColor: AppColors.primaryBlue,
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              children: [
                if (_currentIndex == 0)
                  Container(
                    height: 38, width: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1.5),
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                    ),
                  )
                else
                  const SizedBox(width: 38),

                const Spacer(),

                Text(
                  _currentIndex == 0 ? (isAr ? 'مرحباً بك يا مدير' : 'Welcome Admin') : _getPageTitle(isAr),
                  style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                const Spacer(),

                if (_currentIndex == 0)
                  Builder(builder: (ctx) {
                    return GestureDetector(
                      onTap: () => Scaffold.of(ctx).openEndDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                      ),
                    );
                  })
                else
                  const SizedBox(width: 38),
              ],
            ),
          ),
        ),

        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            _buildFloatingNavBar(),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(bool isAr) {
    switch (_currentIndex) {
      case 1: return isAr ? "إدارة المؤسسات" : "Institutions";
      case 2: return isAr ? "إدارة الطلاب" : "Students";
      case 3: return isAr ? "طلبات التدريب" : "Applications";
      case 4: return isAr ? "مراقبة التدريب" : "Internship Monitor";
      case 5: return isAr ? "الشكاوى والمراسلات" : "Complaints";
      default: return "";
    }
  }

  Widget _buildFloatingNavBar() {
    return Positioned(
      bottom: 25,
      left: 15,
      right: 15,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(0, Icons.dashboard_rounded),
              _navItem(1, Icons.business_rounded),
              _navItem(2, Icons.people_outline),
              _navItem(3, Icons.assignment_turned_in_rounded),
              _navItem(4, Icons.monitor_heart_rounded),
              _navItem(5, Icons.mail_outline_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.white60, size: 22),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 25, left: 25),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white54 : AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, bool isDark, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
      leading: Icon(icon, color: AppColors.primaryBlue, size: 22),
      title: Text(
        title,
        style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
    );
  }

  void _showLogoutConfirm(BuildContext context, bool isAr, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isAr ? "تسجيل الخروج" : "Logout", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        content: Text(isAr ? "هل أنت متأكد من رغبتك في تسجيل الخروج؟" : "Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? "إلغاء" : "Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
              try {
                await ApiService().logout();
                await TokenManager.clearToken();
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                await TokenManager.clearToken();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: const StadiumBorder()),
            child: Text(isAr ? "خروج" : "Logout", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isAr, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(isAr ? "عن المنصة" : "About Platform", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        content: Text(
          isAr
              ? "منصة TrainEx لإدارة التدريب الميداني. تهدف المنصة إلى تسهيل الربط بين الطلاب والجهات التدريبية والجامعة لضمان مسيرة تعليمية ناجحة."
              : "TrainEx Field Training Management Platform. It aims to bridge the gap between students, institutions, and the university.",
          style: GoogleFonts.tajawal(fontSize: 13, height: 1.6),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? "إلغاء" : "Close"))],
      ),
    );
  }
}
