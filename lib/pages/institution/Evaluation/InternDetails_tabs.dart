import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';

class InternDetailsTabs extends StatelessWidget {
  final Map<String, dynamic> intern;
  const InternDetailsTabs({super.key, required this.intern});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final int internshipId = int.tryParse(intern['internship_id']?.toString() ??
        intern['id']?.toString() ?? '0') ?? 0;

    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
            leading: IconButton(
              icon: Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              intern['full_name'] ?? (isAr ? "تفاصيل المتدرب" : "Intern Details"),
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            bottom: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: isAr ? "التقارير الأسبوعية" : "Weekly Reports"),
                Tab(text: isAr ? "التقييم النهائي" : "Final Evaluation"),
              ],
            ),
          ),
          body: internshipId == 0
              ? Center(child: Text(isAr ? "خطأ: معرف المتدرب غير صالح" : "Error: Invalid Intern ID"))
              : TabBarView(
            children: [
              _ReportsTab(internId: internshipId, isAr: isAr, isDark: isDark),
              _EvaluationTab(internId: internshipId, isAr: isAr, isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  final int internId;
  final bool isAr;
  final bool isDark;
  const _ReportsTab({required this.internId, required this.isAr, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService().getInternshipReports(internId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return Center(child: Text(isAr ? "لم يتم رفع أي تقارير بعد." : "No reports uploaded yet.",
              style: GoogleFonts.tajawal(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 10)],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: Text("${report['week_number'] ?? index + 1}",
                      style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ),
                title: Text(report['title'] ?? (isAr ? "تقرير أسبوعي" : "Weekly Report"),
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
                subtitle: Text("${isAr ? 'تاريخ الرفع:' : 'Date:'} ${report['created_at']?.toString().substring(0, 10) ?? ''}",
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 11)),
                trailing: const Icon(Icons.remove_red_eye_outlined, size: 18, color: AppColors.primaryBlue),
                onTap: () => _showReportContent(context, report),
              ),
            );
          },
        );
      },
    );
  }

  void _showReportContent(BuildContext context, dynamic report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isAr ? "محتوى التقرير الأسبوعي" : "Weekly Report Content",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : AppColors.textDark)),
            Divider(height: 40, color: isDark ? Colors.white10 : Colors.grey.shade200),
            Text(report['content'] ?? (isAr ? "لا يوجد محتوى نصي." : "No content provided."),
                style: TextStyle(height: 1.8, fontSize: 14, color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _EvaluationTab extends StatefulWidget {
  final int internId;
  final bool isAr;
  final bool isDark;
  const _EvaluationTab({required this.internId, required this.isAr, required this.isDark});

  @override
  State<_EvaluationTab> createState() => _EvaluationTabState();
}

class _EvaluationTabState extends State<_EvaluationTab> {
  final _scoreCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(widget.isAr ? "التقييم الرقمي (من 100)" : "Score (out of 100)"),
          const SizedBox(height: 12),
          TextField(
            controller: _scoreCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: widget.isAr ? "أدخل الدرجة النهائية" : "Enter final score",
              prefixIcon: const Icon(Icons.star_border_rounded, color: Colors.orange),
              filled: true,
              fillColor: widget.isDark ? Colors.black26 : const Color(0xFFF8F9FD),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 30),

          _buildLabel(widget.isAr ? "الملاحظات الختامية والتوصية" : "Final Notes & Recommendation"),
          const SizedBox(height: 8),
          Text(
            widget.isAr ? "سيراها الطالب في حسابه بشكل رسمي." : "Student will see these notes in their account.",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _notesCtrl,
            maxLines: 6,
            style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: widget.isAr ? "اكتب تقييمك هنا..." : "Write your feedback here...",
              filled: true,
              fillColor: widget.isDark ? Colors.black26 : const Color(0xFFF8F9FD),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submitFinalEvaluation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.isAr ? "اعتماد وإرسال التقييم" : "Submit Evaluation",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white70 : AppColors.primaryBlue, fontSize: 15));

  Future<void> _submitFinalEvaluation() async {
    if (_scoreCtrl.text.isEmpty) {
      _showSnack(widget.isAr ? "يرجى إدخال الدرجة أولاً" : "Enter score first", Colors.red);
      return;
    }
    final int? score = int.tryParse(_scoreCtrl.text);
    if (score == null || score < 0 || score > 100) {
      _showSnack(widget.isAr ? "الدرجة بين 0 و 100" : "Score must be 0-100", Colors.red);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ApiService().evaluateInternship(widget.internId, score, _notesCtrl.text.trim());
      if (mounted) {
        _showSnack(widget.isAr ? " تم الإرسال بنجاح" : " Submitted successfully", Colors.green);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) _showSnack(widget.isAr ? " فشل الإرسال" : " Failed to submit", Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
      backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}
