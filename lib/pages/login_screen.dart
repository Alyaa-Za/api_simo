import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ftms_final/pages/student/main_wrapper.dart';
import '../../../core/ui/app_color.dart';
import '../../../widgets/bubble_background.dart';
import '../../../core/theme/language_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../core/api/api_s.dart';
import '../core/token_manager.dart';
import 'institution/institution_auth_guard.dart';
import 'institution/InstitutionRegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showPremiumResponseDialog(String title, String message, bool isError, bool isAr) {
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
              Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: isError ? Colors.red : Colors.green, size: 60),
              const SizedBox(height: 20),
              Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center, style: GoogleFonts.tajawal(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: isError ? Colors.red : Colors.green, shape: const StadiumBorder()),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(isAr ? "موافق" : "OK", style: const TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordSheet(bool isAr, bool isDark) {
    final resetEmailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 30, left: 25, right: 25, top: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              const Icon(Icons.lock_reset_rounded, size: 60, color: AppColors.primaryBlue),
              const SizedBox(height: 15),
              Text(isAr ? "استعادة كلمة المرور" : "Reset Password", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(isAr ? "أدخل بريدك الإلكتروني لإرسال رابط التعيين." : "Enter your email to receive a reset link.",
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 30),
              _buildPopupTextField(isAr ? "البريد الإلكتروني" : "Email", Icons.email_outlined, resetEmailCtrl, isPassword: false, isDark: isDark),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity, height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () {
                    Navigator.pop(context);
                    _showPremiumResponseDialog(isAr ? "تم الإرسال" : "Sent", isAr ? "تحقق من بريدك قريباً " : "Check your email inbox soon ", false, isAr);
                  },
                  child: Text(isAr ? "إرسال الطلب" : "Send Request", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForceChangePasswordDialog(bool isAr, String email) {
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isChanging = false;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.security_update_good_rounded, color: Colors.orange, size: 50),
                ),
                const SizedBox(height: 20),
                Text(isAr ? "تحديث الأمان" : "Security Update", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 10),
                Text(isAr ? "لحماية حسابك، يرجى تعيين كلمة مرور جديدة." : "Please set a new password to secure your account.",
                    textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 25),
                _buildPopupTextField(isAr ? "كلمة المرور الجديدة" : "New Password", Icons.lock_outline, newPassCtrl, isPassword: true, isDark: isDark),
                const SizedBox(height: 12),
                _buildPopupTextField(isAr ? "تأكيد كلمة المرور" : "Confirm Password", Icons.lock_reset, confirmPassCtrl, isPassword: true, isDark: isDark),
                const SizedBox(height: 30),
                isChanging
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: () async {
                      if (newPassCtrl.text.length < 8) return;
                      if (newPassCtrl.text != confirmPassCtrl.text) return;
                      setModalState(() => isChanging = true);
                      try {
                        await ApiService().changePassword(email, newPassCtrl.text, confirmPassCtrl.text);
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        _showPremiumResponseDialog(isAr ? "تم التحديث" : "Updated", isAr ? "تم تأمين حسابك بنجاح " : "Secured ", false, isAr);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainWrapper()));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                      } finally { setModalState(() => isChanging = false); }
                    },
                    child: Text(isAr ? "تحديث ودخول الآن" : "Update & Login", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(bool isAr) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().login(_loginCtrl.text.trim(), _passwordCtrl.text.trim());
      final data = response['data'];
      final user = data['user'];
      final String role = user['user_type'] ?? 'student';

      await TokenManager.saveToken(data['token'].toString());
      await TokenManager.saveUserData(user['full_name'], user['email']);

      if (!mounted) return;
      if (data['requires_password_change'] == true) {
        _showForceChangePasswordDialog(isAr, user['email']);
      } else {
        if (role == 'student') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainWrapper()));
        } else if (role == 'institution') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const InstitutionMainWrapper()));
        } else if (role == 'admin') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? "مرحباً بك أيها المسؤول" : "Welcome Admin")));
        }
      }
    } catch (e) {
      _showPremiumResponseDialog(isAr ? "خطأ في الدخول" : "Login Error", e.toString().replaceAll("Exception: ", ""), true, isAr);
    } finally { if (mounted) setState(() => _isLoading = false); }
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
        body: Stack(
          children: [
            const BubbleBackground(child: SizedBox.shrink()),

            Positioned(
              top: 50, right: isAr ? 20 : null, left: !isAr ? 20 : null,
              child: Row(
                children: [
                  _circleBtn(isDark ? Icons.light_mode : Icons.dark_mode,
                          () => themeProvider.toggleTheme(!isDark)
                  ),
                  const SizedBox(width: 10),
                  _circleBtn(Icons.language,
                          () => langProvider.changeLanguage(isAr ? 'en' : 'ar'),
                      label: isAr ? "EN" : "AR"
                  ),
                ],
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] : [const Color(0xFFEEF5FF), const Color(0xFFDDEEFF)],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 30)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 20),
                        Text(isAr ? 'مرحباً بك مجدداً' : 'Welcome Back', style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark)),
                        Text(isAr ? 'سجل دخولك للمتابعة' : 'Login to continue', style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 35),

                        _label(isAr ? 'البريد الإلكتروني / الرقم الأكاديمي' : 'Email / ID', isAr, isDark),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _loginCtrl,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: _inputDecoration(hint: isAr ? 'أدخل بياناتك' : 'Enter details', icon: Icons.login_rounded, isDark: isDark),
                          validator: (v) => v!.isEmpty ? (isAr ? "هذا الحقل مطلوب" : "Required") : null,
                        ),
                        const SizedBox(height: 20),
                        _label(isAr ? 'كلمة المرور' : 'Password', isAr, isDark),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: _inputDecoration(
                            isDark: isDark, hint: '********', icon: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),

                        Align(
                          alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _showForgotPasswordSheet(isAr, isDark),
                            child: Text(isAr ? "نسيت كلمة المرور؟" : "Forgot Password?", style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),

                        const SizedBox(height: 15),
                        _buildLoginBtn(isAr),

                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isAr ? "تمثل مؤسسة؟ " : "Representing an entity? ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const InstitutionRegisterScreen())),
                              child: Text(isAr ? "سجل الآن" : "Register Now", style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, {String? label}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
      child: label != null ? Text(label, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)) : Icon(icon, color: AppColors.primaryBlue, size: 20),
    ),
  );

  Widget _label(String text, bool isAr, bool isDark) => Align(alignment: isAr ? Alignment.centerRight : Alignment.centerLeft, child: Text(text, style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textDark)));

  InputDecoration _inputDecoration({required String hint, required IconData icon, Widget? suffix, required bool isDark}) {
    return InputDecoration(
      hintText: hint, hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true, fillColor: isDark ? Colors.black26 : Colors.white,
      prefixIcon: Icon(icon, color: AppColors.primaryBlue.withOpacity(0.7), size: 20),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
    );
  }

  Widget _buildLoginBtn(bool isAr) => GestureDetector(
    onTap: _isLoading ? null : () => _handleLogin(isAr),
    child: Container(
      width: double.infinity, height: 60,
      decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 12)]),
      child: Center(child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isAr ? 'تسجيل الدخول' : 'Login', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
    ),
  );

  Widget _buildLogo() => Container(
    height: 90, width: 90,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
    child: Padding(padding: const EdgeInsets.all(15), child: Image.asset('assets/images/logo.png', fit: BoxFit.contain)),
  );

  Widget _buildPopupTextField(String label, IconData icon, TextEditingController ctrl, {bool isPassword = false, required bool isDark}) {
    return TextField(
      controller: ctrl, obscureText: isPassword,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 22),
          filled: true, fillColor: isDark ? Colors.black26 : const Color(0xFFF8F9FD),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
      ),
    );
  }
}
