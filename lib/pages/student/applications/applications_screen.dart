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
      final dynamic response = await ApiService().getMyRequests();

      if (response is Map) {
        return response['data'] is List ? response['data'] : [];
      } else if (response is List) {
        return response;
      }

      return [];
    } catch (e) {
      debugPrint("Error fetching requests: $e");
      return [];
    }
  }


  Map<String, dynamic> _parseStatus(String status, bool isAr) {
    switch (status) {
      case 'pending_admin':
        return {
          'text': isAr ? "بانتظار مراجعة المدير" : "Pending Admin Review",
          'color': Colors.blue,
          'icon': Icons.admin_panel_settings_outlined,
          'step': 1
        };
      case 'pending_institution':
        return {
          'text': isAr ? "بانتظار قرار المؤسسة" : "Pending Entity Decision",
          'color': Colors.orange,
          'icon': Icons.account_balance_outlined,
          'step': 2
        };
      case 'approved':
      case 'accepted':
        return {
          'text': isAr ? "تم القبول النهائي" : "Accepted",
          'color': Colors.green,
          'icon': Icons.check_circle_outline,
          'step': 3
        };
      case 'rejected':
        return {
          'text': isAr ? "تم رفض الطلب" : "Rejected",
          'color': Colors.red,
          'icon': Icons.cancel_outlined,
          'step': 0
        };
      default:
        return {
          'text': isAr ? "قيد المراجعة" : "Under Review",
          'color': Colors.grey,
          'icon': Icons.hourglass_bottom_rounded,
          'step': 1
        };
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
              final pending = allData.where((r) => ['pending', 'pending_admin', 'pending_institution', 'under_review'].contains(r['status'])).toList();
              final accepted = allData.where((r) => r['status'] == 'approved' || r['status'] == 'accepted').toList();
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

  Widget _buildListView(List<dynamic> requests, String tabType, bool isAr, bool isDark) {
    if (requests.isEmpty) return _buildEmptyState(tabType, isAr);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final item = requests[index];
        final opp = item['opportunity'] ?? {};
        final statusInfo = _parseStatus(item['status'] ?? "", isAr);

        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: AppColors.primaryBlue,
                collapsedIconColor: Colors.grey,
                tilePadding: const EdgeInsets.all(15),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: statusInfo['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                  child: Icon(statusInfo['icon'], color: statusInfo['color'], size: 24),
                ),
                title: Text(
                  opp['title'] ?? (isAr ? "فرصة تدريبية" : "Training Opportunity"),
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : AppColors.textDark),
                ),
                subtitle: Text(
                  statusInfo['text'],
                  style: GoogleFonts.tajawal(fontSize: 11, color: statusInfo['color'], fontWeight: FontWeight.bold),
                ),
                children: [_buildExpandedDetails(item, statusInfo, isAr, isDark)],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedDetails(dynamic item, Map<String, dynamic> statusInfo, bool isAr, bool isDark) {
    final institution = item['opportunity']?['institution']?['name'] ?? (isAr ? "غير محدد" : "Not set");

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: isDark ? Colors.white10 : Colors.grey.shade100),
          const SizedBox(height: 10),
          _detailRow(isDark, Icons.business_rounded, isAr ? "الجهة:" : "Entity:", institution),
          const SizedBox(height: 8),
          _detailRow(isDark, Icons.calendar_month_outlined, isAr ? "تاريخ الطلب:" : "Date:", item['submission_date'] ?? "---"),
          const SizedBox(height: 15),

          if (item['status'] != 'rejected')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniStep(isAr ? "المدير" : "Admin", statusInfo['step'] >= 1, isDark),
                _miniDivider(statusInfo['step'] >= 2),
                _miniStep(isAr ? "المؤسسة" : "Entity", statusInfo['step'] >= 2, isDark),
                _miniDivider(statusInfo['step'] >= 3),
                _miniStep(isAr ? "القبول" : "Accepted", statusInfo['step'] >= 3, isDark),
              ],
            ),

          if (item['status'] == "rejected")
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: _detailRow(isDark, Icons.info_outline, isAr ? "سبب الرفض:" : "Reason:",
                  item['admin_notes'] ?? item['institution_notes'] ?? (isAr ? "نعتذر، لم يتم قبول الطلب حالياً." : "Sorry, request rejected."), color: Colors.redAccent),
            ),
        ],
      ),
    );
  }

  Widget _miniStep(String label, bool done, bool isDark) => Column(children: [
    Icon(done ? Icons.check_circle : Icons.radio_button_off, size: 16, color: done ? Colors.green : Colors.grey),
    Text(label, style: TextStyle(fontSize: 9, color: isDark ? Colors.white38 : Colors.grey)),
  ]);

  Widget _miniDivider(bool done) => Expanded(child: Container(height: 2, color: done ? Colors.green : Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 4)));

  Widget _detailRow(bool isDark, IconData icon, String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color ?? (isDark ? Colors.white38 : Colors.grey)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(width: 5),
        Expanded(child: Text(value, style: TextStyle(fontSize: 11, color: color ?? (isDark ? Colors.white60 : Colors.black54)))),
      ],
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
