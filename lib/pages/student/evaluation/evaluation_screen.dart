import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';

class EvaluationScreen extends StatelessWidget {
  const EvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder<Map<String, dynamic>>(
          future: ApiService().getEvaluation(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            }

            final Map<String, dynamic> rawData = snapshot.data ?? {};
            final Map<String, dynamic> dataPart = rawData['data'] ?? rawData;
            final eval = dataPart.containsKey('evaluation') ? dataPart['evaluation'] : dataPart;

            final dynamic rawScore = eval['final_score'] ?? eval['score'] ?? eval['total_score'];
            final String? comments = eval['comments'] ?? eval['feedback'] ?? eval['notes'];

            if (rawScore == null) {
              return _buildNoEvaluationState(context, isAr);
            }

            final int score = int.tryParse(rawScore.toString()) ?? 0;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 320.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeaderGradient(score, isAr),
                  ),
                  leading: IconButton(
                    icon: Icon(isAr ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(isAr ? "النتيجة النهائية" : "Final Result",
                      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: Colors.white)),
                  centerTitle: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel(isAr ? "تفاصيل النتيجة المعتمدة" : "Result Details", isDark),
                        _buildScoreDetailCard(score, isAr, isDark),
                        const SizedBox(height: 35),
                        _sectionLabel(isAr ? "تقرير أداء المتدرب" : "Performance Report", isDark),
                        _buildCommentCard(
                            comments ?? (isAr ? "تم إنهاء البرنامج التدريبي بنجاح." : "Training program completed successfully."),
                            Icons.comment_bank_rounded,
                            isAr ? "ملاحظات المشرف الميداني" : "Mentor Feedback",
                            isDark
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

  Widget _buildHeaderGradient(int score, bool isAr) => Container(
    decoration: const BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(60))
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 50),
      Container(
        width: 140, height: 140,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white10, border: Border.all(color: Colors.white24, width: 2)),
        child: Center(child: Text("$score%", style: const TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.w900))),
      ),
      const SizedBox(height: 20),
      Text(_getGradeText(score, isAr), style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
    ]),
  );

  Widget _buildScoreDetailCard(int score, bool isAr, bool isDark) => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 15)],
    ),
    child: Row(children: [
      CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1),
          child: const Icon(Icons.workspace_premium_rounded, color: Colors.orange)
      ),
      const SizedBox(width: 15),
      Text(
          isAr ? "المعدل المكتسب: $score من 100" : "Score: $score out of 100",
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)
      ),
    ]),
  );

  Widget _buildCommentCard(String text, IconData icon, String title, bool isDark) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.blueGrey))
      ]),
      const Divider(height: 30),
      Text(text, style: GoogleFonts.tajawal(height: 1.7, fontSize: 14, color: isDark ? Colors.white60 : Colors.black87)),
    ]),
  );

  Widget _sectionLabel(String t, bool isDark) => Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 15, left: 10),
      child: Text(t, style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? Colors.white38 : Colors.black54))
  );

  String _getGradeText(int s, bool isAr) {
    if (s >= 90) return isAr ? "ممتاز " : "Excellent ";
    if (s >= 80) return isAr ? "جيد جداً " : "Very Good ";
    return isAr ? "ناجح " : "Pass ";
  }

  Widget _buildNoEvaluationState(BuildContext context, bool isAr) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.assignment_late_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
      const SizedBox(height: 20),
      Text(isAr ? "التقييم قيد الرصد" : "Evaluation in Progress",
          style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Text(
              isAr ? "المؤسسة لم ترفع بيانات التقييم بشكل نهائي بعد." : "The institution has not uploaded the final evaluation yet.",
              textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)
          )
      ),
      TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isAr ? "العودة للخلف" : "Go Back")
      ),
    ]),
  );
}
