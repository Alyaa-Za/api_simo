import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
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
    return response['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _fetchInternshipData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return _buildNoInternship();
            }

            final data = snapshot.data!;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildPremiumHeader(
                    data['opportunity']?['title'] ?? "برنامج التدريب الميداني",
                    data['mentor_name'] ?? "المشرف الأكاديمي",
                    data['institution']?['name'] ?? "الجهة المدربة",
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
                        "التقارير اليومية",
                        "رفع ومتابعة الإنجاز",
                        Icons.edit_note_rounded,
                        const Color(0xFF6366F1),
                        const ReportsScreen(),
                      ),
                      _buildOptionCard(
                        context,
                        "تقييم الأداء",
                        "النتيجة والملاحظات",
                        Icons.auto_graph_rounded,
                        const Color(0xFFF59E0B),
                        const EvaluationScreen(),
                      ),
                      _buildOptionCard(
                        context,
                        "المهام الموكلة",
                        "قائمة المتطلبات",
                        Icons.task_alt_rounded,
                        const Color(0xFF10B981),
                        null,
                        isDetail: true,
                        taskData: data,
                      ),
                      _buildOptionCard(
                        context,
                        "الخطة الزمنية",
                        "مواعيد البداية والنهاية",
                        Icons.calendar_today_rounded,
                        const Color(0xFF3B82F6),
                        null,
                        isTimeline: true,
                        taskData: data,
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

  Widget _buildPremiumHeader(String title, String mentor, String company) {
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
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.tajawal(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(company, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text("المشرف المباشر: $mentor", style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget? destination, {bool isDetail = false, bool isTimeline = false, Map? taskData}) {
    return InkWell(
      onTap: () {
        if (isDetail) {
          _showTaskDetails(context, taskData!);
        } else if (isTimeline) {
          _showTimelineDetails(context, taskData!);
        } else if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (c) => destination));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Map data) {
    _showCustomSheet(context, "المهام المطلوبة", data['assigned_tasks'] ?? "سيقوم المشرف بإضافة المهام قريباً.");
  }

  void _showTimelineDetails(BuildContext context, Map data) {
    _showCustomSheet(context, "الجدول الزمني", "البداية: ${data['actual_start_date']}\nالنهاية: ${data['actual_end_date'] ?? 'مستمر حالياً'}");
  }

  void _showCustomSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 25),
            Text(title, style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            const SizedBox(height: 20),
            Text(content, style: const TextStyle(height: 1.8, fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInternship() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.work_off_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 20),
        Text("لا يوجد تدريب مفعل حالياً", style: GoogleFonts.tajawal(color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
