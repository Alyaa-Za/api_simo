//import 'package:TrainEx/pages/student/main_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:ftms_final/pages/student/main_wrapper.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../widgets/bubble_background.dart';
import '../core/api/api_s.dart';
import '../core/token_manager.dart';
import 'institution/institution_home_screen.dart';

enum UserRole { student, institution }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure   = true;
  bool _isLoading = false;
  UserRole _role  = UserRole.student;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            Text(
              "خطأ في الدخول",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "حاول مرة أخرى",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );

      print("Login Response: $response");

      final data = response['data'];
      final user = data['user'];
      final token = data['token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception("فشل الحصول على التوكن");
      }

      await TokenManager.saveToken(token.toString());

      final String name = user['full_name'] ?? '';
      final String role = user['user_type'] ?? '';

      print("Name: $name");
      print("Role: $role");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("مرحباً بك، $name", style: GoogleFonts.tajawal()),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) {
            if (role == 'student') {
              return const MainWrapper();
            } else {
              return const InstitutionHomeScreen();
            }
          },
        ),
      );

    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString().replaceAll("Exception: ", "");
      _showErrorDialog(errorMessage);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       e.toString().replaceAll("Exception: ", ""),
      //     ),
      //   ),
      // );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryBlue,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'مرحبًا بعودتك',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'سجّل الدخول لمواصلة رحلتك',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),

                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0EEFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _roleTab(UserRole.student,     'طالب',     Icons.person_rounded),
                          _roleTab(UserRole.institution, 'المؤسسة', Icons.business_rounded),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _label('Email'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'البريد الإلكتروني مطلوب';
                        if (!v.contains('@')) return 'أدخل عنوان بريد إلكتروني صالح';
                        return null;
                      },
                      decoration: _inputDecoration(
                        hint: 'أدخل بريدك الإلكتروني',
                        icon: Icons.email_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _label('Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'يلزم إدخال كلمة المرور';
                        if (v.length < 8) return '8 أحرف على الأقل';
                        return null;
                      },
                      decoration: _inputDecoration(
                        hint: 'أدخل كلمة مرورك',
                        icon: Icons.lock_outline_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textGrey,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: _isLoading ? null : _login,
                      child: Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.40),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.login_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'تسجيل الدخول',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleTab(UserRole role, String label, IconData icon) {
    final isActive = _role == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: isActive ? Colors.white : AppColors.textGrey),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFB0BBC8)),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
      ),
    );
  }
}