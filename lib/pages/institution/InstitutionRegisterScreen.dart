import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../core/api/api_s.dart';
import 'InstitutionVerificationScreen.dart';

class InstitutionRegisterScreen extends StatefulWidget {
  const InstitutionRegisterScreen({super.key});
  @override
  State<InstitutionRegisterScreen> createState() => _InstitutionRegisterScreenState();
}

class _InstitutionRegisterScreenState extends State<InstitutionRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // المتحكمات
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _instNameCtrl = TextEditingController();
  final _registerCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("كلمات المرور غير متطابقة"), backgroundColor: Colors.red),
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
      "address": _addressCtrl.text.trim().isEmpty ? "غير محدد" : _addressCtrl.text.trim(),
      "description": "مؤسسة تدريبية مسجلة حديثاً",
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          title: Text("انضم كشريك تدريب", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
          centerTitle: true,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 25),

                _buildSection("معلومات المسؤول", [
                  _buildModernField("الاسم الكامل للمسؤول", Icons.person_outline, _nameCtrl),
                  _buildModernField("البريد الإلكتروني الرسمي", Icons.email_outlined, _emailCtrl),
                  _buildModernField("رقم هاتف التواصل", Icons.phone_android, _phoneCtrl),
                ]),

                const SizedBox(height: 20),

                _buildSection("بيانات المؤسسة", [
                  _buildModernField("اسم المؤسسة التجاري", Icons.business, _instNameCtrl),
                  _buildModernField("رقم السجل التجاري", Icons.badge_outlined, _registerCtrl),
                  _buildModernField("عنوان المقر الرئيسي", Icons.location_on_outlined, _addressCtrl),
                ]),

                const SizedBox(height: 20),

                _buildSection("إعدادات الأمان", [
                  _buildModernField("كلمة المرور", Icons.lock_outline, _passCtrl, isPass: true),
                  _buildModernField("تأكيد كلمة المرور", Icons.lock_reset, _confirmPassCtrl, isPass: true),
                ]),

                const SizedBox(height: 40),
                _buildSubmitButton(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    width: double.infinity, padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)]),
    child: Column(children: [
      CircleAvatar(radius: 35, backgroundColor: AppColors.primaryBlue.withOpacity(0.1), child: const Icon(Icons.add_business_rounded, size: 35, color: AppColors.primaryBlue)),
      const SizedBox(height: 15),
      Text("سجل مؤسستك في Trainex", style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
      const Text("ساهم في بناء مهارات الجيل القادم", style: TextStyle(color: Colors.grey, fontSize: 12)),
    ]),
  );

  Widget _buildSection(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.only(right: 10, bottom: 8), child: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.primaryBlue))),
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Column(children: children),
      ),
    ],
  );

  Widget _buildModernField(String hint, IconData icon, TextEditingController ctrl, {bool isPass = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: ctrl,
      obscureText: isPass,
      style: GoogleFonts.tajawal(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: const Color(0xFFF9FBFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
    ),
  );

  Widget _buildSubmitButton() => GestureDetector(
    onTap: _isLoading ? null : _handleRegister,
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
              : Text("إرسال طلب التسجيل", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
      ),
    ),
  );
}
