import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';
import 'explore/opportunity_detail_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final VoidCallback onSeeAllPressed;
  const StudentHomeScreen({super.key, required this.onSeeAllPressed});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic> profileData = {};
  Map<String, dynamic> internshipData = {};
  List<dynamic> latestOpportunities = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  List<dynamic> _extractOppsList(dynamic res) {
    if (res == null) return [];
    if (res is List) return res;
    if (res is Map) {
      if (res['data'] != null) {
        if (res['data'] is List) return res['data'];
        if (res['data'] is Map && res['data']['items'] != null) return res['data']['items'];
      }
      if (res['items'] != null) return res['items'];
    }
    return [];
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final dynamic pRes = await ApiService().getProfile();
      final dynamic oRes = await ApiService().getOpportunities();

      dynamic iRes;
      try { iRes = await ApiService().getMyInternship(); } catch (e) { iRes = null; }

      if (mounted) {
        setState(() {
          if (pRes != null && pRes['data'] != null) {
            profileData = Map<String, dynamic>.from(pRes['data']);
          }
          List<dynamic> allOpps = _extractOppsList(oRes);
          latestOpportunities = allOpps.reversed.take(5).toList();

          debugPrint("Check Opps Count: ${latestOpportunities.length}");

          if (iRes != null && iRes['data'] != null) {
            internshipData = Map<String, dynamic>.from(iRes['data']);
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Dashboard Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    bool isComplete = profileData['is_profile_complete'] ?? false;
    int percent = profileData['completion_percentage'] ?? 0;
    bool hasIntern = internshipData.isNotEmpty && internshipData['internship_id'] != null;

    String internTitle = hasIntern
        ? (internshipData['opportunity']?['title'] ?? (isAr ? "جاري التدريب" : "In Progress"))
        : (isAr ? "لا يوجد تدريب نشط" : "No Active Training");

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatBox(isAr ? "اكتمال الملف" : "Profile", isComplete ? (isAr ? "مكتمل" : "Complete") : "$percent%", isComplete ? Colors.green : Colors.orange, Icons.person_pin_rounded, isDark),
                const SizedBox(width: 15),
                _buildStatBox(isAr ? "التدريبات" : "Internships", hasIntern ? "1" : "0", AppColors.primaryBlue, Icons.workspace_premium_rounded, isDark),
              ],
            ),
            const SizedBox(height: 15),

            _buildHeroCard(hasIntern, internTitle, isAr, isDark),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle(isAr ? "أحدث الفرص المتاحة" : "Latest Opportunities", Icons.bolt_rounded, isDark),
                TextButton(
                    onPressed: widget.onSeeAllPressed,
                    child: Text(isAr ? "استكشف الكل" : "See All", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue))
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildOppsList(latestOpportunities, isAr, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String val, Color col, IconData ico, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)],
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

  Widget _buildHeroCard(bool active, String title, bool isAr, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: active ? AppColors.splashGradient : null,
        color: active ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(30),
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
                Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14, color: active ? Colors.white : (isDark ? Colors.white : AppColors.textDark))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOppsList(List opps, bool isAr, bool isDark) {
    if (opps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.withOpacity(0.3)),
              const SizedBox(height: 10),
              Text(isAr ? "لا توجد فرص حالياً" : "No opportunities available", style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: opps.map((opp) => GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => OpportunityDetailScreen(opportunity: opp))),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(22),
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
                  Text(opp['institution']?['name'] ?? (isAr ? "مؤسسة تدريبية" : "Entity"), style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
