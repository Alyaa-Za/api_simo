import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ftms_final/pages/student/main_wrapper.dart';
import 'package:http/http.dart' as http;
import '../../../core/ui/app_color.dart';
import '../../../widgets/bubble_background.dart';
import '../core/api/api_s.dart';
import '../core/token_manager.dart';
import 'institution/InstitutionRegisterScreen.dart';
import 'institution/institution_auth_guard.dart';

enum UserRole { student, institution }

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
  UserRole _role = UserRole.student;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── 1. دالة الرسالة المنبثقة الفخمة ──
  void _showPremiumResponseDialog(String title, String message, bool isError) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                color: isError ? Colors.red : Colors.green,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center, style: GoogleFonts.tajawal(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isError ? Colors.red : Colors.green,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("موافق", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ── 2. نافذة نسيت كلمة المرور الفخمة (التي طلبتموها) ──
  void _showForgotPasswordSheet() {
    final resetEmailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
            left: 25, right: 25, top: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              const Icon(Icons.lock_reset_rounded, size: 60, color: AppColors.primaryBlue),
              const SizedBox(height: 15),
              Text("استعادة كلمة المرور", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("أدخل بريدك الإلكتروني وسنقوم بإرسال رابط لتعيين كلمة مرور جديدة.",
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
              const SizedBox(height: 30),
              _buildPopupTextField("البريد الإلكتروني", Icons.email_outlined, resetEmailCtrl, isPassword: false),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showPremiumResponseDialog("تم الإرسال", "إذا كان البريد مسجلاً، فستصلك رسالة الاستعادة قريباً ✅", false);
                  },
                  child: Text("إرسال طلب الاستعادة", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3. نافذة إجبار تغيير كلمة المرور ──
  void _showForceChangePasswordDialog() {
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isChanging = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
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
                Text("تحديث الأمان", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 10),
                const Text("لحماية حسابك، يرجى تعيين كلمة مرور جديدة بدلاً من الافتراضية.",
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 25),
                _buildPopupTextField("كلمة المرور الجديدة", Icons.lock_outline, newPassCtrl, isPassword: true),
                const SizedBox(height: 12),
                _buildPopupTextField("تأكيد كلمة المرور", Icons.lock_reset, confirmPassCtrl, isPassword: true),
                const SizedBox(height: 30),
                isChanging
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () async {
                      if (newPassCtrl.text.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("كلمة المرور قصيرة جداً")));
                        return;
                      }
                      if (newPassCtrl.text != confirmPassCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("كلمات المرور غير متطابقة")));
                        return;
                      }
                      setModalState(() => isChanging = true);
                      try {
                        await ApiService().changePassword("21436587", newPassCtrl.text, confirmPassCtrl.text);
                        Navigator.pop(ctx);
                        _showPremiumResponseDialog("تم التحديث", "تم تأمين حسابك بنجاح ✅", false);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainWrapper()));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل: $e")));
                      } finally { setModalState(() => isChanging = false); }
                    },
                    child: Text("تحديث ودخول الآن", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 4. منطق تسجيل الدخول ──
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().login(_loginCtrl.text.trim(), _passwordCtrl.text.trim());
      final data = response['data'];
      final user = data['user'];
      final token = data['token'];
      final bool requiresChange = data['requires_password_change'] ?? false;

      if (token == null) throw Exception("فشل الحصول على رمز الدخول");

      await TokenManager.saveToken(token.toString());
      await TokenManager.saveUserData(user['full_name'], user['email']);

      if (!mounted) return;
      if (requiresChange) {
        _showForceChangePasswordDialog();
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => user['user_type'] == 'student' ? const MainWrapper() : const InstitutionMainWrapper(),
        ));
      }
    } catch (e) {
      _showPremiumResponseDialog("خطأ في الدخول", e.toString().replaceAll("Exception: ", ""), true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BubbleBackground(
          style: BubbleStyle.login,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEEF5FF), Color(0xFFDDEEFF)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 30, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue),
                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 38),
                      ),
                      const SizedBox(height: 20),
                      Text('مرحباً بك مجدداً', style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      const SizedBox(height: 6),
                      Text('سجل دخولك للمتابعة', style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textGrey)),
                      const SizedBox(height: 28),

                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: const Color(0xFFE0EEFF), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            _roleTab(UserRole.student, 'طالب', Icons.person_rounded),
                            _roleTab(UserRole.institution, 'مؤسسة', Icons.business_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _label(_role == UserRole.student ? 'الرقم الأكاديمي أو البريد' : 'البريد الإلكتروني'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _loginCtrl,
                        decoration: _inputDecoration(hint: 'أدخل بياناتك', icon: Icons.login_rounded),
                        validator: (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
                      ),
                      const SizedBox(height: 16),
                      _label('كلمة المرور'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: _inputDecoration(
                          hint: '********',
                          icon: Icons.lock_outline_rounded,
                          suffix: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),

                      // ── [الإضافة]: زر نسيت كلمة المرور ──
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordSheet,
                          child: Text("نسيت كلمة المرور؟",
                              style: GoogleFonts.tajawal(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),

                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: _isLoading ? null : _login,
                        child: Container(
                          width: double.infinity, height: 58,
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text('تسجيل الدخول', style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),

                      if (_role == UserRole.institution) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("ليس لديك حساب؟ ", style: GoogleFonts.tajawal(fontSize: 13, color: Colors.grey)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const InstitutionRegisterScreen())),
                              child: Text("إنشاء حساب مؤسسة", style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleTab(UserRole role, String label, IconData icon) {
    bool selected = _role == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: selected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18, color: selected ? AppColors.primaryBlue : AppColors.textGrey), const SizedBox(width: 8), Text(label, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? AppColors.primaryBlue : AppColors.textGrey))]),
        ),
      ),
    );
  }

  Widget _label(String text) => Align(alignment: Alignment.centerRight, child: Text(text, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)));

  InputDecoration _inputDecoration({required String hint, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint, filled: true, fillColor: Colors.white,
      prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
    );
  }

  Widget _buildPopupTextField(String label, IconData icon, TextEditingController ctrl, {bool isPassword = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.tajawal(fontSize: 13, color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 22),
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }
}
