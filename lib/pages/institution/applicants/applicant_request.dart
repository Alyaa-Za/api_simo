import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';

class ApplicantsRequests extends StatefulWidget {
  const ApplicantsRequests({super.key});

  @override
  State<ApplicantsRequests> createState() => _ApplicantsRequestsState();
}

class _ApplicantsRequestsState extends State<ApplicantsRequests> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAr ? "الطلبات" : "Requests",
                style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(isAr ? "إدارة المتقدمين" : "Manage Applicants",
                style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 25),

            FutureBuilder<List<dynamic>>(
              future: ApiService().getInstitutionRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()));
                }

                final list = snapshot.data ?? [];
                if (list.isEmpty) return _buildEmptyState(isAr);

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _applicantSummaryCard(list[index], isDark, isAr),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _applicantSummaryCard(dynamic request, bool isDark, bool isAr) {
    final student = request['student'] ?? {};
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 10)],
      ),
      child: ListTile(
        onTap: () => _showRequestDetails(request, isDark, isAr),
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          child: const Icon(Icons.person_outline, color: AppColors.primaryBlue),
        ),
        title: Text(student['full_name'] ?? (isAr ? "اسم الطالب" : "Student Name"),
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text(request['opportunity']?['title'] ?? "",
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey)),
        trailing: Icon(isAr ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }

  void _showRequestDetails(dynamic request, bool isDark, bool isAr) {
    final student = request['student'] ?? {};
    final opportunity = request['opportunity'] ?? {};

    // تأمين جلب المتغيرات بأكثر من مسمى لضمان الظهور مَسْطرة
    String studentEmail = student['email'] ?? student['user']?['email'] ?? "N/A";
    String studentNumber = student['student_number']?.toString() ?? student['university_id']?.toString() ?? "N/A";
    String phone = student['phone'] ?? student['contact_phone'] ?? "N/A";
    String university = student['university'] ?? "N/A";
    String department = student['department'] ?? student['major'] ?? "N/A";
    String level = student['level']?.toString() ?? "N/A";
    String gpa = student['gpa']?.toString() ?? "0.0";
    String status = request['status'] ?? "pending";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30))
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("${isAr ? 'طلب الطالب:' : 'Student:'} ${student['full_name'] ?? ''}", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
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
                      _sectionTitle(isAr ? "البيانات الشخصية والأكاديمية" : "Personal & Academic Info"),
                      const SizedBox(height: 10),

                      // كرت البيانات المرتب والواضح
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : const Color(0xFFF9FBFF),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _infoRow(isAr ? "رقم الطالب:" : "Student ID:", studentNumber, isDark),
                            _infoRow(isAr ? "البريد الإلكتروني:" : "Email:", studentEmail, isDark),
                            _infoRow(isAr ? "الجامعة:" : "University:", university, isDark),
                            _infoRow(isAr ? "المستوى:" : "Level:", level, isDark),
                            _infoRow(isAr ? "رقم الجوال:" : "Phone:", phone, isDark),
                            _infoRow(isAr ? "التخصص:" : "Major:", department, isDark),
                            _infoRow(isAr ? "المعدل:" : "GPA:", gpa, isDark),
                            _infoRow(isAr ? "حالة الطلب:" : "Status:", _getStatusText(status, isAr), isDark, isStatus: true),
                          ],
                        ),
                      ),

                      const Divider(height: 40),
                      _sectionTitle(isAr ? "إجابات الطالب" : "Student Answers"),
                      _contentBox(request['student_answers'] ?? (isAr ? "لا توجد إجابات." : "No answers."), isDark),
                      const SizedBox(height: 20),
                      _sectionTitle(isAr ? "ملاحظات الطالب" : "Student Notes"),
                      _contentBox(request['student_notes'] ?? (isAr ? "لا توجد ملاحظات." : "No notes."), isDark),
                    ],
                  ),
                ),
              ),
              _buildActionFooter(request['request_id'], isAr, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isStatus
                      ? (value == 'مقبول' || value == 'Accepted' ? Colors.green : Colors.orange)
                      : (isDark ? Colors.white : Colors.black87)
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status, bool isAr) {
    if (status == 'accepted') return isAr ? "مقبول" : "Accepted";
    if (status == 'rejected') return isAr ? "مرفوض" : "Rejected";
    return isAr ? "قيد الانتظار" : "Pending";
  }

  void _showRejectDialog(int requestId, bool isAr, bool isDark) {
    final TextEditingController reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text(isAr ? "سبب الرفض" : "Rejection Reason", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          content: TextField(
            controller: reasonCtrl, maxLines: 3,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: isAr ? "يجب كتابة سبب الرفض هنا..." : "You must write the reason here...",
              filled: true, fillColor: isDark ? Colors.black26 : const Color(0xFFF8F9FD),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? "إلغاء" : "Cancel")),
            ElevatedButton(
              onPressed: () {
                if (reasonCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? "يرجى كتابة السبب أولاً" : "Please write a reason first")));
                  return;
                }
                Navigator.pop(ctx);
                _handleDecision(requestId, 'reject', isAr, reason: reasonCtrl.text.trim());
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: const StadiumBorder()),
              child: Text(isAr ? "تأكيد الرفض" : "Confirm", style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDecision(int id, String type, bool isAr, {String? reason}) async {
    try {
      if (type == 'accept') {
        await ApiService().acceptInstitutionRequest(id);
      } else {
        await ApiService().rejectInstitutionRequest(id, reason ?? "");
      }
      if (!mounted) return;
      Navigator.pop(context); // إغلاق الـ BottomSheet
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? "تم تحديث حالة الطلب" : "Request status updated")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildActionFooter(int requestId, bool isAr, bool isDark) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: isDark ? Colors.black12 : Colors.grey.shade50, border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200))),
    child: Row(
      children: [
        Expanded(child: _decisionBtn(isAr ? "قبول" : "Accept", Colors.green, () => _handleDecision(requestId, 'accept', isAr))),
        const SizedBox(width: 10),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(isAr ? "إغلاق" : "Close", style: const TextStyle(color: Colors.grey))),
        const SizedBox(width: 10),
        Expanded(child: _decisionBtn(isAr ? "رفض" : "Reject", Colors.redAccent, () => _showRejectDialog(requestId, isAr, isDark))),
      ],
    ),
  );

  Widget _decisionBtn(String text, Color color, VoidCallback onTap) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 15)),
    child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  );

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryBlue)));
  Widget _contentBox(String text, bool isDark) => Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: isDark ? Colors.black26 : const Color(0xFFF9FBFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200)), child: Text(text, style: TextStyle(height: 1.6, fontSize: 13, color: isDark ? Colors.white60 : Colors.black87)));
  Widget _buildEmptyState(bool isAr) => Center(child: Padding(padding: const EdgeInsets.only(top: 100), child: Text(isAr ? "لا توجد طلبات معلقة" : "No pending requests", style: const TextStyle(color: Colors.grey))));
}
