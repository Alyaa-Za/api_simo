import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';
import 'admin_review_evaluation_screen.dart';

class AdminManageStudents extends StatefulWidget {
  const AdminManageStudents({super.key});

  @override
  State<AdminManageStudents> createState() => _AdminManageStudentsState();
}

class _AdminManageStudentsState extends State<AdminManageStudents> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _allStudents = [];
  List<dynamic> _filteredStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_onSearchChanged);
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService().getAdminStudents();
      setState(() {
        _allStudents = data;
        _filteredStudents = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {
      _filteredStudents = _allStudents.where((s) {
        final name = (s['full_name'] ?? "").toString().toLowerCase();
        final id = (s['student_number'] ?? "").toString().toLowerCase();
        final query = _searchCtrl.text.toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();
    });
  }

  void _refresh() {
    setState(() => _isLoading = true);
    _loadData();
  }

  Future<void> _pickExcelFile(bool isAr) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null) {
        String? ext = result.files.single.extension?.toLowerCase();
        if (ext == 'xlsx' || ext == 'xls') {
          _showStatus(isAr ? "تم اختيار الملف بنجاح" : "File selected successfully", Colors.green);
        } else {
          _showStatus(isAr ? "خطأ: اختر ملف اكسل فقط" : "Error: Select Excel only", Colors.redAccent);
        }
      }
    } catch (e) {
      _showStatus(isAr ? "فشل فتح الملفات" : "Picker Error", Colors.redAccent);
    }
  }

  void _showStatus(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 95),
          child: FloatingActionButton.extended(
            onPressed: () => _pickExcelFile(isAr),
            elevation: 5,
            backgroundColor: AppColors.primaryBlue,
            icon: const Icon(Icons.file_upload_outlined, color: Colors.white),
            label: Text(isAr ? "استيراد الطلاب" : "Import Students", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                title: Text(isAr ? "إدارة الطلاب المتدربين" : "Intern Students Management",
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryBlue)),
              ),
              actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue))],
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: isAr ? "ابحث بالاسم أو الرقم..." : "Search by name or ID...",
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    border: InputBorder.none,
                    icon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_filteredStudents.isEmpty)
              SliverFillRemaining(child: Center(child: Text(isAr ? "لا توجد نتائج" : "No results found")))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 150),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildModernStudentCard(_filteredStudents[index], isAr, isDark),
                    childCount: _filteredStudents.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStudentCard(dynamic student, bool isAr, bool isDark) {
    final String name = student['full_name'] ?? "---";
    final String email = student['email'] ?? "---";
    final bool isActive = student['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 50, width: 50,
                decoration: const BoxDecoration(gradient: AppColors.splashGradient, shape: BoxShape.circle),
                child: Center(child: Text(name.substring(0,1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
              ),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                Text(email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ])),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: isActive,
                  activeColor: Colors.green,
                  onChanged: (val) async {
                    await ApiService().changeStudentStatus(student['student_id'] ?? student['id'], val ? 'active' : 'suspended');
                    _refresh();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AdminReviewEvaluationScreen(student: student))),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.insert_chart_outlined_rounded, size: 18, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(isAr ? "التقارير" : "Reports", style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => _showFullDetails(student, isAr, isDark),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.person_search_rounded, size: 18, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Text(isAr ? "التفاصيل" : "Details", style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showFullDetails(dynamic student, bool isAr, bool isDark) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      pageBuilder: (ctx, anim1, anim2) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          appBar: AppBar(backgroundColor: AppColors.primaryBlue, title: Text(student['full_name'] ?? ""), elevation: 0),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _detailCard(isAr ? "السجل الأكاديمي" : "Academic Info", Icons.school_outlined, isDark, [
                  _row(isAr ? "الرقم الجامعي:" : "ID:", student['student_number'], isDark),
                  _row(isAr ? "الجامعة:" : "University:", student['university'], isDark),
                  _row(isAr ? "التخصص الدراسي:" : "Major:", student['department'], isDark),
                  _row(isAr ? "المستوى الدراسي:" : "Level:", student['level'], isDark),
                  _row(isAr ? "المعدل التراكمي:" : "GPA:", student['gpa'], isDark),
                ]),
                const SizedBox(height: 15),
                _detailCard(isAr ? "معلومات التواصل" : "Contact", Icons.alternate_email_rounded, isDark, [
                  _row(isAr ? "البريد الإلكتروني:" : "Email:", student['email'], isDark),
                  _row(isAr ? "رقم الهاتف:" : "Phone:", student['phone'], isDark),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailCard(String t, IconData i, bool d, List<Widget> c) => Container(
    width: double.infinity, padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: d ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(25)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(i, color: AppColors.primaryBlue, size: 22), const SizedBox(width: 10), Text(t, style: const TextStyle(fontWeight: FontWeight.bold))]), const Divider(height: 35), ...c]),
  );

  Widget _row(String l, dynamic v, bool d) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Row(children: [Text(l, style: const TextStyle(color: Colors.grey, fontSize: 13)), const SizedBox(width: 10), Expanded(child: Text(v?.toString() ?? "---", textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold, color: d ? Colors.white : Colors.black87)))]));
}
