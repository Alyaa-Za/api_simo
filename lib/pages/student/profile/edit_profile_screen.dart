import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _uniController = TextEditingController();
  final _deptController = TextEditingController();
  final _gpaController = TextEditingController();
  String? _selectedCity, _selectedLevel;

  final List<String> _cities = ["صنعاء", "عدن", "تعز", "حضرموت", "إب", "الحديدة"];
  final List<String> _levels = ["Level 1", "Level 2", "Level 3", "Level 4", "Graduate"];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  // ── [الإصلاح]: جلب البيانات من المسار الصحيح (data -> student) ──
  Future<void> _loadCurrentData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().getProfile();
      // الباك أند يرسل البيانات داخل ['data']['student']
      final data = response['data']?['student'] ?? response['data'] ?? {};

      setState(() {
        _uniController.text = data['university']?.toString() ?? "";
        _deptController.text = data['department']?.toString() ?? "";
        _gpaController.text = data['gpa']?.toString() ?? "";

        // فحص وجود القيم في القوائم المنسدلة لمنع الـ Error
        if (_cities.contains(data['city'])) _selectedCity = data['city'];
        if (_levels.contains(data['level'])) _selectedLevel = data['level'];

        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Load Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    Map<String, dynamic> body = {
      "university": _uniController.text.trim(),
      "department": _deptController.text.trim(),
      "level": _selectedLevel,
      "gpa": _gpaController.text.trim(),
      "city": _selectedCity,
    };

    try {
      await ApiService().updateProfile(body);
      if (!mounted) return;

      // إظهار رسالة نجاح فخمة قبل العودة
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث بياناتك بنجاح ✅"), backgroundColor: Colors.green)
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل الحفظ: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF), // خلفية فخمة
        appBar: AppBar(
          title: Text("تحديث الملف الأكاديمي", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("المؤسسة التعليمية", Icons.account_balance_rounded),
                _buildPremiumCard([
                  _buildField("اسم الجامعة / الكلية", Icons.school_rounded, _uniController),
                  _buildField("القسم أو التخصص", Icons.account_tree_rounded, _deptController),
                ]),

                const SizedBox(height: 30),

                _buildSectionTitle("المستوى والمعدل", Icons.auto_graph_rounded),
                _buildPremiumCard([
                  _buildDropdown("المستوى الدراسي الحالي", Icons.layers_rounded, _levels, _selectedLevel, (v) => setState(() => _selectedLevel = v)),
                  _buildDropdown("مدينة الإقامة", Icons.location_city_rounded, _cities, _selectedCity, (v) => setState(() => _selectedCity = v)),
                  _buildField("المعدل التراكمي (GPA)", Icons.grade_rounded, _gpaController, isNumber: true),
                ]),

                const SizedBox(height: 45),
                _buildPremiumSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController ctrl, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
          filled: true, fillColor: const Color(0xFFF8F9FD),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1)),
        ),
        validator: (v) => v!.isEmpty ? "هذا الحقل ضروري" : null,
      ),
    );
  }

  Widget _buildDropdown(String label, IconData icon, List<String> items, String? val, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: val,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
          filled: true, fillColor: const Color(0xFFF8F9FD),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildPremiumCard(List<Widget> children) => Container(
    padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
    ),
    child: Column(children: children),
  );

  Widget _buildPremiumSaveButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text("حفظ التغييرات الأكاديمية", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
