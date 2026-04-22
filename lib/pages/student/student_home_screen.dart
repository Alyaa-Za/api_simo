import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../core/api/api_s.dart';

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
    return RefreshIndicator(
      onRefresh: () async => setState(() => _loadDashboardData()),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("نظرة عامة"),
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                final stats = snapshot.data?['data'] ?? {};
                return Row(
                  children: [
                    _buildStatCard("فرص متاحة", stats['total_opportunities']?.toString() ?? "0", Icons.local_fire_department, Colors.orange),
                    const SizedBox(width: 15),
                    _buildStatCard("طلباتي", stats['my_requests_count']?.toString() ?? "0", Icons.assignment_turned_in, Colors.blue),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),
            _sectionTitle("مسار طلبك الأخير"),
            FutureBuilder<Map<String, dynamic>>(
              future: _timelineFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final steps = snapshot.data?['data']?['steps'] ?? [];
                return _buildTimeline(steps);
              },
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle("فرص مقترحة لك"),
                TextButton(
                    onPressed: widget.onSeeAllPressed,
                    child: const Text("الكل", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold))
                ),
              ],
            ),

            FutureBuilder<List<dynamic>>(
              future: _recommendationsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final list = snapshot.data!.reversed.take(3).toList();
                return Column(
                  children: list.map((opp) => _buildRecommendationCard(opp)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 15),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(List<dynamic> steps) {
    if (steps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
        child: const Center(child: Text("لا توجد خطوات مسجلة لهذا الطلب")),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];

          String title = step['title']?.toString() ?? "خطوة غير محددة";
          bool isCompleted = step['is_completed'] ?? false;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isCompleted ? Colors.green : Colors.grey,
                    size: 22,
                  ),
                  if (index != steps.length - 1)
                    Container(width: 2, height: 40, color: Colors.grey.shade200),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    title,
                    style: GoogleFonts.tajawal(
                      color: isCompleted ? Colors.black87 : Colors.grey,
                      fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRecommendationCard(dynamic opp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(backgroundColor: AppColors.primaryBlue.withOpacity(0.1), child: const Icon(Icons.business_center, color: AppColors.primaryBlue, size: 20)),
        title: Text(opp['title'] ?? "", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("${opp['city'] ?? ''} • ${opp['department'] ?? ''}", style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: GoogleFonts.tajawal(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark));
}
