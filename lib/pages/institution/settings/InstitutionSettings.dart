import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/token_manager.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/language_provider.dart';
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildPremiumHeader(isAr),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(isAr ? "المظهر واللغة" : "Appearance & Language"),
                    _buildSectionCard([
                      SwitchListTile(
                        activeColor: AppColors.primaryBlue,
                        title: Text(isAr ? "الوضع الليلي" : "Dark Mode", style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 14)),
                        secondary: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode, color: AppColors.primaryBlue),
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (v) => themeProvider.toggleTheme(v),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      ListTile(
                        leading: const Icon(Icons.translate_rounded, color: AppColors.primaryBlue),
                        title: Text(isAr ? "لغة الواجهة" : "App Language", style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 14)),
                        trailing: Text(isAr ? "العربية" : "English", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                        onTap: () => langProvider.changeLanguage(isAr ? 'en' : 'ar'),
                      ),
                    ]),

                    const SizedBox(height: 25),
                    _sectionTitle(isAr ? "الأمان والحساب" : "Security"),
                    _buildSectionCard([
                      _buildListTile(Icons.lock_reset_rounded, isAr ? "تغيير كلمة المرور" : "Change Password", () => _showChangePasswordSheet(context, isAr)),
                    ]),

                    const SizedBox(height: 25),
                    _sectionTitle(isAr ? "الدعم والقوانين" : "Support"),
                    _buildSectionCard([
                      _buildListTile(Icons.support_agent_rounded, isAr ? "مركز البلاغات" : "Support Center", () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const InstitutionComplaintsScreen()));
                      }),
                      const Divider(height: 1, indent: 60),
                      _buildListTile(Icons.privacy_tip_outlined, isAr ? "سياسة الخصوصية" : "Privacy Policy", () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const InstitutionPrivacyPolicyScreen()));
                      }),
                    ]),

                    const SizedBox(height: 40),
                    _buildLogoutButton(context, isAr),
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

  Widget _buildPremiumHeader(bool isAr) => Container(
    width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 70, 20, 45),
    decoration: const BoxDecoration(gradient: AppColors.splashGradient, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50))),
    child: Column(children: [
      const CircleAvatar(radius: 35, backgroundColor: Colors.white24, child: Icon(Icons.business_center, color: Colors.white, size: 35)),
      const SizedBox(height: 15),
      Text(isAr ? "إعدادات المؤسسة" : "Institution Settings", style: GoogleFonts.tajawal(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _buildSectionCard(List<Widget> children) => Container(
    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)]),
    child: Column(children: children),
  );

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(right: 10, bottom: 10), child: Text(title, style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)));

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) => ListTile(
    onTap: onTap,
    leading: Icon(icon, color: AppColors.primaryBlue),
    title: Text(title, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600)),
    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
  );

  Widget _buildLogoutButton(BuildContext context, bool isAr) => SizedBox(
    width: double.infinity, height: 60,
    child: ElevatedButton.icon(
      onPressed: () => _showLogoutConfirmation(context, isAr),
      icon: const Icon(Icons.logout_rounded, color: Colors.white),
      label: Text(isAr ? "تسجيل الخروج" : "Logout", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.shade400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    ),
  );

  void _showLogoutConfirmation(BuildContext context, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
              const SizedBox(height: 15),
              Text(
                isAr ? "هل أنت متأكد من رغبتك في تسجيل الخروج؟" : "Confirm logout?",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text(isAr ? "إلغاء" : "Cancel")
                    )
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () async {
                          Navigator.pop(ctx);

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (c) => const Center(child: CircularProgressIndicator()),
                          );

                          try {
                            await ApiService().logout();

                            await TokenManager.clearToken();

                            if (!context.mounted) return;
                            Navigator.pop(context);

                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            Navigator.pop(context);

                            await TokenManager.clearToken();

                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(isAr ? "تم تسجيل الخروج" : "Logged out"))
                            );
                          }
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



  void _showChangePasswordSheet(BuildContext context, bool isAr) {
    final oldP = TextEditingController();
    final newP = TextEditingController();
    final confirmP = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 30, left: 25, right: 25, top: 20),
          decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(40))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Text(isAr ? "تحديث كلمة المرور" : "Change Password", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildPassField(isAr ? "الحالية" : "Current", oldP, _isObscureOld, () => setModalState(() => _isObscureOld = !_isObscureOld)),
            _buildPassField(isAr ? "الجديدة" : "New", newP, _isObscureNew, () => setModalState(() => _isObscureNew = !_isObscureNew)),
            _buildPassField(isAr ? "تأكيد الجديدة" : "Confirm", confirmP, _isObscureConfirm, () => setModalState(() => _isObscureConfirm = !_isObscureConfirm)),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: const StadiumBorder()),
                onPressed: () async {
                  if (newP.text != confirmP.text) return;
                  await ApiService().changePassword(oldP.text, newP.text, confirmP.text);
                  Navigator.pop(ctx);
                },
                child: Text(isAr ? "تحديث" : "Update", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildPassField(String label, TextEditingController ctrl, bool obscure, VoidCallback onToggle) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextField(
      controller: ctrl, obscureText: obscure,
      decoration: InputDecoration(
        labelText: label, prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
        suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onToggle),
        filled: true, fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    ),
  );
}
