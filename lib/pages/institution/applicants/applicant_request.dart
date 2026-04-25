import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';

class ApplicantsRequests extends StatefulWidget {
  const ApplicantsRequests({super.key});

  @override
  State<ApplicantsRequests> createState() => _ApplicantsRequestsState();
}

class _ApplicantsRequestsState extends State<ApplicantsRequests> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("الطلبات", style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text("إدارة المتقدمين", style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
            const SizedBox(height: 25),

            FutureBuilder<List<dynamic>>(
              future: ApiService().getInstitutionRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()));
                }

                final list = snapshot.data ?? [];
                if (list.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _applicantSummaryCard(list[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _applicantSummaryCard(dynamic request) {
    final student = request['student'] ?? {};
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        onTap: () => _showRequestDetails(request),
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          child: const Icon(Icons.person_outline, color: AppColors.primaryBlue),
        ),
        title: Text(student['full_name'] ?? "اسم الطالب", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        subtitle: Text(request['opportunity']?['title'] ?? "", style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }
  void _showRequestDetails(dynamic request) {
    final student = request['student'] ?? {};
    final opportunity = request['opportunity'] ?? {};

    String studentEmail = student['email'] ?? (student['user'] != null ? student['user']['email'] : "غير متوفر");

    String studentNumber = student['student_number']?.toString() ?? "N/A";

    String university = student['university'] ?? "لم تحدد";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("طلب الطالب: ${student['full_name'] ?? ''}", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoGrid([
                        _infoItem("رقم الطالب:", studentNumber),
                        _infoItem("الاسم الكامل:", student['full_name'] ?? ""),
                        _infoItem("البريد الإلكتروني:", studentEmail),
                        _infoItem("رقم الجوال:", student['phone'] ?? "غير متوفر"),
                        _infoItem("الجامعة:", university),
                        _infoItem("التخصص:", student['department'] ?? ""),
                        _infoItem("المستوى:", student['level'] ?? ""),
                        _infoItem("المعدل:", student['gpa']?.toString() ?? "0.0"),
                        _infoItem("الفرصة:", opportunity['title'] ?? ""),
                        _infoItem("حالة الطلب:", request['status'] ?? ""),
                      ]),
                      _infoItem("تاريخ التقديم:", request['submission_date'] ?? "", isFullWidth: true),

                      const Divider(height: 40),
                      _sectionTitle("إجابات الطالب"),
                      _contentBox(request['student_answers'] ?? "لا توجد إجابات."),
                      const SizedBox(height: 20),
                      _sectionTitle("ملاحظات الطالب"),
                      _contentBox(request['student_notes'] ?? "لا توجد ملاحظات."),
                    ],
                  ),
                ),
              ),

              _buildActionFooter(request['request_id']),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildInfoGrid(List<Widget> items) => Wrap(runSpacing: 20, children: items);

  Widget _infoItem(String label, String value, {bool isFullWidth = false}) {
    return SizedBox(
      width: isFullWidth ? double.infinity : MediaQuery.of(context).size.width * 0.43,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryBlue)));

  Widget _contentBox(String text) => Container(
    width: double.infinity, padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: const Color(0xFFF9FBFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
    child: Text(text, style: const TextStyle(height: 1.6, fontSize: 13, color: Colors.black87)),
  );

  Widget _buildActionFooter(int requestId) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.grey.shade50, border: Border(top: BorderSide(color: Colors.grey.shade200))),
    child: Row(
      children: [
        Expanded(child: _decisionBtn("قبول", Colors.green, () => _handleDecision(requestId, 'accept'))),
        const SizedBox(width: 10),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("إغلاق", style: TextStyle(color: Colors.grey))),
        const SizedBox(width: 10),
        Expanded(child: _decisionBtn("رفض", Colors.redAccent, () => _handleDecision(requestId, 'reject'))),
      ],
    ),
  );

  Widget _decisionBtn(String text, Color color, VoidCallback onTap) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 15)),
    child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  );

  Future<void> _handleDecision(int id, String type) async {
    try {
      if (type == 'accept') {
        await ApiService().acceptInstitutionRequest(id);
      } else {
        await ApiService().rejectInstitutionRequest(id, "تم الرفض بناءً على المراجعة");
      }
      if (!mounted) return;
      Navigator.pop(context);
      _refresh();
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e"))); }
  }

  Widget _buildEmptyState() => const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: Text("لا توجد طلبات معلقة")));
}
