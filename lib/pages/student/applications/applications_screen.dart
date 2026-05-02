import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  Future<List<dynamic>> _fetchRequests() async {
    try {
      final response = await ApiService().getMyRequests();
      return response;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10)],
              ),
              child: TabBar(
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: Colors.grey.shade500,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: isAr ? "قيد المراجعة" : "Reviewing"),
                  Tab(text: isAr ? "المقبولة" : "Accepted"),
                  Tab(text: isAr ? "المرفوضة" : "Rejected"),
                ],
              ),
            ),
          ),
          body: FutureBuilder<List<dynamic>>(
            future: _fetchRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allData = snapshot.data ?? [];
              final pending = allData.where((r) =>
                  ['pending', 'pending_admin', 'pending_institution', 'under_review'].contains(r['status'])).toList();
              final accepted = allData.where((r) => r['status'] == 'approved').toList();
              final rejected = allData.where((r) => r['status'] == 'rejected').toList();

              return TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildListView(pending, "pending", isAr, isDark),
                  _buildListView(accepted, "accepted", isAr, isDark),
                  _buildListView(rejected, "rejected", isAr, isDark),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<dynamic> requests, String type, bool isAr, bool isDark) {
    if (requests.isEmpty) return _buildEmptyState(type, isAr);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final item = requests[index];
        final opp = item['opportunity'] ?? {};

        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent),
            boxShadow: [
              BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.03),
                  blurRadius: 15, offset: const Offset(0, 8)
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: AppColors.primaryBlue,
                collapsedIconColor: Colors.grey,
                tilePadding: const EdgeInsets.all(15),
                leading: _buildStatusIcon(type, isDark),
                title: Text(
                  opp['title'] ?? (isAr ? "فرصة تدريبية" : "Training Opportunity"),
                  style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold, fontSize: 15,
                      color: isDark ? Colors.white : AppColors.textDark
                  ),
                ),
                subtitle: Text(
                  "${opp['city'] ?? (isAr ? 'الموقع يحدد لاحقاً' : 'Location TBA')} • ${item['submission_date'] ?? ''}",
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey),
                ),
                children: [
                  _buildExpandedDetails(item, type, isAr, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedDetails(dynamic item, String type, bool isAr, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: isDark ? Colors.white10 : Colors.grey.shade100),
          const SizedBox(height: 10),
          _detailRow(isDark, Icons.business_rounded, isAr ? "الجهة:" : "Entity:",
              item['opportunity']?['institution']?['name'] ?? (isAr ? "غير محدد" : "Not set")),
          const SizedBox(height: 8),
          if (type == "rejected")
            _detailRow(isDark, Icons.info_outline, isAr ? "سبب الرفض:" : "Reason:",
                item['rejection_reason'] ?? item['institution_notes'] ?? (isAr ? "نعتذر، تم الاكتفاء بالعدد." : "Sorry, positions filled."),
                color: Colors.redAccent),
          if (type == "accepted")
            _detailRow(isDark, Icons.celebration_rounded, isAr ? "ملاحظة:" : "Note:",
                isAr ? "مبروك! سيتم التواصل معك قريباً." : "Congrats! We will contact you soon.",
                color: Colors.green),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _detailRow(bool isDark, IconData icon, String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color ?? (isDark ? Colors.white38 : Colors.grey)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
        const SizedBox(width: 5),
        Expanded(child: Text(value, style: TextStyle(fontSize: 12, color: color ?? (isDark ? Colors.white60 : Colors.black54)))),
      ],
    );
  }

  Widget _buildStatusIcon(String status, bool isDark) {
    Color color = status == "accepted" ? Colors.green : (status == "rejected" ? Colors.redAccent : Colors.orange);
    IconData icon = status == "accepted" ? Icons.verified_rounded : (status == "rejected" ? Icons.error_rounded : Icons.pending_actions_rounded);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(15)),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildEmptyState(String type, bool isAr) {
    String msg = type == "pending"
        ? (isAr ? "لا توجد طلبات قيد المراجعة" : "No requests under review")
        : (type == "accepted"
        ? (isAr ? "لم يتم قبول أي طلب بعد" : "No accepted requests yet")
        : (isAr ? "سجل الرفض فارغ" : "No rejected requests"));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(msg, style: GoogleFonts.tajawal(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
