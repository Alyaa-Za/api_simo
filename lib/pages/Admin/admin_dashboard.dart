import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';
import 'admin_main_wrapper.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  void _jump(int index) {
    final wrapper = context.findAncestorStateOfType<AdminMainWrapperState>();
    if (wrapper != null) {
      wrapper.jumpToTab(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService().getAdminDashboardStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                isAr ? "حدث خطأ في الاتصال بالباك آند" : "Connection Error with Backend",
                style: GoogleFonts.tajawal(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            );
          }

          final res = snapshot.data ?? {};
          final stats = res['data'] ?? res;

          String studentsCount = (stats['total_students'] ?? "0").toString();
          String institutionsCount = (stats['total_institutions'] ?? "0").toString();
          String oppsCount = (stats['active_opportunities'] ?? "0").toString();
          String pendingReqCount = (stats['pending_admin_requests'] ?? stats['pending_requests'] ?? "0").toString();

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? "نظام الإشراف الإداري" : "Admin Supervision System",
                            style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAr ? "لوحة التحكم الإحصائية" : "Statistical Dashboard",
                            style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.textDark),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white10 : const Color(0xFFF0F4F8),
                            elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                        ),
                        child: Text(isAr ? "تحديث" : "Refresh", style: GoogleFonts.tajawal(fontSize: 11, color: isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 25),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.2,
                    children: [
                      _buildWebStyleStatCard(
                          isAr ? "إجمالي الطلاب" : "Total Students",
                          studentsCount,
                          Icons.people_outline, Colors.blue, isDark,
                          onTap: () => _jump(2) // فتح تبويب الطلاب
                      ),
                      _buildWebStyleStatCard(
                          isAr ? "المؤسسات المعتمدة" : "Approved Entities",
                          institutionsCount,
                          Icons.business_center_outlined, Colors.orange, isDark,
                          onTap: () => _jump(1) // فتح تبويب المؤسسات
                      ),
                      _buildWebStyleStatCard(
                          isAr ? "الفرص النشطة" : "Active Opps",
                          oppsCount,
                          Icons.work_outline_rounded, Colors.green, isDark
                      ),
                      _buildWebStyleStatCard(
                          isAr ? "طلبات معلقة" : "Pending Req",
                          pendingReqCount,
                          Icons.assignment_late_outlined, Colors.redAccent, isDark,
                          onTap: () => _jump(3) // فتح تبويب الطلبات
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  _buildStatusOverviewBox(
                      isAr,
                      isDark,
                      pendingRequests: pendingReqCount,
                      totalStudents: studentsCount
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWebStyleStatCard(String label, String value, IconData icon, Color color, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: GoogleFonts.tajawal(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 16),
                )
              ],
            ),
            Text(value, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOverviewBox(bool isAr, bool isDark, {required String pendingRequests, required String totalStudents}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(isAr ? "ملخص الحالة" : "Status Overview", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                Text(isAr ? "إحصائية سريعة بجميع العناصر الحالية" : "Quick list of all current items", style: GoogleFonts.tajawal(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          _statusOverviewRow(isAr ? "إجمالي الطلاب بالمنظومة" : "Total Students", totalStudents, true, () => _jump(2)),
          _statusOverviewRow(isAr ? "طلبات بانتظار موافقة الأدمن" : "Requests Pending Approval", pendingRequests, false, () => _jump(3)),
        ],
      ),
    );
  }

  Widget _statusOverviewRow(String title, String count, bool hasDivider, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: hasDivider ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.15))) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.tajawal(fontSize: 12, color: Colors.white)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text(count, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ),
          ],
        ),
      ),
    );
  }
}
