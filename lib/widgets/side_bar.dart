import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/token_manager.dart';
import '../pages/login_screen.dart';
import '../pages/student/settings/PrivacyPolicyScreen.dart';
import '../pages/student/settings/complaints_screen.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.85,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            _buildPremiumHeader(),

            const SizedBox(height: 20),

            _buildMenuTile(Icons.lock_reset_rounded, "تغيير كلمة المرور", () => _showChangePasswordModal(context)),

            _buildMenuTile(Icons.support_agent_rounded, "مركز الدعم والبلاغات", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const ComplaintsScreen()));
            }),

            _buildMenuTile(Icons.privacy_tip_outlined, "سياسة الخصوصية والأمان", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const PrivacyPolicyScreen()));
            }),

            const Spacer(),

            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 70, 20, 40),
    decoration: const BoxDecoration(
      gradient: AppColors.splashGradient,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white24,
            child: Icon(Icons.settings_suggest_outlined, color: Colors.white, size: 35)
        ),
        const SizedBox(height: 15),
        Text("إعدادات الحساب", style: GoogleFonts.tajawal(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text("تحكم في خصوصية وأمان ملفك الأكاديمي", style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 12)),
      ],
    ),
  );

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) => ListTile(
    onTap: onTap,
    leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primaryBlue, size: 22)
    ),
    title: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 15)),
    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
    contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
  );

  Widget _buildLogoutButton(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(25, 10, 25, 40),
    child: ElevatedButton.icon(
      onPressed: () => _showHugeLogoutWarning(context),
      icon: const Icon(Icons.logout_rounded, color: Colors.white),
      label: Text("تسجيل الخروج", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
      ),
    ),
  );

  void _showHugeLogoutWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.warning_rounded, color: Colors.red, size: 70)
            ),
            const SizedBox(height: 25),
            Text("تنبيه أمان!", style: GoogleFonts.tajawal(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.red)),
            const SizedBox(height: 10),
            const Text("هل أنت متأكد من رغبتك في تسجيل الخروج؟", textAlign: TextAlign.center),
            const SizedBox(height: 35),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text("إلغاء"))),
              const SizedBox(width: 15),
              Expanded(child: ElevatedButton(onPressed: () async {
                await TokenManager.clearToken();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (r) => false);
              }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text("خروج", style: TextStyle(color: Colors.white)))),
            ]),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordModal(BuildContext context) {
    final oldP = TextEditingController();
    final newP = TextEditingController();
    final confirmP = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (c) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left: 25, right: 25, top: 20),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              Text("تحديث كلمة المرور", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              _buildPasswordField("كلمة المرور الحالية", oldP, _isObscureOld, () => setModalState(() => _isObscureOld = !_isObscureOld)),
              _buildPasswordField("كلمة المرور الجديدة", newP, _isObscureNew, () => setModalState(() => _isObscureNew = !_isObscureNew)),
              _buildPasswordField("تأكيد الكلمة الجديدة", confirmP, _isObscureConfirm, () => setModalState(() => _isObscureConfirm = !_isObscureConfirm)),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                    onPressed: () async {
                      if (newP.text != confirmP.text) { /* تنبيه */ return; }
                      await ApiService().changePassword(oldP.text, newP.text, confirmP.text);
                      Navigator.pop(c);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: const StadiumBorder()),
                    child: const Text("تحديث الآن", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                ),
              ),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController ctrl, bool obscure, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl, obscureText: obscure,
        decoration: InputDecoration(
          labelText: label, prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
          suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onToggle),
          filled: true, fillColor: const Color(0xFFF8F9FD),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
