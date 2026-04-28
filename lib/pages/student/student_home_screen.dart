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
  late Future<Map<String, dynamic>> _profileFuture;
  late Future<Map<String, dynamic>> _internshipFuture;
  late Future<List<dynamic>> _oppsFuture;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    _profileFuture = ApiService().getProfile();
    _internshipFuture = ApiService().getMyInternship();
    _oppsFuture = ApiService().getOpportunities();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        body: RefreshIndicator(
          onRefresh: () async => setState(() => _loadAllData()),
          child: FutureBuilder(
            future: Future.wait([_profileFuture, _internshipFuture, _oppsFuture]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final profileData = snapshot.data?[0]['data'] ?? {};
              final internshipData = snapshot.data?[1]['data'] ?? {};
              final recommendations = snapshot.data?[2] ?? [];


              int completionPercentage = profileData['completion_percentage'] ?? 0;
              bool isComplete = profileData['is_profile_complete'] ?? false;

              bool hasActiveIntern = internshipData != null && internshipData.isNotEmpty;
              int activeCount = hasActiveIntern ? 1 : 0;
              String internTitle = hasActiveIntern
                  ? (internshipData['opportunity']?['title'] ?? "جاري التدريب")
                  : "لا يوجد تدريب نشط حالياً";

              List steps = profileData['latest_application_steps'] ?? [];

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatBox(
                            "اكتمال الملف",
                            isComplete ? "مكتمل " : "$completionPercentage%",
                            isComplete ? Colors.green : Colors.orange,
                            Icons.person_pin_rounded
                        ),
                        const SizedBox(width: 15),
                        _buildStatBox(
                            "التدريبات النشطة",
                            activeCount.toString(),
                            AppColors.primaryBlue,
                            Icons.workspace_premium_rounded
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _buildHeroInternCard(hasActiveIntern, internTitle),

                    if (steps.isNotEmpty) ...[
                      const SizedBox(height: 40),
                      _sectionTitle("تتبع طلب الانضمام", Icons.bubble_chart_rounded),
                      const SizedBox(height: 15),
                      _buildTimeline(steps),
                    ],

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle("فرص مقترحة لك", Icons.auto_awesome_rounded),
                        TextButton(
                            onPressed: widget.onSeeAllPressed,
                            child: Text("استكشف الكل", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.primaryBlue))
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildRecommendations(recommendations),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String val, Color col, IconData ico) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: col.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Icon(ico, color: col, size: 28),
            const SizedBox(height: 15),
            Text(val, style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroInternCard(bool active, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: active ? AppColors.splashGradient : null,
        color: active ? null : Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: active ? Colors.white24 : Colors.orange.withOpacity(0.1),
            child: Icon(active ? Icons.verified_user_rounded : Icons.info_rounded, color: active ? Colors.white : Colors.orange),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(active ? "أنت الآن في مرحلة التدريب" : "حالة البرنامج",
                    style: TextStyle(color: active ? Colors.white70 : Colors.grey, fontSize: 12)),
                Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 17, color: active ? Colors.white : AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List steps) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35)),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          bool done = step['is_completed'] ?? false;
          bool current = step['is_current'] ?? false;
          return Row(
            children: [
              Column(
                children: [
                  Icon(done ? Icons.check_circle_rounded : (current ? Icons.radio_button_checked : Icons.radio_button_off),
                      color: done ? Colors.green : (current ? AppColors.primaryBlue : Colors.grey.shade200), size: 24),
                  if (index != steps.length - 1) Container(width: 2, height: 35, color: done ? Colors.green : Colors.grey.shade100),
                ],
              ),
              const SizedBox(width: 20),
              Text(step['title'] ?? "", style: GoogleFonts.tajawal(fontSize: 14, fontWeight: current ? FontWeight.w900 : FontWeight.bold)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRecommendations(List opps) {
    if (opps.isEmpty) return const Center(child: Text("لا توجد فرص مقترحة حالياً"));
    final list = opps.take(3).toList();
    return Column(
      children: list.map((opp) => GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => OpportunityDetailScreen(opportunity: opp))),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              Container(
                height: 55, width: 55,
                decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.business_center_outlined, color: AppColors.primaryBlue, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opp['title'] ?? "عنوان الفرصة", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(opp['institution']?['name'] ?? "جهة التدريب", style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _sectionTitle(String t, IconData i) {
    return Row(
      children: [
        Icon(i, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 10),
        Text(t, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
      ],
    );
  }
}
