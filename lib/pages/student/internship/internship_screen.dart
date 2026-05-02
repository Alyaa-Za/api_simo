import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';
import 'reports_screen.dart';
import '../evaluation/evaluation_screen.dart';

class InternshipScreen extends StatefulWidget {
  const InternshipScreen({super.key});

  @override
  State<InternshipScreen> createState() => _InternshipScreenState();
}

class _InternshipScreenState extends State<InternshipScreen> {
  Future<Map<String, dynamic>> _fetchInternshipData() async {
    final response = await ApiService().getMyInternship();
    return response['data'] ?? {};
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
        body: FutureBuilder<Map<String, dynamic>>(
          future: _fetchInternshipData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data;
            if (snapshot.hasError || data == null || data.isEmpty) {
              return _buildNoInternship(isAr, isDark);
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildPremiumHeader(
                      data['opportunity']?['title'] ?? (isAr ? "برنامج التدريب الميداني" : "Internship Program"),
                      data['mentor_name'] ?? (isAr ? "لم يحدد" : "Not assigned"),
                      data['institution']?['name'] ?? (isAr ? "الجهة المدربة" : "Host Entity"),
                      isAr
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.1,
                    children: [
                      _buildOptionCard(
                        context,
                        isAr ? "التقارير اليومية" : "Daily Reports",
                        isAr ? "رفع ومتابعة الإنجاز" : "Track performance",
                        Icons.edit_note_rounded,
                        const Color(0xFF6366F1),
                        const ReportsScreen(),
                        isDark: isDark,
                      ),
                      _buildOptionCard(
                        context,
                        isAr ? "تقييم الأداء" : "Evaluation",
                        isAr ? "النتيجة والملاحظات" : "Results & Feedback",
                        Icons.auto_graph_rounded,
                        const Color(0xFFF59E0B),
                        const EvaluationScreen(),
                        isDark: isDark,
                      ),
                      _buildOptionCard(
                        context,
                        isAr ? "المهام الموكلة" : "Assigned Tasks",
                        isAr ? "قائمة المتطلبات" : "Requirement list",
                        Icons.task_alt_rounded,
                        const Color(0xFF10B981),
                        null,
                        isDetail: true,
                        taskData: data,
                        isDark: isDark,
                        isAr: isAr,
                      ),
                      _buildOptionCard(
                        context,
                        isAr ? "الخطة الزمنية" : "Timeline",
                        isAr ? "بداية ونهاية البرنامج" : "Start & End dates",
                        Icons.calendar_today_rounded,
                        const Color(0xFF3B82F6),
                        null,
                        isTimeline: true,
                        taskData: data,
                        isDark: isDark,
                        isAr: isAr,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(String title, String mentor, String company, bool isAr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 80, 30, 40),
      decoration: const BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.stars_rounded, color: Colors.white, size: 45),
          ),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.tajawal(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(company, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text("${isAr ? 'المشرف المباشر:' : 'Mentor:'} $mentor", style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget? destination, {bool isDetail = false, bool isTimeline = false, Map? taskData, required bool isDark, bool isAr = true}) {
    return InkWell(
      onTap: () {
        if (isDetail) {
          _showTaskDetails(context, taskData!, isDark, isAr);
        } else if (isTimeline) {
          _showTimelineDetails(context, taskData!, isDark, isAr);
        } else if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (c) => destination));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Map data, bool isDark, bool isAr) {
    _showCustomSheet(context, isAr ? "المهام المطلوبة" : "Assigned Tasks", data['assigned_tasks'] ?? (isAr ? "سيقوم المشرف بإضافة المهام قريباً." : "No tasks added yet."), isDark, isAr);
  }

  void _showTimelineDetails(BuildContext context, Map data, bool isDark, bool isAr) {
    String content = isAr
        ? "تاريخ البداية: ${data['actual_start_date']}\nتاريخ النهاية: ${data['actual_end_date'] ?? 'مستمر حالياً'}"
        : "Start Date: ${data['actual_start_date']}\nEnd Date: ${data['actual_end_date'] ?? 'Ongoing'}";
    _showCustomSheet(context, isAr ? "الجدول الزمني" : "Timeline", content, isDark, isAr);
  }

  void _showCustomSheet(BuildContext context, String title, String content, bool isDark, bool isAr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 25),
            Text(title, style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            const SizedBox(height: 20),
            Text(content, style: TextStyle(height: 1.8, fontSize: 14, color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInternship(bool isAr, bool isDark) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.work_off_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
        const SizedBox(height: 20),
        Text(isAr ? "لا يوجد تدريب مفعل" : "No active internship", style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    ),
  );
}
