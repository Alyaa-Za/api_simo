import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';

class InternDetailsTabs extends StatefulWidget {
  final dynamic intern;
  const InternDetailsTabs({super.key, required this.intern});

  @override
  State<InternDetailsTabs> createState() => _InternDetailsTabsState();
}

class _InternDetailsTabsState extends State<InternDetailsTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scoreController = TextEditingController();
  final _notesController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // ── [دالة إرسال التقييم والترحيل اللحظي مَسْطرة] ──
  Future<void> _submitEvaluation() async {
    if (_scoreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى إدخال الدرجة أولاً")));
      return;
    }

    setState(() => _loading = true);
    try {
      // استدعاء الـ API حقك
      await ApiService().evaluateInternship(
        widget.intern['internship_id'] ?? widget.intern['id'],
        int.parse(_scoreController.text),
        _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم رصد التقييم وترحيل الطالب بنجاح ✅"), backgroundColor: Colors.green),
        );

        // ── [السر هنا] ──
        // نغلق الصفحة ونرجع 'true' للصفحة السابقة عشان تحدث القائمة فوراً
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ أثناء التقييم: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final student = widget.intern['student'] ?? {};

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: Text(student['full_name'] ?? "تفاصيل المتدرب", style: const TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: "التفاصيل"),
            Tab(icon: Icon(Icons.description_outlined), text: "التقارير"),
            Tab(icon: Icon(Icons.star_outline), text: "التقييم"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(student, isDark),    // التبويب 1
          _buildReportsTab(isDark),         // التبويب 2
          _buildEvaluationTab(isDark),      // التبويب 3
        ],
      ),
    );
  }

  // 1. تبويب المعلومات
  Widget _buildInfoTab(Map student, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _infoTile("الجامعة", student['university'] ?? "---", Icons.school, isDark),
          _infoTile("التخصص", student['department'] ?? "---", Icons.account_tree, isDark),
          _infoTile("المستوى", student['level'] ?? "---", Icons.bar_chart, isDark),
          _infoTile("المعدل", "${student['gpa'] ?? '0.00'}", Icons.grade, isDark),
          _infoTile("رقم الهاتف", student['phone'] ?? "---", Icons.phone, isDark),
        ],
      ),
    );
  }

  // 2. تبويب التقارير (عرض فقط)
  Widget _buildReportsTab(bool isDark) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService().getInternshipReports(widget.intern['internship_id'] ?? widget.intern['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final reports = snapshot.data ?? [];
        if (reports.isEmpty) return const Center(child: Text("لا توجد تقارير مرفوعة"));

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: reports.length,
          itemBuilder: (context, index) => Card(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: ListTile(
              leading: const Icon(Icons.insert_drive_file, color: AppColors.primaryBlue),
              title: Text(reports[index]['title'] ?? "تقرير أسبوعي"),
              subtitle: Text(reports[index]['submission_date'] ?? ""),
            ),
          ),
        );
      },
    );
  }

  // 3. تبويب التقييم مَسْطرة ملان العين
  Widget _buildEvaluationTab(bool isDark) {
    if (widget.intern['status'] == 'completed') {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: Colors.green, size: 60), SizedBox(height: 10), Text("هذا الطالب تم تقييمه مسبقاً")]));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("رصد الدرجة النهائية", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          TextField(
            controller: _scoreController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "الدرجة (0-100) *",
              filled: true, fillColor: isDark ? Colors.white10 : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: "ملاحظات وتوصيات المؤسسة",
              filled: true, fillColor: isDark ? Colors.white10 : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              onPressed: _loading ? null : _submitEvaluation,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("إرسال التقييم وإنهاء التدريب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String l, String v, IconData i, bool d) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: d ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [Icon(i, color: AppColors.primaryBlue, size: 20), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(color: Colors.grey, fontSize: 11)), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))])]),
  );
}
