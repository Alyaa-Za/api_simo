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

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _gpaController = TextEditingController();
  final _uniController = TextEditingController();

  String? _selectedCity, _selectedLevel, _selectedCollege, _selectedDept;

  final List<String> _cities = ["صنعاء", "عدن", "تعز", "حضرموت", "إب", "الحديدة"];
  final List<String> _levels = ["Level 1", "Level 2", "Level 3", "Level 4", "Graduate"];
  final List<String> _colleges = ["كلية الهندسة", "كلية الحاسوب", "كلية العلوم الإدارية", "كلية اللغات"];
  final List<String> _departments = ["تقنية معلومات", "علوم حاسوب", "هندسة برمجيات", "نظم معلومات"];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().getProfile();
      final data = response['data'] ?? {};

      setState(() {
        _nameController.text = data['full_name']?.toString() ?? "";
        _phoneController.text = data['phone']?.toString() ?? "";
        _bioController.text = data['bio']?.toString() ?? "";

        if (data['skills'] is List) {
          _skillsController.text = (data['skills'] as List).join(', ');
        } else {
          _skillsController.text = data['skills']?.toString() ?? "";
        }

        _uniController.text = data['university']?.toString() ?? "";
        _gpaController.text = data['gpa']?.toString() ?? "";

        if (_cities.contains(data['city'])) _selectedCity = data['city'];
        if (_levels.contains(data['level'])) _selectedLevel = data['level'];
        if (_colleges.contains(data['college'])) _selectedCollege = data['college'];
        if (_departments.contains(data['department'])) _selectedDept = data['department'];

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("خطأ في تحميل البيانات: $e");
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    List<String> skillsArray = _skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    Map<String, dynamic> body = {
      "full_name": _nameController.text.trim(),
      "phone": _phoneController.text.trim(),
      "bio": _bioController.text.trim(),
      "skills": skillsArray,
      "university": _uniController.text.trim(),
      "college": _selectedCollege,
      "department": _selectedDept,
      "level": _selectedLevel,
      "gpa": _gpaController.text.trim(),
      "city": _selectedCity,
    };

    try {
      await ApiService().updateProfile(body);

      await _loadCurrentData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حفظ البيانات بنجاح وتثبيتها"), backgroundColor: Colors.green));

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
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
        backgroundColor: const Color(0xFFF4F7FF),
        appBar: AppBar(
          title: Text("تعديل ملفك الشخصي", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
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
              children: [
                _buildSectionHeader("البيانات الأساسية", Icons.person_rounded),
                _buildPremiumCard([
                  _buildFancyField("الاسم بالكامل", Icons.badge_outlined, _nameController),
                  _buildFancyField("رقم الهاتف", Icons.phone_android_rounded, _phoneController, isNumber: true),
                  _buildFancyField("المهارات (فاصلة بين كل مهارة)", Icons.auto_awesome_outlined, _skillsController),
                  _buildFancyField("نبذة تعريفية", Icons.info_outline, _bioController, maxLines: 3),
                ]),
                const SizedBox(height: 30),
                _buildSectionHeader("البيانات الأكاديمية", Icons.school_rounded),
                _buildPremiumCard([
                  _buildFancyField("الجامعة", Icons.account_balance_rounded, _uniController),
                  _buildFancyDropdown("الكلية", Icons.account_balance_outlined, _colleges, _selectedCollege, (v) => setState(() => _selectedCollege = v)),
                  _buildFancyDropdown("القسم", Icons.account_tree_outlined, _departments, _selectedDept, (v) => setState(() => _selectedDept = v)),
                  _buildFancyDropdown("المستوى", Icons.layers_outlined, _levels, _selectedLevel, (v) => setState(() => _selectedLevel = v)),
                  _buildFancyField("المعدل (GPA)", Icons.stars_rounded, _gpaController, isNumber: true),
                  _buildFancyDropdown("المدينة", Icons.location_city_rounded, _cities, _selectedCity, (v) => setState(() => _selectedCity = v)),
                ]),
                const SizedBox(height: 50),
                _buildLuxurySaveButton(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Text(title, style: GoogleFonts.tajawal(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildFancyField(String label, IconData icon, TextEditingController ctrl, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          filled: true, fillColor: const Color(0xFFF9FBFF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        ),
        validator: (v) => v!.isEmpty ? "مطلوب" : null,
      ),
    );
  }

  Widget _buildFancyDropdown(String label, IconData icon, List<String> items, String? val, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: val,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          filled: true, fillColor: const Color(0xFFF9FBFF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildPremiumCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]),
      child: Column(children: children),
    );
  }

  Widget _buildLuxurySaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("حفظ التعديلات النهائية ✨", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
