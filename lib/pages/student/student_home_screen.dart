import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';
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
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

              String internTitle = hasActiveIntern
                  ? (internshipData['opportunity']?['title'] ?? (isAr ? "جاري التدريب" : "In Progress"))
                  : (isAr ? "لا يوجد تدريب نشط" : "No Active Training");

              List steps = profileData['latest_application_steps'] ?? [];

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. كروت الإحصائيات (المربعات)
                    Row(
                      children: [
                        _buildStatBox(
                            isAr ? "اكتمال الملف" : "Profile",
                            isComplete ? (isAr ? "مكتمل" : "Complete") : "$completionPercentage%",
                            isComplete ? Colors.green : Colors.orange,
                            Icons.person_pin_rounded, isDark
                        ),
                        const SizedBox(width: 15),
                        _buildStatBox(
                            isAr ? "التدريبات" : "Internships",
                            hasActiveIntern ? "1" : "0",
                            AppColors.primaryBlue,
                            Icons.workspace_premium_rounded, isDark
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // 2. كرت التدريب الحالي (Slate Style)
                    _buildHeroInternCard(hasActiveIntern, internTitle, isAr, isDark),

                    // 3. مسار الطلب (Slate Style)
                    if (steps.isNotEmpty) ...[
                      const SizedBox(height: 40),
                      _sectionTitle(isAr ? "تتبع طلب الانضمام" : "Application Tracking", Icons.bubble_chart_rounded, isDark),
                      const SizedBox(height: 15),
                      _buildTimeline(steps, isDark),
                    ],

                    const SizedBox(height: 40),

                    // 4. التوصيات (Slate Style)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle(isAr ? "فرص مقترحة" : "Recommendations", Icons.auto_awesome_rounded, isDark),
                        TextButton(
                            onPressed: widget.onSeeAllPressed,
                            child: Text(isAr ? "استكشف الكل" : "See All", style: const TextStyle(fontWeight: FontWeight.bold))
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildRecommendations(recommendations, isAr, isDark),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── [تصميم المربعات المطور] ──
  Widget _buildStatBox(String title, String val, Color col, IconData ico, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Icon(ico, color: col, size: 28),
            const SizedBox(height: 12),
            Text(val, style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.textDark)),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ── [تصميم كرت الهيرو المطور] ──
  Widget _buildHeroInternCard(bool active, String title, bool isAr, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: active ? AppColors.splashGradient : null,
        color: active ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(30),
        border: (isDark && !active) ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: active ? Colors.white24 : Colors.orange.withOpacity(0.1),
            child: Icon(active ? Icons.verified_user_rounded : Icons.info_rounded, color: active ? Colors.white : Colors.orange),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(active ? (isAr ? "أنت الآن متدرب" : "Currently Training") : (isAr ? "حالة البرنامج" : "Program Status"),
                    style: TextStyle(color: active ? Colors.white70 : Colors.grey, fontSize: 11)),
                Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15, color: active ? Colors.white : (isDark ? Colors.white : AppColors.textDark))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── [تصميم التايم لاين المطور] ──
  Widget _buildTimeline(List steps, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
      ),
      child: Column(
        children: steps.map((step) {
          bool done = step['is_completed'] ?? false;
          bool current = step['is_current'] ?? false;
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Icon(done ? Icons.check_circle_rounded : (current ? Icons.radio_button_checked : Icons.radio_button_off),
                    color: done ? Colors.green : (current ? AppColors.primaryBlue : Colors.grey.shade400), size: 22),
                const SizedBox(width: 15),
                Text(step['title'] ?? "", style: GoogleFonts.tajawal(fontSize: 13, fontWeight: current ? FontWeight.bold : FontWeight.normal, color: isDark ? Colors.white70 : Colors.black87)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── [تصميم التوصيات المطور] ──
  Widget _buildRecommendations(List opps, bool isAr, bool isDark) {
    if (opps.isEmpty) return const Center(child: Text("..."));
    return Column(
      children: opps.take(3).map((opp) => GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => OpportunityDetailScreen(opportunity: opp))),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Container(
                height: 50, width: 50,
                decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.business_center_outlined, color: AppColors.primaryBlue, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(opp['title'] ?? "", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.textDark)),
                  Text(opp['institution']?['name'] ?? "", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ]),
              ),
              Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _sectionTitle(String t, IconData i, bool isDark) => Row(children: [
    Icon(i, color: AppColors.primaryBlue, size: 18),
    const SizedBox(width: 8),
    Text(t, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.textDark))
  ]);
}
