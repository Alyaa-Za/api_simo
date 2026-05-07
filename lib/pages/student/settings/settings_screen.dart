import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/token_manager.dart';
import '../../login_screen.dart';
import 'privacypolicyscreen.dart';
import 'complaints_screen.dart';
import 'notification.dart';

class StudentSettingsSideBar extends StatelessWidget {
  const StudentSettingsSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    Icons.notifications_active_outlined,
                    "مركز الإشعارات",
                        () => Navigator.push(context, MaterialPageRoute(builder: (c) => const NotificationsScreen())),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.support_agent_rounded,
                    "الدعم والشكاوى",
                        () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ComplaintsScreen())),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.privacy_tip_outlined,
                    "سياسة الخصوصية",
                        () => Navigator.push(context, MaterialPageRoute(builder: (c) => const PrivacyPolicyScreen())),
                  ),
                ],
              ),
            ),

            _buildLogoutButton(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
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
          child: Icon(Icons.settings_outlined, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 20),
        Text(
          "الإعدادات",
          style: GoogleFonts.tajawal(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Text(
          "إدارة الحساب والأمان",
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) => ListTile(
    onTap: () {
      Navigator.pop(context);
      onTap();
    },
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: AppColors.primaryBlue, size: 20),
    ),
    title: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 14)),
    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
  );

  Widget _buildLogoutButton(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ElevatedButton.icon(
      onPressed: () => _showLogoutDialog,
      icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.white),
      label: Text("تسجيل الخروج", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
    ),
  );

  void _showLogoutDialog(BuildContext context, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
              const SizedBox(height: 15),
              Text(
                isAr ? "هل تود تسجيل الخروج فعلاً؟" : "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: Text(isAr ? "إلغاء" : "Cancel")
                    )
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () async {
                          // 1. إغلاق ديالوج التنبيه فوراً
                          Navigator.pop(ctx);

                          // 2. مسح التوكن محلياً بدون إذن السيرفر لضمان الأمان
                          await TokenManager.clearToken();

                          if (!context.mounted) return;

                          // 3. العودة لصفحة الدخول الموحدة وتصفير السجل
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  (Route<dynamic> route) => false
                          );
                        },
                        child: Text(isAr ? "خروج" : "Exit", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    )
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

}
