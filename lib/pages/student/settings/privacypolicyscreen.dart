import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          title: Text(isAr ? "سياسة الخصوصية للطالب" : "Student Privacy Policy",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          centerTitle: true,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
          elevation: 0,
          leading: IconButton(
            icon: Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(isAr, isDark),
              const SizedBox(height: 30),

              _sectionTitle(isAr ? "1. معلومات الهوية الأكاديمية" : "1. Academic Identity Information", isDark),
              _buildInfoCard(
                  isAr
                      ? "نحن نجمع بياناتك الأساسية (الاسم الرباعي، الرقم الجامعي، التخصص، والمعدل) لضمان صحة تسجيلك في النظام وربطك بفرص التدريب التي تناسب مؤهلاتك."
                      : "We collect your basic data (full name, student ID, specialization, and GPA) to ensure correct registration and match you with suitable training opportunities.",
                  isDark
              ),

              _sectionTitle(isAr ? "2. ملف التدريب الميداني" : "2. Field Training Profile", isDark),
              _buildInfoCard(
                  isAr
                      ? "يتم تخزين تقاريرك الأسبوعية، سجل الحضور، والتقييمات النهائية بشكل آمن. هذه البيانات متاحة فقط لمشرفك الأكاديمي في الجامعة ومدربك المباشر في المؤسسة."
                      : "Your weekly reports, attendance records, and final evaluations are stored securely. This data is only accessible to your academic supervisor and direct trainer.",
                  isDark
              ),

              _sectionTitle(isAr ? "3. خصوصية التواصل" : "3. Communication Privacy", isDark),
              _buildInfoCard(
                  isAr
                      ? "رقم هاتفك وبريدك الإلكتروني يُستخدمان فقط لإرسال تنبيهات حالة طلبات التدريب، أو للتواصل من قبل المؤسسة التي وافقت على تدريبك."
                      : "Your phone number and email are used only to send training request status alerts or for communication by the institution that approved your training.",
                  isDark
              ),

              _sectionTitle(isAr ? "4. أمان الحساب" : "4. Account Security", isDark),
              _buildInfoCard(
                  isAr
                      ? "كلمة المرور الخاصة بك مشفرة تماماً بنظام (Bcrypt)؛ لا يمكن لموظفي الجامعة أو إدارة النظام الاطلاع عليها. تقع مسؤولية الحفاظ على سرية الحساب على عاتقك."
                      : "Your password is fully encrypted using (Bcrypt); university staff or system admins cannot access it. You are responsible for maintaining account confidentiality.",
                  isDark
              ),

              _sectionTitle(isAr ? "5. حقوق الوصول والتعديل" : "5. Access and Correction Rights", isDark),
              _buildInfoCard(
                  isAr
                      ? "لك الحق الكامل في تعديل مهاراتك ونبذتك الشخصية في أي وقت. بعد انتهاء فترة التدريب، يتم أرشفة بياناتك الأكاديمية لأغراض التدقيق الجامعي فقط."
                      : "You have the full right to edit your skills and personal bio at any time. After the training period, academic data is archived for university auditing only.",
                  isDark
              ),

              const SizedBox(height: 50),
              _buildFooter(isAr),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isAr, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 20)],
      ),
      child: Column(
        children: [
          const Icon(Icons.security_outlined, size: 60, color: AppColors.primaryBlue),
          const SizedBox(height: 15),
          Text(isAr ? "نحمي رحلتك المهنية" : "Protecting Your Career Journey",
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          const SizedBox(height: 10),
          Text(
            isAr
                ? "خصوصية بياناتك الأكاديمية هي أولويتنا القصوى لضمان تجربة تدريب آمنة."
                : "The privacy of your academic data is our top priority to ensure a safe training experience.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, height: 1.5, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10, bottom: 12, top: 10),
      child: Text(title,
          style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.textDark
          )),
    );
  }

  Widget _buildInfoCard(String content, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent),
      ),
      child: Text(
        content,
        style: GoogleFonts.tajawal(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black87,
            height: 1.8
        ),
      ),
    );
  }

  Widget _buildFooter(bool isAr) {
    return Center(
      child: Column(
        children: [
          Text(isAr ? "نظام إدارة التدريب الميداني (TrainEx)" : "Field Training Management System (TrainEx)",
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(isAr ? "نسخة الطالب v1.0.2" : "Student Version v1.0.2", style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
