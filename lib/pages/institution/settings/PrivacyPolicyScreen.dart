import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';

class InstitutionPrivacyPolicyScreen extends StatelessWidget {
  const InstitutionPrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        appBar: AppBar(
          // ── إضافة زر الرجوع هنا ──
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("سياسة الخصوصية للمؤسسة",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
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

              _sectionTitle("1. سرية بيانات الطلاب"),
              _buildInfoCard("تتعهد المؤسسة بالحفاظ على سرية البيانات الشخصية والأكاديمية للطلاب المتقدمين، وعدم استخدامها أو مشاركتها خارج نطاق إجراءات التوظيف والتدريب المعتمدة في النظام."),

              _sectionTitle("2. صلاحيات الوصول"),
              _buildInfoCard("يقتصر حق الوصول إلى ملفات الطلاب وتقاريرهم الدورية على المشرفين الميدانيين المعينين من قبل المؤسسة فقط، لغرض المتابعة والتقييم."),

              _sectionTitle("3. تقارير الأداء والتقييم"),
              _buildInfoCard("كافة التقييمات والملاحظات التي تُدخلها المؤسسة بحق الطالب تُعد بيانات أكاديمية محمية، تُشارك فقط مع الطالب المعني والجامعة التابع لها."),

              _sectionTitle("4. الالتزام بالمعايير"),
              _buildInfoCard("تلتزم المؤسسة بحذف صلاحيات الوصول إلى بيانات الطالب فور انتهاء فترة التدريب المقررة، ما لم يتطلب الأمر غير ذلك لأغراض إدارية متفق عليها مع الجامعة."),

              _sectionTitle("5. حماية حساب المؤسسة"),
              _buildInfoCard("تتحمل المؤسسة مسؤولية الحفاظ على سرية بيانات الدخول الخاصة بمشرفيها، وأي نشاط يتم من خلال الحساب يُعتبر صادراً عن المؤسسة رسمياً."),

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
          const Icon(Icons.admin_panel_settings_rounded, size: 60, color: AppColors.primaryBlue),
          const SizedBox(height: 15),
          Text("ميثاق الخصوصية المهني",
              style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          const SizedBox(height: 10),
          const Text(
            "نحن نؤمن بأن حماية البيانات هي أساس الشراكة الناجحة بين المؤسسات التعليمية وجهات التدريب.",
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
          const Text("نسخة المؤسسات v1.0.2", style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
