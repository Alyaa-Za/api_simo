import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/token_manager.dart';

class AdminSettings extends StatelessWidget {
  const AdminSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Drawer(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        child: Column(
          children: [
            // ── هيدر السايد بار الفخم ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: AppColors.splashGradient,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    height: 80, width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    isAr ? "لوحة تحكم الإدارة" : "Admin Dashboard",
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isAr ? "نظام TrainEx" : "TrainEx System",
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── قائمة الإعدادات ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: [
                  _sectionTitle(isAr ? "التفضيلات" : "Preferences", isDark),

                  // تعديل الثيم
                  _buildOption(
                    icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    title: isAr ? "الوضع الليلي" : "Dark Mode",
                    isDark: isDark,
                    trailing: Switch(
                      value: isDark,
                      activeColor: AppColors.primaryBlue,
                      onChanged: (val) {
                        themeProvider.toggleTheme(val);
                      },
                    ),
                  ),

                  // تعديل اللغة
                  _buildOption(
                    icon: Icons.language_rounded,
                    title: isAr ? "اللغة الحالية: العربية" : "Current Language: English",
                    isDark: isDark,
                    onTap: () {
                      langProvider.changeLanguage(isAr ? 'en' : 'ar');
                    },
                  ),

                  const Divider(height: 40),
                  _sectionTitle(isAr ? "الدعم والنظام" : "Support & System", isDark),

                  _buildOption(
                    icon: Icons.info_outline_rounded,
                    title: isAr ? "عن المنصة" : "About Platform",
                    isDark: isDark,
                    onTap: () {
                      _showAboutDialog(context, isAr, isDark);
                    },
                  ),

                  _buildOption(
                    icon: Icons.logout_rounded,
                    title: isAr ? "تسجيل الخروج" : "Logout",
                    isDark: isDark,
                    iconColor: Colors.redAccent,
                    onTap: () => _showLogoutConfirm(context, isAr, isDark),
                  ),
                ],
              ),
            ),

            // الفوتر
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                isAr ? "نسخة الإدارة v1.0.0" : "Admin Version v1.0.0",
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 10, left: 10),
      child: Text(
        title,
        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white54 : AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8F9FD),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Icon(icon, color: iconColor ?? AppColors.primaryBlue, size: 22),
        title: Text(
          title,
          style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
      ),
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
              await TokenManager.clearToken(); // تفريغ التوكن تماماً
              if (!context.mounted) return;
              // العودة لصفحة الدخول الموحدة اللي سويناها
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? "إغلاق" : "Close")),
        ],
      ),
    );
  }
}
