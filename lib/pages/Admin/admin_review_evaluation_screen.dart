import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';

class AdminReviewEvaluationScreen extends StatefulWidget {
  final dynamic student;
  const AdminReviewEvaluationScreen({super.key, required this.student});

  @override
  State<AdminReviewEvaluationScreen> createState() => _AdminReviewEvaluationScreenState();
}

class _AdminReviewEvaluationScreenState extends State<AdminReviewEvaluationScreen> {
  @override
  Widget build(BuildContext context) {
    final isAr = Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                color: isDark ? Colors.white : AppColors.textDark, size: 20),
          ),
          title: Text(isAr ? "العودة للقائمة" : "Back to list",
              style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey)),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainTitle(isAr, isDark),

              const SizedBox(height: 25),

              _buildHeroStudentCard(widget.student['full_name'] ?? (isAr ? "المتدرب" : "Intern"), isAr),

              const SizedBox(height: 30),

              _buildScoreSummary(isAr, isDark),

              const SizedBox(height: 20),

              _buildEvaluationSection(isAr, isDark),

              const SizedBox(height: 25),

              _buildRecommendations(isAr, isDark),

              const SizedBox(height: 40),

              _buildBottomDisclaimer(isAr, isDark),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainTitle(bool isAr, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isAr ? "مراجعة واعتماد التقييم" : "Review & Approve Evaluation",
            style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.textDark)),
        Container(margin: const EdgeInsets.only(top: 5), width: 60, height: 4, decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  Widget _buildHeroStudentCard(String name, bool isAr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 45, color: AppColors.primaryBlue)),
          ),
          const SizedBox(height: 15),
          Text(name, style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
            child: Text(isAr ? "متدرب نشط" : "Active Intern", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary(bool isAr, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_outlined, color: AppColors.primaryBlue, size: 22),
            const SizedBox(width: 10),
            Text(isAr ? "معايير الأداء والتقييم الفني" : "Performance Standards", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "85 ", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
              TextSpan(text: "/ 100", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluationSection(bool isAr, bool isDark) {
    return Column(
      children: [
        _sliderItem(isAr ? "المهارات الفنية" : "Technical Skills", isAr ? "مدى إتقان المهام المسندة" : "Technical proficiency", 9, isDark, isAr),
        _sliderItem(isAr ? "الالتزام والمسؤولية" : "Commitment", isAr ? "التقيد بأنظمة العمل" : "Work ethics", 8, isDark, isAr),
        _sliderItem(isAr ? "الروح الجماعية" : "Teamwork", isAr ? "التعاون مع الفريق" : "Collaboration", 10, isDark, isAr),
        _sliderItem(isAr ? "الانضباط والوقت" : "Discipline", isAr ? "المواظبة على الحضور" : "Attendance", 7, isDark, isAr),
      ],
    );
  }

  Widget _sliderItem(String title, String sub, double val, bool isDark, bool isAr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text("${(val * 10).toInt()}%", style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryBlue, fontSize: 14)),
            ],
          ),
          Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(trackHeight: 6, thumbShape: SliderComponentShape.noThumb, overlayShape: SliderComponentShape.noOverlay),
            child: Slider(value: val, max: 10, divisions: 10, activeColor: AppColors.primaryBlue, inactiveColor: Colors.grey.withOpacity(0.1), onChanged: null),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isAr ? "ضعيف" : "Poor", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(isAr ? "ممتاز" : "Excellent", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRecommendations(bool isAr, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isAr ? "توصيات اللجنة والملاحظات الختامية" : "Committee Recommendations", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Text(
            isAr
                ? "أظهر المتدرب تميزاً ملحوظاً في المهام التقنية المسندة إليه، نوصي بصرف شهادة إتمام التدريب بتقدير ممتاز مع تمنياتنا له بالتوفيق."
                : "The intern showed remarkable excellence in assigned tasks. We recommend issuing a completion certificate with an excellent grade.",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.blueGrey, fontSize: 13, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomDisclaimer(bool isAr, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A), borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: Colors.green, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isAr ? "اعتماد رسمي" : "Official Approval", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(isAr ? "هذا التقرير معتمد من قبل جهة التدريب والإدارة." : "This report is officially approved by the entity.", style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
