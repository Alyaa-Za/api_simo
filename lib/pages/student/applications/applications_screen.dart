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
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: "قيد الانتظار"),
                Tab(text: "مقبول"),
                Tab(text: "مرفوض"),
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

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final allData = snapshot.data!;

            final pendingRequests = allData.where((r) =>
                ['pending', 'pending_admin', 'pending_institution', 'under_review'].contains(r['status'])).toList();

            final acceptedRequests = allData.where((r) => r['status'] == 'approved').toList();

            final rejectedRequests = allData.where((r) => r['status'] == 'rejected').toList();

            return TabBarView(
              children: [
                _buildListView(pendingRequests, "pending"),
                _buildListView(acceptedRequests, "accepted"),
                _buildListView(rejectedRequests, "rejected"),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildListView(List<dynamic> requests, String statusType) {
    if (requests.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final item = requests[index];
        final opportunity = item['opportunity'] ?? {};

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: _buildStatusIcon(statusType),
            title: Text(
              opportunity['title'] ?? "فرصة تدريبية",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  "${opportunity['city'] ?? 'اليمن'} • ${item['submission_date'] ?? ''}",
                  style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: statusType == "rejected"
                ? IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.redAccent),
              onPressed: () => _showRejectionDetails(item['institution_notes'] ?? "نعتذر، تم الاكتفاء بالعدد."),
            )
                : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(String status) {
    Color color;
    IconData icon;
    if (status == "accepted") {
      color = Colors.green;
      icon = Icons.check_circle_rounded;
    } else if (status == "rejected") {
      color = Colors.redAccent;
      icon = Icons.cancel_rounded;
    } else {
      color = Colors.orange;
      icon = Icons.hourglass_bottom_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 24),
    );
  }

  void _showRejectionDetails(String note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("سبب الرفض", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        content: Text(note, style: GoogleFonts.tajawal()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إغلاق")),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text("لا توجد طلبات في هذا القسم", style: GoogleFonts.tajawal(color: Colors.grey)),
        ],
      ),
    );
  }
}
