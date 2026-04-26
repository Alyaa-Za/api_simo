import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/token_manager.dart';
import '../../login_screen.dart';
import 'InstitutionComplaints.dart';
import 'PrivacyPolicyScreen.dart';

class InstitutionSettings extends StatefulWidget {
  const InstitutionSettings({super.key});

  @override
  State<InstitutionSettings> createState() => _InstitutionSettingsState();
}

class _InstitutionSettingsState extends State<InstitutionSettings> {
  bool _isObscureOld = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildPremiumHeader(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("الأمان والحساب"),
                    _buildSettingsCard(context),

                    const SizedBox(height: 30),

                    _sectionTitle("الدعم والقوانين"),
                    _buildSupportCard(context),

                    const SizedBox(height: 40),

                    _buildLogoutButton(context),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 70, 20, 45),
    decoration: const BoxDecoration(
      gradient: AppColors.splashGradient,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
    ),
    child: Column(
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundColor: Colors.white24,
          child: Icon(Icons.business_center_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 15),
        Text("إعدادات المؤسسة",
            style: GoogleFonts.tajawal(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text("إدارة الصلاحيات والأمان المهني", style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 12)),
      ],
    ),
  );

  Widget _buildSettingsCard(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
    child: Column(
      children: [
        _buildListTile(Icons.lock_reset_rounded, "تغيير كلمة المرور", () => _showChangePasswordSheet(context)),
      ],
    ),
  );

  Widget _buildSupportCard(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
    child: Column(
      children: [
        _buildListTile(Icons.support_agent_rounded, "مركز البلاغات والدعم", () {
          Navigator.push(context, MaterialPageRoute(builder: (c) => const InstitutionComplaintsScreen()));
        }),
        _buildListTile(Icons.privacy_tip_outlined, "سياسة الخصوصية", () {
          Navigator.push(context, MaterialPageRoute(builder: (c) => const InstitutionPrivacyPolicyScreen()));
        }),
      ],
    ),
  );

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmation(context),
        icon: const Icon(Icons.logout_rounded, color: Colors.white),
        label: Text("تسجيل الخروج من الحساب", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
              ),
              const SizedBox(height: 20),
              Text("تأكيد الخروج", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              const Text("هل أنت متأكد من رغبتك في تسجيل الخروج من حساب المؤسسة؟", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("إلغاء"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () async {
                        await TokenManager.clearToken();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (c) => const LoginScreen()),
                                (route) => false,
                          );
                        }
                      },
                      child: const Text("خروج", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final oldP = TextEditingController();
    final newP = TextEditingController();
    final confirmP = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 30, left: 25, right: 25, top: 20),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              Text("تحديث كلمة المرور", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              _buildPassField("كلمة المرور الحالية", oldP, _isObscureOld, () => setModalState(() => _isObscureOld = !_isObscureOld)),
              _buildPassField("كلمة المرور الجديدة", newP, _isObscureNew, () => setModalState(() => _isObscureNew = !_isObscureNew)),
              _buildPassField("تأكيد الكلمة الجديدة", confirmP, _isObscureConfirm, () => setModalState(() => _isObscureConfirm = !_isObscureConfirm)),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: const StadiumBorder()),
                  onPressed: () async {
                    if (newP.text != confirmP.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("كلمات المرور غير متطابقة")));
                      return;
                    }
                    try {
                      await ApiService().changePassword(oldP.text, newP.text, confirmP.text);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم التحديث بنجاح ✅"), backgroundColor: Colors.green));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: Text("تحديث الآن", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassField(String label, TextEditingController ctrl, bool obscure, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
          suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onToggle),
          filled: true, fillColor: const Color(0xFFF8F9FD),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) => ListTile(
    onTap: onTap,
    leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.05), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primaryBlue, size: 20)),
    title: Text(title, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600)),
    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
  );

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(right: 10, bottom: 12), child: Text(title, style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey)));
}
