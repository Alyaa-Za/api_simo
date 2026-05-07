import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';
import '../../../core/token_manager.dart';

class AdminReviewEvaluationScreen extends StatefulWidget {
  final int internshipId;

  const AdminReviewEvaluationScreen({super.key, required this.internshipId});

  @override
  State<AdminReviewEvaluationScreen> createState() => _AdminReviewEvaluationScreenState();
}

class _AdminReviewEvaluationScreenState extends State<AdminReviewEvaluationScreen> {
  double _technicalSkills = 5.0;
  double _commitment = 5.0;
  double _discipline = 5.0;
  double _teamSpirit = 5.0;
  double _generalEvaluation = 5.0;

  final _notesCtrl = TextEditingController();
  bool _isSaving = false;
  bool _isLoading = true;

  Map<String, dynamic> _studentData = {};
  Map<String, dynamic> _opportunityData = {};

  double get _totalScore => _technicalSkills + _commitment + _discipline + _teamSpirit + _generalEvaluation;

  @override
  void initState() {
    super.initState();
    _fetchEvaluationData();
  }

  // ── [الاستدعاء الحقيقي لبيانات التقييم من السيرفر] ──
  Future<void> _fetchEvaluationData() async {
    try {
      final response = await ApiService().getAdminInternshipDetails(widget.internshipId);
      final data = response['data'] ?? response;

      setState(() {
        _studentData = data['student'] ?? {};
        _opportunityData = data['opportunity'] ?? {};

        final scores = data['evaluation_scores'] ?? {};
        _technicalSkills = double.tryParse(scores['technical']?.toString() ?? "5.0") ?? 5.0;
        _commitment = double.tryParse(scores['commitment']?.toString() ?? "5.0") ?? 5.0;
        _discipline = double.tryParse(scores['discipline']?.toString() ?? "5.0") ?? 5.0;
        _teamSpirit = double.tryParse(scores['team_spirit']?.toString() ?? "5.0") ?? 5.0;
        _generalEvaluation = double.tryParse(scores['general']?.toString() ?? "5.0") ?? 5.0;

        _notesCtrl.text = data['institution_notes'] ?? data['admin_notes'] ?? "";
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
    }
  }

  // ── [الاستدعاء الحقيقي لحفظ واعتماد التقييم في السيرفر] ──
  Future<void> _handleApprove(bool isAr) async {
    setState(() => _isSaving = true);
    try {
      final token = await TokenManager.getToken();

      final response = await http.patch(
        Uri.parse('${ApiService.baseUrl}/api/admin/complaints'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "technical": _technicalSkills,
          "commitment": _commitment,
          "discipline": _discipline,
          "team_spirit": _teamSpirit,
          "general": _generalEvaluation,
          "admin_notes": _notesCtrl.text.trim(),
          "final_score": _totalScore,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isAr ? "تم اعتماد التقييم بنجاح " : "Evaluation approved"), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving: $e"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentCard(isAr, isDark),
                  const SizedBox(height: 25),
                  _buildSectionHeader(isAr, isDark),
                  const SizedBox(height: 15),
                  _buildSliderCard(isAr ? "المهارات الفنية" : "Technical Skills", isAr ? "مدى إتقان المهام التقنية المسندة" : "Proficiency in assigned technical tasks", _technicalSkills, (v) => setState(() => _technicalSkills = v), isDark),
                  _buildSliderCard(isAr ? "الالتزام والمسؤولية" : "Commitment & Responsibility", isAr ? "التقيد بأنظمة العمل والتعليمات" : "Adherence to work regulations and instructions", _commitment, (v) => setState(() => _commitment = v), isDark),
                  _buildSliderCard(isAr ? "الانضباط والوقت" : "Discipline & Time", isAr ? "المواظبة على الحضور والانصراف" : "Regular attendance and punctuality", _discipline, (v) => setState(() => _discipline = v), isDark),
                  _buildSliderCard(isAr ? "الروح الجماعية" : "Team Spirit", isAr ? "التعاون والانسجام مع فريق العمل" : "Cooperation and harmony with the team", _teamSpirit, (v) => setState(() => _teamSpirit = v), isDark),
                  _buildSliderCard(isAr ? "التقييم العام" : "General Evaluation", isAr ? "الانطباع الشامل عن أداء المتدرب" : "Overall impression of intern's performance", _generalEvaluation, (v) => setState(() => _generalEvaluation = v), isDark),
                  const SizedBox(height: 25),
                  _buildNotesBox(isAr, isDark),
                ],
              ),
            ),
            _buildBottomActionBar(isAr),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(bool isAr, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 15)]),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Row(
              children: [
                const CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 30)),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_studentData['full_name'] ?? "Rania Tarek", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(5)), child: Text(isAr ? "متدرب نشط" : "Active Intern", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _studentInfoRow(Icons.work_outline_rounded, isAr ? "الرقم الأكاديمي" : "Student ID", _studentData['student_number']?.toString() ?? "---"),
                _studentInfoRow(Icons.business_rounded, isAr ? "التخصص" : "Department", _studentData['department'] ?? "---"),
                _studentInfoRow(Icons.assignment_turned_in_outlined, isAr ? "الفرصة" : "Opportunity", _opportunityData['title'] ?? "---"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _studentInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [Icon(icon, color: Colors.grey, size: 18), const SizedBox(width: 10), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)), const Spacer(), Text(value, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryBlue))]),
    );
  }

  Widget _buildSectionHeader(bool isAr, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [const Icon(Icons.analytics_outlined, color: AppColors.primaryBlue, size: 22), const SizedBox(width: 8), Text(isAr ? "معايير الأداء والتقييم الفني" : "Evaluation Criteria", style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark))]),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text("${_totalScore.toInt()}/50", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue))),
      ],
    );
  }

  Widget _buildSliderCard(String title, String subtitle, double value, ValueChanged<double> onChanged, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(15), border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)), Text("${value.toInt()}/10", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue))],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(activeTrackColor: AppColors.primaryBlue, inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade200, thumbColor: AppColors.primaryBlue, overlayColor: AppColors.primaryBlue.withOpacity(0.2), trackHeight: 4),
            child: Slider(value: value, min: 0, max: 10, divisions: 10, onChanged: onChanged),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesBox(bool isAr, bool isDark) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(15), border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.comment_outlined, color: AppColors.primaryBlue, size: 18), const SizedBox(width: 8), Text(isAr ? "توصيات اللجنة والملاحظات" : "Recommendations", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.textDark))]),
          const SizedBox(height: 15),
          TextField(controller: _notesCtrl, maxLines: 4, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13), decoration: InputDecoration(hintText: isAr ? "اكتب تعليقاً..." : "Write a comment...", hintStyle: const TextStyle(color: Colors.grey, fontSize: 12), filled: true, fillColor: isDark ? Colors.black26 : const Color(0xFFF8F9FD), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(bool isAr) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        decoration: const BoxDecoration(color: Color(0xFF111827), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: _isSaving ? null : () => _handleApprove(isAr),
            icon: _isSaving ? const SizedBox.shrink() : const Icon(Icons.check_circle_outline, color: Colors.white),
            label: _isSaving ? const CircularProgressIndicator(color: Colors.white) : Text(isAr ? "اعتماد النتيجة" : "Approve Result", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
