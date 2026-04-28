import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';

class EvaluationScreen extends StatelessWidget {
  const EvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: FutureBuilder<Map<String, dynamic>>(
          future: ApiService().getEvaluation(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            }

            // ── [صياد البيانات الذكي] ──
            // السيرفر أحياناً يرسل البيانات داخل data أو داخل كائن evaluation
            final Map<String, dynamic> rawData = snapshot.data ?? {};
            final Map<String, dynamic> dataPart = rawData['data'] ?? rawData;

            // البحث عن التقييم في أكثر من مسمى محتمل
            final eval = dataPart.containsKey('evaluation') ? dataPart['evaluation'] : dataPart;

            // استخراج الحقول (دعم كل الاحتمالات)
            final dynamic rawScore = eval['final_score'] ?? eval['score'] ?? eval['total_score'];
            final String? comments = eval['comments'] ?? eval['feedback'] ?? eval['notes'];

            // التحقق النهائي: إذا لم يجد درجة، يظهر "قيد الرصد"
            if (rawScore == null) {
              return _buildNoEvaluationState(context);
            }

            final int score = int.tryParse(rawScore.toString()) ?? 0;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 320.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeaderGradient(score),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text("النتيجة النهائية", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: Colors.white)),
                  centerTitle: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel("تفاصيل النتيجة المعتمدة"),
                        _buildScoreDetailCard(score),
                        const SizedBox(height: 35),
                        _sectionLabel("تقرير أداء المتدرب"),
                        _buildCommentCard(
                            comments ?? "تم إنهاء البرنامج التدريبي بنجاح.",
                            Icons.comment_bank_rounded,
                            "ملاحظات المشرف الميداني"
                        ),
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

  // ── [الدوال المساعدة - تصميم VIP] ──

  Widget _buildHeaderGradient(int score) => Container(
    decoration: const BoxDecoration(gradient: AppColors.splashGradient, borderRadius: BorderRadius.vertical(bottom: Radius.circular(60))),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 50),
      Container(
        width: 140, height: 140,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white10, border: Border.all(color: Colors.white24, width: 2)),
        child: Center(child: Text("$score%", style: const TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.w900))),
      ),
      const SizedBox(height: 20),
      Text(_getGradeText(score), style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
    ]),
  );

  Widget _buildScoreDetailCard(int score) => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)]),
    child: Row(children: [
      const CircleAvatar(backgroundColor: Color(0xFFFFF4E5), child: Icon(Icons.workspace_premium_rounded, color: Colors.orange)),
      const SizedBox(width: 15),
      Text("المعدل المكتسب: $score من 100", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _buildCommentCard(String text, IconData icon, String title) => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: AppColors.primaryBlue, size: 20), const SizedBox(width: 10), Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: Colors.blueGrey))]),
      const Divider(height: 30),
      Text(text, style: GoogleFonts.tajawal(height: 1.7, fontSize: 14)),
    ]),
  );

  Widget _sectionLabel(String t) => Padding(padding: const EdgeInsets.only(right: 10, bottom: 15), child: Text(t, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black54)));

  String _getGradeText(int s) {
    if (s >= 90) return "ممتاز جداً ✨";
    if (s >= 80) return "جيد جداً ⭐";
    return "ناجح ✅";
  }

  Widget _buildNoEvaluationState(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.assignment_late_rounded, size: 80, color: Colors.grey.shade300),
      const SizedBox(height: 20),
      Text("التقييم قيد الرصد", style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10), child: Text("المؤسسة لم ترفع بيانات التقييم بشكل نهائي بعد.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
      TextButton(onPressed: () => Navigator.pop(context), child: const Text("العودة للخلف")),
    ]),
  );
}
