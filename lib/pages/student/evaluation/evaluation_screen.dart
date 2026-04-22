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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("تقييم الأداء التدريبي"),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
        elevation: 0,
      ),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildFinalScoreCard(eval['final_score'] ?? 0),

                const SizedBox(height: 25),

                _sectionTitle("تفاصيل المهارات"),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
                  ),
                  child: Column(
                    children: [
                      _buildRatingRow("المهارات التقنية", eval['technical_skills'] ?? 0),
                      _buildRatingRow("الالتزام والضبط", eval['commitment'] ?? 0),
                      _buildRatingRow("العمل بروح الفريق", eval['teamwork'] ?? 0),
                      _buildRatingRow("الانضباط بالحضور", eval['attendance'] ?? 0),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                _sectionTitle("ملاحظات المشرف"),
                const SizedBox(height: 10),
                _buildCommentSection(eval['comments'] ?? "لا توجد ملاحظات إضافية مرصودة حالياً."),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFinalScoreCard(int score) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35),
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Text("النتيجة النهائية المعتمدة", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 10),
          Text("$score%", style: const TextStyle(color: Colors.white, fontSize: 55, fontWeight: FontWeight.w900)),
          Text(
            score >= 90 ? "تقدير: ممتاز جداً" : score >= 80 ? "تقدير: جيد جداً" : "تقدير: ناجح",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String label, int rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
          Row(
            children: List.generate(5, (index) => Icon(
              index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: index < rating ? Colors.orange : Colors.grey[300],
              size: 24,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection(String comment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.comment_bank_outlined, color: Colors.orange, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              comment,
              style: GoogleFonts.tajawal(height: 1.6, color: Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(title, style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
    );
  }

  Widget _buildNoEvaluationState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pending_actions_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text("لم يتم رصد تقييمك النهائي بعد", style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 5),
          Text("سيظهر هنا فور اعتماده من قبل جهة التدريب", style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
