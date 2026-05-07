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
    final isAr = Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          elevation: 0,
          title: Text(isAr ? "طلبات المتدربين" : "Applicants Requests",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
          actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.sync, color: AppColors.primaryBlue))],
        ),
        body: FutureBuilder<List<dynamic>>(
          future: ApiService().getInstitutionRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text(isAr ? "فشل جلب البيانات" : "Load Failed"));
            final list = snapshot.data ?? [];
            if (list.isEmpty) return _buildEmpty(isAr, isDark);

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              itemBuilder: (context, index) => _buildRequestCard(list[index], isAr, isDark),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard(dynamic request, bool isAr, bool isDark) {
    final student = request['student'] ?? {};
    final String name = student['full_name'] ?? "---";
    final int requestId = request['id'] ?? request['request_id'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        onTap: () => _openDetailsScreen(requestId, isAr, isDark),
        leading: CircleAvatar(
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: Text(name.isNotEmpty ? name.substring(0,1).toUpperCase() : "S", style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold))
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(request['opportunity']?['title'] ?? "", style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  void _openDetailsScreen(int requestId, bool isAr, bool isDark) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (ctx, anim1, anim2) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          appBar: AppBar(
            backgroundColor: AppColors.primaryBlue,
            elevation: 0,
            leading: IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.white)),
            title: Text(isAr ? "ملف المتقدم الكامل" : "Full Applicant Profile", style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          body: FutureBuilder<Map<String, dynamic>>(
            future: ApiService().getInstitutionRequestDetails(requestId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(child: Text(isAr ? "فشل تحميل تفاصيل الطالب" : "Failed to load details"));
              }

              final Map<String, dynamic> fullData = snapshot.data!['data'] ?? snapshot.data!;
              final Map<String, dynamic> student = Map<String, dynamic>.from(fullData['student'] ?? {});
              final Map<String, dynamic> user = Map<String, dynamic>.from(student['user'] ?? fullData['user'] ?? {});
              final Map<String, dynamic> opp = Map<String, dynamic>.from(fullData['opportunity'] ?? {});

              final String name = student['full_name'] ?? user['full_name'] ?? fullData['full_name'] ?? "---";
              final String email = student['email'] ?? user['email'] ?? (isAr ? "غير متوفر" : "N/A");
              final String phone = student['phone'] ?? user['phone'] ?? (isAr ? "غير متوفر" : "N/A");
              final String university = student['university']?.toString() ?? (isAr ? "غير محددة" : "Not Set");
              final String level = student['level']?.toString() ?? (isAr ? "غير محدد" : "Not Set");
              final String department = student['department']?.toString() ?? "---";

              final dynamic rawAnswers = fullData['student_answers'] ?? fullData['answers'] ?? student['answers'];
              String displayAnswers = (isAr ? "لا توجد إجابات مسجلة" : "No answers provided");

              if (rawAnswers != null) {
                if (rawAnswers is String && rawAnswers.isNotEmpty) displayAnswers = rawAnswers;
                if (rawAnswers is List) displayAnswers = rawAnswers.join("\n");
                if (rawAnswers is Map) displayAnswers = rawAnswers.values.join("\n");
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _massiveCard(isAr ? "بيانات التواصل" : "Contact Info", Icons.person_outline, isDark, [
                      _infoRow(isAr ? "الاسم الكامل:" : "Name:", name, isDark),
                      _infoRow(isAr ? "البريد الإلكتروني:" : "Email:", email, isDark),
                      _infoRow(isAr ? "رقم الهاتف:" : "Phone:", phone, isDark),
                    ]),
                    const SizedBox(height: 15),
                    _massiveCard(isAr ? "المسار الأكاديمي والتعليم" : "Academic Path", Icons.school_outlined, isDark, [
                      _infoRow(isAr ? "الجامعة:" : "University:", university, isDark),
                      _infoRow(isAr ? "التخصص:" : "Department:", department, isDark),
                      _infoRow(isAr ? "المعدل التراكمي:" : "GPA:", "${student['gpa'] ?? '0.00'}", isDark),
                      _infoRow(isAr ? "المستوى الدراسي:" : "Level:", level, isDark),
                      _infoRow(isAr ? "الفرصة المتقدم لها:" : "Applied For:", opp['title'] ?? "---", isDark),
                    ]),
                    const SizedBox(height: 15),
                    _massiveCard(isAr ? "إجابات الطالب على الأسئلة" : "Q&A Response", Icons.quiz_outlined, isDark, [
                      _longText(isAr ? "نص الإجابات:" : "Response Content:", displayAnswers, isDark, Colors.blue),
                    ]),
                    const SizedBox(height: 15),
                    _massiveCard(isAr ? "ملاحظات إضافية" : "Additional Notes", Icons.edit_note, isDark, [
                      _longText(isAr ? "ملاحظات الطالب:" : "Student Notes:", fullData['student_notes'] ?? "---", isDark, Colors.grey),
                    ]),
                    const SizedBox(height: 120),
                  ],
                ),
              );
            },
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Row(
              children: [
                Expanded(child: ElevatedButton(
                  onPressed: () => _handleDecision(requestId, 'accept', isAr),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: Text(isAr ? "قبول الطالب" : "Accept", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )),
                const SizedBox(width: 15),
                Expanded(child: ElevatedButton(
                  onPressed: () => _showRejectWithReason(requestId, isAr, isDark),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: Text(isAr ? "رفض الطلب" : "Reject", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _massiveCard(String title, IconData icon, bool d, List<Widget> children) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: d ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: AppColors.primaryBlue, size: 22), const SizedBox(width: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
        const Divider(height: 30),
        ...children,
      ]),
    );
  }

  Widget _infoRow(String l, String v, bool d) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(children: [Text(l, style: const TextStyle(color: Colors.grey, fontSize: 13)), const SizedBox(width: 10), Expanded(child: Text(v, style: TextStyle(fontWeight: FontWeight.bold, color: d ? Colors.white : Colors.black87), textAlign: TextAlign.end))]),
  );

  Widget _longText(String l, String v, bool d, Color c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: d ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withOpacity(0.1))), child: Text(v, style: const TextStyle(fontSize: 13, height: 1.5))),
  ]);

  void _showRejectWithReason(int id, bool ar, bool d) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: d ? const Color(0xFF1E293B) : Colors.white,
      title: Row(children: [Text(ar ? "سبب الرفض" : "Reject"), const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))]),
      content: TextField(controller: ctrl, maxLines: 3, decoration: InputDecoration(hintText: ar ? "اكتب هنا..." : "Reason...", filled: true, fillColor: Colors.grey.withOpacity(0.1), border: InputBorder.none)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ar ? "إلغاء" : "Cancel")),
        ElevatedButton(onPressed: () async {
          if (ctrl.text.trim().isEmpty) return;
          await ApiService().rejectInstitutionRequest(id, ctrl.text.trim());
          Navigator.pop(ctx); Navigator.pop(context); _refresh();
        }, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: Text(ar ? "تأكيد الرفض" : "Confirm")),
      ],
    ));
  }

  Future<void> _handleDecision(int id, String type, bool ar) async {
    await ApiService().acceptInstitutionRequest(id);
    Navigator.pop(context); _refresh();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ar ? "تم القبول " : "Accepted "), backgroundColor: Colors.green));
  }

  Widget _buildEmpty(bool ar, bool d) => Center(child: Text(ar ? "لا توجد طلبات" : "No Requests"));
}
