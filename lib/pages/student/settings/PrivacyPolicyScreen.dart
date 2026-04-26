import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        appBar: AppBar(
          title: Text("سياسة الخصوصية للطالب",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 30),

              _sectionTitle("1. معلومات الهوية الأكاديمية"),
              _buildInfoCard("نحن نجمع بياناتك الأساسية (الاسم الرباعي، الرقم الجامعي، التخصص، والمعدل) لضمان صحة تسجيلك في النظام وربطك بفرص التدريب التي تناسب مؤهلاتك."),

              _sectionTitle("2. ملف التدريب الميداني"),
              _buildInfoCard("يتم تخزين تقاريرك الأسبوعية، سجل الحضور، والتقييمات النهائية بشكل آمن. هذه البيانات متاحة فقط لمشرفك الأكاديمي في الجامعة ومدربك المباشر في المؤسسة."),

              _sectionTitle("3. خصوصية التواصل"),
              _buildInfoCard("رقم هاتفك وبريدك الإلكتروني يُستخدمان فقط لإرسال تنبيهات حالة طلبات التدريب، أو للتواصل من قبل المؤسسة التي وافقت على تدريبك."),

              _sectionTitle("4. أمان الحساب"),
              _buildInfoCard("كلمة المرور الخاصة بك مشفرة تماماً بنظام (Bcrypt)؛ لا يمكن لموظفي الجامعة أو إدارة النظام الاطلاع عليها. تقع مسؤولية الحفاظ على سرية الحساب على عاتقك."),

              _sectionTitle("5. حقوق الوصول والتعديل"),
              _buildInfoCard("لك الحق الكامل في تعديل مهاراتك ونبذتك الشخصية في أي وقت. بعد انتهاء فترة التدريب، يتم أرشفة بياناتك الأكاديمية لأغراض التدقيق الجامعي فقط."),

              const SizedBox(height: 50),
              _buildFooter(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Column(
        children: [
          const Icon(Icons.security_outlined, size: 60, color: AppColors.primaryBlue),
          const SizedBox(height: 15),
          Text("نحمي رحلتك المهنية",
              style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          const SizedBox(height: 10),
          const Text(
            "خصوصية بياناتك الأكاديمية هي أولويتنا القصوى لضمان تجربة تدريب آمنة.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 12, top: 10),
      child: Text(title,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
    );
  }

  Widget _buildInfoCard(String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white),
      ),
      child: Text(
        content,
        style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black87, height: 1.8),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text("نظام إدارة التدريب الميداني (FTMS)",
              style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("نسخة الطالب v1.0.2", style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
