import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';

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
    return DefaultTabController(
      length: 3,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7FF), // خلفية باردة وفخمة
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: TabBar(
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: Colors.grey.shade400,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: "قيد المراجعة"),
                  Tab(text: "المقبولة"),
                  Tab(text: "المرفوضة"),
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
                  _buildListView(pending, "pending"),
                  _buildListView(accepted, "accepted"),
                  _buildListView(rejected, "rejected"),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<dynamic> requests, String type) {
    if (requests.isEmpty) return _buildEmptyState(type);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final item = requests[index];
        final opp = item['opportunity'] ?? {};

        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.all(15),
                leading: _buildStatusIcon(type),
                title: Text(
                  opp['title'] ?? "فرصة تدريبية",
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                ),
                subtitle: Text(
                  "${opp['city'] ?? 'الموقع يحدد لاحقاً'} • ${item['submission_date'] ?? ''}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                children: [
                  _buildExpandedDetails(item, type),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedDetails(dynamic item, String type) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 10),
          _detailRow(Icons.business_rounded, "الجهة:", item['opportunity']?['institution']?['name'] ?? "غير محدد"),
          const SizedBox(height: 8),
          if (type == "rejected")
            _detailRow(Icons.info_outline, "سبب الرفض:", item['institution_notes'] ?? "نعتذر، تم الاكتفاء بالعدد.", color: Colors.redAccent),
          if (type == "accepted")
            _detailRow(Icons.celebration_rounded, "ملاحظة:", "مبروك! سيتم التواصل معك قريباً.", color: Colors.green),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(width: 5),
        Expanded(child: Text(value, style: TextStyle(fontSize: 12, color: color ?? Colors.black87))),
      ],
    );
  }

  Widget _buildStatusIcon(String status) {
    Color color = status == "accepted" ? Colors.green : (status == "rejected" ? Colors.redAccent : Colors.orange);
    IconData icon = status == "accepted" ? Icons.verified_rounded : (status == "rejected" ? Icons.error_rounded : Icons.pending_actions_rounded);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildEmptyState(String type) {
    String msg = type == "pending" ? "لا توجد طلبات تحت المراجعة" : (type == "accepted" ? "لم يتم قبول أي طلب بعد" : "سجل الرفض فارغ");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(msg, style: GoogleFonts.tajawal(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
