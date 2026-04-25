import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../core/api/api_s.dart';
import 'explore/opportunity_detail_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final VoidCallback onSeeAllPressed;
  const StudentHomeScreen({super.key, required this.onSeeAllPressed});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  late Future<Map<String, dynamic>> _statsFuture;
  late Future<Map<String, dynamic>> _timelineFuture;
  late Future<List<dynamic>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    _statsFuture = ApiService().getDashboardStats();
    _timelineFuture = ApiService().getTimeline();
    _recommendationsFuture = ApiService().getOpportunities();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: RefreshIndicator(
          onRefresh: () async => setState(() => _loadDashboardData()),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 100), // مسافة علوية بديلة للهيدر
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. [قسم الأرقام والإحصائيات]: يظهر في أعلى الشاشة مباشرة
                _sectionTitle("نظرة عامة على النشاط", Icons.grid_view_rounded),
                const SizedBox(height: 15),
                _buildQuickStats(),

                // 2. [مسار الطلب]: تتبع الحالة الحالية
                const SizedBox(height: 35),
                _sectionTitle("حالة طلب الانضمام الأخير", Icons. analytics_outlined),
                const SizedBox(height: 15),
                _buildTimelineCard(),

                // 3. [فرص مقترحة]: بطاقات الفرص المتاحة
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionTitle("فرص تدريبية مقترحة", Icons.auto_awesome_rounded),
                    TextButton(
                      onPressed: widget.onSeeAllPressed,
                      child: Text("عرض الكل",
                          style: GoogleFonts.tajawal(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                _buildRecommendationsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // كروت الإحصائيات (الفرص المتاحة وطلباتي)
  Widget _buildQuickStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data?['data'] ?? {};
        return Row(
          children: [
            _statItem("فرص متاحة حالياً", stats['total_opportunities']?.toString() ?? "0", Colors.orange),
            const SizedBox(width: 12),
            _statItem("طلباتي المقدمة", stats['my_requests_count']?.toString() ?? "0", AppColors.primaryBlue),
          ],
        );
      },
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.tajawal(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // كرت مسار الطلب (التايم لاين)
  Widget _buildTimelineCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _timelineFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final steps = snapshot.data?['data']?['steps'] ?? [];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: steps.isEmpty
              ? const Center(child: Text("لا توجد طلبات تدريب مسجلة حالياً"))
              : Column(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              bool isDone = step['is_completed'] ?? false;
              return IntrinsicHeight(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Icon(isDone ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                            color: isDone ? Colors.green : Colors.grey.shade300, size: 22),
                        if (index != steps.length - 1)
                          Expanded(child: Container(width: 2, color: isDone ? Colors.green : Colors.grey.shade100)),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(step['title'] ?? "",
                          style: GoogleFonts.tajawal(fontSize: 14,
                              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                              color: isDone ? Colors.black87 : Colors.grey)),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // قائمة الفرص المقترحة
  Widget _buildRecommendationsList() {
    return FutureBuilder<List<dynamic>>(
      future: _recommendationsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final list = snapshot.data!.reversed.take(3).toList();
        return Column(
          children: list.map((opp) => _recommendationCard(opp)).toList(),
        );
      },
    );
  }

  Widget _recommendationCard(dynamic opp) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => OpportunityDetailScreen(opportunity: opp))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              height: 48, width: 48,
              decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.business_center_rounded, color: AppColors.primaryBlue, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opp['title'] ?? "", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(opp['institution']?['name'] ?? "جهة غير محددة",
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ],
    );
  }
}
