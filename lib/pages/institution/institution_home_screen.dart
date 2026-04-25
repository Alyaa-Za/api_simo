import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';

class InstitutionDashboard extends StatefulWidget {
  const InstitutionDashboard({super.key});

  @override
  State<InstitutionDashboard> createState() => _InstitutionDashboardState();
}

class _InstitutionDashboardState extends State<InstitutionDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "لوحة التحكم الإحصائية",
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),

              FutureBuilder<Map<String, dynamic>>(
                future: ApiService().getInstitutionDashboardStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final stats = snapshot.data?['data'] ?? {};

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      _buildStatCard("إجمالي الفرص", stats['total_opportunities']?.toString() ?? "0", Icons.business_center_outlined, Colors.blue),
                      _buildStatCard("المتدربون النشطون", stats['active_interns']?.toString() ?? "0", Icons.people_outline, Colors.teal),
                      _buildStatCard("طلبات المراجعة", stats['pending_requests_count']?.toString() ?? "0", Icons.hourglass_empty_rounded, Colors.orange),
                      _buildStatCard("البلاغات المفتوحة", "0", Icons.report_problem_outlined, Colors.redAccent),
                    ],
                  );
                },
              ),

              const SizedBox(height: 25),

              _buildOverviewBox(),

              const SizedBox(height: 25),

              _buildQuickAction(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 10),
              Text("نظرة عامة على النظام", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 30),
          Text(
            "مرحباً بك في لوحة تحكم المؤسسة، يمكنك البدء بمراجعة الطلبات المعلقة أو إضافة فرص تدريبية جديدة من خلال التبويبات بالأسفل. النظام يساعدك على متابعة المتدربين بفعالية.",
            style: GoogleFonts.tajawal(fontSize: 13, color: Colors.black54, height: 1.8),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "لديك طلبات جديدة بانتظار قرارك، توجه لتبويب الطلبات.",
              style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
