import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';

class InternDetailsTabs extends StatelessWidget {
  final Map<String, dynamic> intern;
  const InternDetailsTabs({super.key, required this.intern});

  @override
  Widget build(BuildContext context) {
    final int internshipId = int.tryParse(intern['internship_id']?.toString() ?? '0') ?? 0;

    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            elevation: 0,
            flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
            title: Text(
              intern['full_name'] ?? "تفاصيل المتدرب",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            bottom: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "التقارير الأسبوعية"),
                Tab(text: "التقييم النهائي"),
              ],
            ),
          ),
          body: internshipId == 0
              ? const Center(child: Text("خطأ: معرف المتدرب غير صالح"))
              : TabBarView(
            children: [
              _ReportsTab(internId: internshipId),
              _EvaluationTab(internId: internshipId),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  final int internId;
  const _ReportsTab({required this.internId});

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
          return Center(child: Text("لم يتم رفع أي تقارير بعد.", style: GoogleFonts.tajawal(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: Text("${report['week_number'] ?? index + 1}",
                      style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ),
                title: Text(report['title'] ?? "تقرير أسبوعي", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
                subtitle: Text("تاريخ الرفع: ${report['created_at']?.toString().substring(0, 10) ?? ''}"),
                trailing: const Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.grey),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("محتوى التقرير", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(height: 30),
            Text(report['content'] ?? "لا يوجد محتوى نصي.",
                style: const TextStyle(height: 1.8, fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _EvaluationTab extends StatefulWidget {
  final int internId;
  const _EvaluationTab({required this.internId});

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
          _buildHeader("التقييم الرقمي (من 100)"),
          const SizedBox(height: 12),
          TextField(
            controller: _scoreCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "أدخل الدرجة النهائية المستحقة",
              prefixIcon: const Icon(Icons.star_border_rounded, color: Colors.orange),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 30),

          _buildHeader("الملاحظات الختامية"),
          const Text(
            "يرجى كتابة تقييم شامل لأداء المتدرب، مهاراته التقنية، ومدى التزامه بالحضور خلال فترة التدريب:",
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _notesCtrl,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: "مثال: المتدرب متميز في المهارات البرمجية، ملتزم جداً بمواعيد الحضور والانصراف، وأظهر قدرة عالية على التعلم بسرعة...",
              filled: true, fillColor: Colors.white,
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
                  : const Text("اعتماد وإرسال التقييم النهائي",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 15));
  }

  Future<void> _submitFinalEvaluation() async {
    if (_scoreCtrl.text.isEmpty) {
      _showSnack("يرجى إدخال الدرجة أولاً", Colors.red);
      return;
    }

    final int? score = int.tryParse(_scoreCtrl.text);
    if (score == null || score < 0 || score > 100) {
      _showSnack("الدرجة يجب أن تكون قيمة صحيحة بين 0 و 100", Colors.red);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ApiService().evaluateInternship(widget.internId, score, _notesCtrl.text);
      if (mounted) {
        _showSnack("تم إرسال التقييم للجامعة بنجاح ", Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnack("فشل الإرسال: تأكد من الاتصال بقاعدة البيانات", Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
