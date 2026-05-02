import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';
import 'InstitutionVerificationScreen.dart';

class InstitutionRegisterScreen extends StatefulWidget {
  const InstitutionRegisterScreen({super.key});
  @override
  State<InstitutionRegisterScreen> createState() => _InstitutionRegisterScreenState();
}

class _InstitutionRegisterScreenState extends State<InstitutionRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _instNameCtrl = TextEditingController();
  final _registerCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  Future<void> _handleRegister(bool isAr) async {
    if (!_formKey.currentState!.validate()) return;

    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isAr ? "كلمات المرور غير متطابقة" : "Passwords do not match"),
            backgroundColor: Colors.red
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> body = {
      "full_name": _nameCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "password": _passCtrl.text,
      "password_confirmation": _confirmPassCtrl.text,
      "user_type": "institution",
      "name": _instNameCtrl.text.trim(),
      "commercial_register": _registerCtrl.text.trim(),
      "address": _addressCtrl.text.trim().isEmpty ? (isAr ? "غير محدد" : "Not specified") : _addressCtrl.text.trim(),
      "description": "New Training Institution",
      "website": "https://example.com",
      "contact_person": _nameCtrl.text.trim(),
      "contact_phone": _phoneCtrl.text.trim().isEmpty ? "770000000" : _phoneCtrl.text.trim(),
      "social_links": [],
    };

    try {
      final response = await ApiService().registerInstitution(body);

      if (response['success'] == true) {
        String vToken = response['data']['verification_token'];
        int expires = response['data']['expires_in_minutes'] ?? 10;

        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(
            builder: (c) => InstitutionVerificationScreen(token: vToken, expiryMinutes: expires)
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(isAr ? "انضم كشريك تدريب" : "Join as Training Partner",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17)),
          centerTitle: true,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
          leading: IconButton(
            icon: Icon(isAr ? Icons.arrow_back_ios : Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(isAr, isDark),
                const SizedBox(height: 25),

                _buildSection(isAr ? "معلومات المسؤول" : "Admin Information", [
                  _buildModernField(isAr ? "الاسم الكامل للمسؤول" : "Full Admin Name", Icons.person_outline, _nameCtrl, isDark, isAr),
                  _buildModernField(isAr ? "البريد الإلكتروني الرسمي" : "Official Email", Icons.email_outlined, _emailCtrl, isDark, isAr),
                  _buildModernField(isAr ? "رقم هاتف التواصل" : "Contact Phone Number", Icons.phone_android, _phoneCtrl, isDark, isAr),
                ], isDark),

                const SizedBox(height: 20),

                _buildSection(isAr ? "بيانات المؤسسة" : "Institution Details", [
                  _buildModernField(isAr ? "اسم المؤسسة التجاري" : "Business Name", Icons.business, _instNameCtrl, isDark, isAr),
                  _buildModernField(isAr ? "رقم السجل التجاري" : "Commercial Register No.", Icons.badge_outlined, _registerCtrl, isDark, isAr),
                  _buildModernField(isAr ? "عنوان المقر الرئيسي" : "Headquarters Address", Icons.location_on_outlined, _addressCtrl, isDark, isAr),
                ], isDark),

                const SizedBox(height: 20),

                _buildSection(isAr ? "إعدادات الأمان" : "Security Settings", [
                  _buildModernField(isAr ? "كلمة المرور" : "Password", Icons.lock_outline, _passCtrl, isDark, isAr, isPass: true),
                  _buildModernField(isAr ? "تأكيد كلمة المرور" : "Confirm Password", Icons.lock_reset, _confirmPassCtrl, isDark, isAr, isPass: true),
                ], isDark),

                const SizedBox(height: 40),
                _buildSubmitButton(isAr),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isAr, bool isDark) => Container(
    width: double.infinity, padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 15)]
    ),
    child: Column(children: [
      CircleAvatar(radius: 35, backgroundColor: AppColors.primaryBlue.withOpacity(0.1), child: const Icon(Icons.add_business_rounded, size: 35, color: AppColors.primaryBlue)),
      const SizedBox(height: 15),
      Text(isAr ? "سجل مؤسستك في Trainex" : "Register your Institution",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      Text(isAr ? "ساهم في بناء مهارات الجيل القادم" : "Contribute to building future skills",
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ]),
  );

  Widget _buildSection(String title, List<Widget> children, bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.only(right: 10, left: 10, bottom: 8), child: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.primaryBlue))),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 10)]
        ),
        child: Column(children: children),
      ),
    ],
  );

  Widget _buildModernField(String hint, IconData icon, TextEditingController ctrl, bool isDark, bool isAr, {bool isPass = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: ctrl,
      obscureText: isPass,
      style: GoogleFonts.tajawal(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue.withOpacity(0.7), size: 20),
        filled: true,
        fillColor: isDark ? Colors.black26 : const Color(0xFFF9FBFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? (isAr ? "هذا الحقل مطلوب" : "Required") : null,
    ),
  );

  Widget _buildSubmitButton(bool isAr) => GestureDetector(
    onTap: _isLoading ? null : () => _handleRegister(isAr),
    child: Container(
      width: double.infinity, height: 60,
      decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(isAr ? "إرسال طلب التسجيل" : "Send Registration Request ",
              style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
      ),
    ),
  );
}
