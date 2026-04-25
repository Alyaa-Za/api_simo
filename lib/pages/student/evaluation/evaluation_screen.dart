import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';

class EvaluationScreen extends StatelessWidget {
  const EvaluationScreen({super.key});

  Future<Map<String, dynamic>> _fetchEvaluationData() async {
    final response = await ApiService().getEvaluation();
    return response['data'] ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF), // خلفية هادئة وفخمة
        body: FutureBuilder<Map<String, dynamic>>(
          future: _fetchEvaluationData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildNoEvaluationState();
            }

            final eval = snapshot.data!;
            final int score = eval['final_score'] ?? 0;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. [Header الفخم]: يحتوي على الدرجة النهائية
                SliverAppBar(
                  expandedHeight: 280.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeaderGradient(score),
                  ),
                  title: Text("تقييم الأداء النهائي",
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
                  centerTitle: true,
                ),

                // 2. [محتوى التقييم]
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("تفاصيل النتيجة المعتمدة", Icons.verified_user_rounded),
                        _buildScoreDetailCard(score),

                        const SizedBox(height: 30),

                        _buildSectionHeader("ملاحظات المشرف الميداني", Icons.comment_bank_rounded),
                        _buildCommentCard(eval['comments'] ?? "تم إنهاء التدريب بنجاح، ولا توجد ملاحظات إضافية مرصودة حالياً."),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderGradient(int score) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text("$score%", style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w900, letterSpacing: -2)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(
              _getGradeText(score),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetailCard(int score) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Row(
        children: [
          _buildCircleIcon(Icons.stars_rounded, Colors.orange),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("المجموع العام", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("حصلت على $score درجة من أصل 100", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(String comment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded, color: AppColors.primaryBlue, size: 30),
          const SizedBox(height: 10),
          Text(
            comment,
            style: GoogleFonts.tajawal(height: 1.8, color: Colors.black87, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, right: 5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 28),
    );
  }

  String _getGradeText(int score) {
    if (score >= 90) return "تقدير: ممتاز جداً ";
    if (score >= 80) return "تقدير: جيد جداً ";
    if (score >= 70) return "تقدير: جيد ";
    return "تقدير: ناجح";
  }

  Widget _buildNoEvaluationState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(Icons.hourglass_empty_rounded, size: 80, color: Colors.grey[300]),
          ),
          const SizedBox(height: 25),
          Text("التقييم قيد المراجعة", style: GoogleFonts.tajawal(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text("لم يتم رصد نتيجتك النهائية بعد. سيتم إخطارك فور اعتمادها من قِبل جهة التدريب.",
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
