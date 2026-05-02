import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';
import 'institution_auth_guard.dart';

class InstitutionDashboard extends StatefulWidget {
  const InstitutionDashboard({super.key});

  @override
  State<InstitutionDashboard> createState() => _InstitutionDashboardState();
}

class _InstitutionDashboardState extends State<InstitutionDashboard> {

  void _navigateToTab(int index) {
    final wrapperState = context.findAncestorStateOfType<InstitutionMainWrapperState>();
    if (wrapperState != null) {
      wrapperState.jumpToTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? "لوحة التحكم الإحصائية" : "Dashboard Overview",
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),

              FutureBuilder<Map<String, dynamic>>(
                future: ApiService().getInstitutionDashboardStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ));
                  }

                  final stats = snapshot.data?['data'] ?? {};
                  final int pendingCount = int.tryParse(stats['pending_requests_count']?.toString() ?? '0') ?? 0;

                  return Column(
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 1.1,
                        children: [
                          _buildStatCard(
                              isAr ? "إجمالي الفرص" : "Total Opps",
                              stats['total_opportunities']?.toString() ?? "0",
                              Icons.business_center_outlined,
                              Colors.blue, isDark,
                                  () => _navigateToTab(1) // ينتقل لإدارة الفرص
                          ),
                          _buildStatCard(
                              isAr ? "المتدربون النشطون" : "Active Interns",
                              stats['active_interns']?.toString() ?? "0",
                              Icons.people_outline,
                              Colors.teal, isDark,
                                  () => _navigateToTab(3) // ينتقل للمتابعة والتقييم
                          ),
                          _buildStatCard(
                              isAr ? "طلبات المراجعة" : "Pending Requests",
                              pendingCount.toString(),
                              Icons.hourglass_empty_rounded,
                              Colors.orange, isDark,
                                  () => _navigateToTab(2) // ينتقل لطلبات المتقدمين
                          ),
                          _buildStatCard(
                              isAr ? "البلاغات" : "Complaints",
                              "0",
                              Icons.report_problem_outlined,
                              Colors.redAccent, isDark,
                                  () {
                                // إذا كان عندك صفحة بلاغات مستقلة أو تنبيه
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(isAr ? "مركز البلاغات قيد التطوير" : "Complaints center coming soon"))
                                );
                              }
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),
                      _buildOverviewBox(isAr, isDark),
                      const SizedBox(height: 25),
                      _buildDynamicQuickAction(pendingCount, isAr, isDark),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // 👈 تفعيل الضغط
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
          boxShadow: [BoxShadow(color: isDark ? Colors.black26 : color.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 5),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.tajawal(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewBox(bool isAr, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 10),
              Text(isAr ? "نظرة عامة" : "Insights", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          const Divider(height: 30),
          Text(
            isAr
                ? "مرحباً بك، يمكنك إدارة المتقدمين والفرص التدريبية ومتابعة تقارير المتدربين من خلال القائمة السفلية."
                : "Welcome, you can manage applicants, opportunities and track intern reports from the bottom menu.",
            style: GoogleFonts.tajawal(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54, height: 1.8),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicQuickAction(int count, bool isAr, bool isDark) {
    bool hasRequests = count > 0;
    Color statusColor = hasRequests ? AppColors.primaryBlue : Colors.green;
    return GestureDetector(
      onTap: hasRequests ? () => _navigateToTab(2) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(isDark ? 0.15 : 0.05),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: statusColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(hasRequests ? Icons.notification_important_rounded : Icons.check_circle_rounded, color: statusColor, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hasRequests ? (isAr ? "تنبيه: طلبات معلقة" : "Action Required") : (isAr ? "كل شيء مكتمل" : "All Caught Up"),
                      style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor)),
                  const SizedBox(height: 2),
                  Text(hasRequests ? (isAr ? "لديك $count طلبات جديدة، اضغط للمراجعة." : "You have $count pending requests, tap to review.") : (isAr ? "لا توجد طلبات جديدة حالياً." : "No pending requests."),
                      style: GoogleFonts.tajawal(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
