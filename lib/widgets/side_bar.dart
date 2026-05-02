import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/token_manager.dart';
import '../../../core/theme/theme_provider.dart';
import '../core/theme/language_provider.dart';
import '../pages/login_screen.dart';
import '../pages/student/settings/privacypolicyscreen.dart';
import '../pages/student/settings/complaints_screen.dart';
import '../pages/student/settings/notification.dart';

class StudentSettingsSideBar extends StatefulWidget {
  const StudentSettingsSideBar({super.key});

  @override
  State<StudentSettingsSideBar> createState() => _StudentSettingsSideBarState();
}

class _StudentSettingsSideBarState extends State<StudentSettingsSideBar> {
  bool _isObscureOld = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    // استدعاء المدراء (ثيم ولغة)
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.82,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // 1. الهيدر الفخم
            _buildHeader(isAr),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── قسم المظهر واللغة ──
                  _sectionTitle(isAr ? "المظهر واللغة" : "Appearance & Language"),
                  _buildSectionCard([
                    SwitchListTile(
                      activeColor: AppColors.primaryBlue,
                      title: Text(isAr ? "الوضع الليلي" : "Dark Mode",
                          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 14)),
                      secondary: Icon(
                        themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: AppColors.primaryBlue,
                      ),
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (bool value) => themeProvider.toggleTheme(value),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ListTile(
                      leading: const Icon(Icons.language_rounded, color: AppColors.primaryBlue),
                      title: Text(isAr ? "لغة التطبيق" : "App Language",
                          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: Text(isAr ? "العربية" : "English",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      onTap: () => langProvider.changeLanguage(isAr ? 'en' : 'ar'),
                    ),
                  ]),

                  const SizedBox(height: 25),

                  // ── قسم الأمان ──
                  _sectionTitle(isAr ? "الأمان والحساب" : "Security & Account"),
                  _buildSectionCard([
                    _buildMenuItem(context, Icons.lock_reset_rounded, isAr ? "تغيير كلمة المرور" : "Change Password",
                            () => _showChangePasswordModal(context, isAr)),
                  ]),

                  const SizedBox(height: 25),

                  // ── قسم التواصل ──
                  _sectionTitle(isAr ? "التواصل" : "Communication"),
                  _buildSectionCard([
                    _buildMenuItem(context, Icons.notifications_active_outlined, isAr ? "مركز الإشعارات" : "Notifications",
                            () => Navigator.push(context, MaterialPageRoute(builder: (c) => const NotificationsScreen()))),
                  ]),

                  const SizedBox(height: 25),

                  // ── قسم الدعم ──
                  _sectionTitle(isAr ? "الدعم والمعلومات" : "Support & Info"),
                  _buildSectionCard([
                    _buildMenuItem(context, Icons.support_agent_rounded, isAr ? "الدعم والشكاوى" : "Complaints",
                            () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ComplaintsScreen()))),
                    const Divider(height: 1, indent: 50),
                    _buildMenuItem(context, Icons.privacy_tip_outlined, isAr ? "سياسة الخصوصية" : "Privacy Policy",
                            () => Navigator.push(context, MaterialPageRoute(builder: (c) => const PrivacyPolicyScreen()))),
                  ]),
                ],
              ),
            ),

            // 3. زر تسجيل الخروج
            _buildLogoutButton(context, isAr),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isAr) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
    decoration: const BoxDecoration(
      gradient: AppColors.splashGradient,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 30)),
        const SizedBox(height: 20),
        Text(isAr ? "إعدادات الحساب" : "Account Settings",
            style: GoogleFonts.tajawal(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(isAr ? "إدارة الخصوصية والمظهر" : "Manage Privacy & Theme", style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    ),
  );

  Widget _buildSectionCard(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: Column(children: children),
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(right: 10, bottom: 10),
    child: Text(title, style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
  );

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) => ListTile(
    onTap: () {
      if (title != (Provider.of<LanguageProvider>(context, listen: false).locale.languageCode == 'ar' ? "تغيير كلمة المرور" : "Change Password")) {
        Navigator.pop(context);
      }
      onTap();
    },
    leading: Icon(icon, color: AppColors.primaryBlue, size: 22),
    title: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 14)),
    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
  );

  Widget _buildLogoutButton(BuildContext context, bool isAr) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ElevatedButton.icon(
      onPressed: () => _showLogoutDialog(context, isAr),
      icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
      label: Text(isAr ? "تسجيل الخروج" : "Logout", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent.shade400,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
    ),
  );

  void _showChangePasswordModal(BuildContext context, bool isAr) {
    final oldP = TextEditingController();
    final newP = TextEditingController();
    final confirmP = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom + 20, left: 25, right: 25, top: 20),
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(40))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              Text(isAr ? "تحديث كلمة المرور" : "Update Password", style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              _passInput(isAr ? "الحالية" : "Current", oldP, _isObscureOld, () => setModalState(() => _isObscureOld = !_isObscureOld)),
              _passInput(isAr ? "الجديدة" : "New", newP, _isObscureNew, () => setModalState(() => _isObscureNew = !_isObscureNew)),
              _passInput(isAr ? "تأكيد الجديدة" : "Confirm New", confirmP, _isObscureConfirm, () => setModalState(() => _isObscureConfirm = !_isObscureConfirm)),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                    onPressed: () async {
                      if (newP.text != confirmP.text) return;
                      await ApiService().changePassword(oldP.text, newP.text, confirmP.text);
                      Navigator.pop(c);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: const StadiumBorder()),
                    child: Text(isAr ? "تحديث الآن" : "Update Now", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passInput(String label, TextEditingController ctrl, bool obscure, VoidCallback onToggle) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
            suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onToggle),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
  );

  void _showLogoutDialog(BuildContext context, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
            const SizedBox(height: 15),
            Text(isAr ? "هل تود تسجيل الخروج فعلاً؟" : "Are you sure you want to logout?", textAlign: TextAlign.center),
            const SizedBox(height: 25),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? "إلغاء" : "Cancel"))),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        await TokenManager.clearToken();
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (c) => const LoginScreen()), (r) => false);
                      },
                      child: Text(isAr ? "خروج" : "Exit", style: const TextStyle(color: Colors.white)))),
            ]),
          ],
        ),
      ),
    );
  }
}
