import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/api/api_s.dart';
import '../core/ui/app_color.dart';
import '../core/token_manager.dart';
import '../pages/login_screen.dart';
import '../pages/student/settings/notification.dart';
import '../pages/student/settings/support_screen.dart';

class SettingsSideBar extends StatelessWidget {
  const SettingsSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 80),

          _drawerItem(
            context,
            icon: Icons.notifications_active_outlined,
            title: "الإشعارات",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const NotificationsScreen()));
            },
          ),

          _drawerItem(
            context,
            icon: Icons.support_agent_outlined,
            title: "مركز الدعم والشكاوى",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const SupportCenterScreen()));
            },
          ),

          _drawerItem(
            context,
            icon: Icons.lock_reset_rounded,
            title: "تغيير كلمة المرور",
            onTap: () {
              Navigator.pop(context);
              _showChangePasswordSheet(context);
            },
          ),

          const Spacer(),
          const Divider(indent: 20, endIndent: 20),

          _drawerItem(
            context,
            icon: Icons.logout_rounded,
            title: "تسجيل الخروج",
            color: Colors.redAccent,
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── نافذة تغيير كلمة المرور (المنطق الحقيقي) ──
  void _showChangePasswordSheet(BuildContext context) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left: 25, right: 25, top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("تغيير كلمة المرور", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),

            _buildPassField("كلمة المرور الحالية", currentPassCtrl),
            const SizedBox(height: 15),
            _buildPassField("كلمة المرور الجديدة", newPassCtrl),
            const SizedBox(height: 15),
            _buildPassField("تأكيد كلمة المرور الجديدة", confirmPassCtrl),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  // 1. فحص تطابق الرموز الجديدة
                  if (newPassCtrl.text != confirmPassCtrl.text) {
                    _showStatusPopup(context, "خطأ", "كلمات المرور الجديدة غير متطابقة", isError: true);
                    return;
                  }

                  try {
                    // 2. استدعاء الـ API الحقيقي
                    await ApiService().changePassword(
                      currentPassCtrl.text,
                      newPassCtrl.text,
                      confirmPassCtrl.text,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(c); // إغلاق النافذة
                    _showStatusPopup(context, "تم بنجاح", "تم تحديث كلمة المرور بنجاح ✅", isError: false);

                  } catch (e) {
                    // 3. الخطأ (مثل الرمز القديم غلط)
                    _showStatusPopup(context, "فشل التحديث", "الرمز الحالي غير صحيح أو حدث خطأ في النظام", isError: true);
                  }
                },
                child: Text("تحديث الآن", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── ويدجت الرسائل المنبثقة (Dialogs) ──
  void _showStatusPopup(BuildContext context, String title, String msg, {required bool isError}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: isError ? Colors.red : Colors.green)),
        content: Text(msg, style: GoogleFonts.tajawal()),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("موافق"))],
      ),
    );
  }

  // ── تسجيل الخروج ──
  Future<void> _handleLogout(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("تنبيه", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        content: const Text("هل أنت متأكد من تسجيل الخروج؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("إلغاء")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("نعم، خروج", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try { await ApiService().logout(); } finally {
        await TokenManager.clearToken();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (route) => false);
        }
      }
    }
  }

  Widget _drawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
      leading: Icon(icon, color: color ?? AppColors.primaryBlue, size: 24),
      title: Text(title, style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.w600, color: color ?? AppColors.textDark)),
      onTap: onTap,
    );
  }

  Widget _buildPassField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
