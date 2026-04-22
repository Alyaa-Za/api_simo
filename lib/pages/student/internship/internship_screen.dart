import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
import 'reports_screen.dart';
import 'attendance_screen.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeaderCard(
                  data['opportunity']?['title'] ?? "تدريب ميداني",
                  data['mentor_name'] ?? "لم يحدد مشرف بعد",
                ),

                const SizedBox(height: 30),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    _buildMenuCard(context, "رفع التقارير", Icons.description_outlined, Colors.blue,
                        const ReportsScreen()),
                    _buildMenuCard(context, "سجل التحضير", Icons.fact_check_outlined, Colors.teal,
                        const AttendanceScreen()),
                    _buildMenuCard(context, "تقييم الأداء", Icons.star_outline_rounded, Colors.orange,
                        const EvaluationScreen()),
                    _buildMenuCard(context, "تفاصيل المهام", Icons.info_outline, Colors.purple,
                        null, isDetail: true, taskData: data),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(String title, String mentor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 15)],
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 50),
          const SizedBox(height: 15),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("المشرف: $mentor", style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, Widget? destination, {bool isDetail = false, Map? taskData}) {
    return InkWell(
      onTap: () {
        if (isDetail) {
          _showTaskDetails(context, taskData!);
        } else if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (c) => destination));
        }
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 10),
            Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Map data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("المهام الموكلة إليك", style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 10),
            Text(data['assigned_tasks'] ?? "لم يتم إسناد مهام محددة بعد.", style: const TextStyle(height: 1.5)),
            const SizedBox(height: 20),
            Text("فترة التدريب:", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
            Text("${data['actual_start_date']} إلى ${data['actual_end_date'] ?? 'الآن'}"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInternship() => Center(child: Text("لا يوجد تدريب نشط حالياً", style: GoogleFonts.tajawal(color: Colors.grey)));
}
