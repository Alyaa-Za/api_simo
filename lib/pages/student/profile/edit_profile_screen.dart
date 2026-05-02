import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

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
    _loadCurrentDataFromApi();
  }

  Future<void> _loadCurrentDataFromApi() async {
    try {
      final response = await ApiService().getProfile();
      final data = response['data'] ?? {};

      setState(() {
        _nameController.text = data['full_name']?.toString() ?? "";

        _phoneController.text = data['phone']?.toString() ?? data['mobile']?.toString() ?? "";

        _bioController.text = data['bio']?.toString() ?? "";

        if (data['skills'] is List) {
          _skillsController.text = (data['skills'] as List).join(', ');
        } else {
          _skillsController.text = data['skills']?.toString() ?? "";
        }

        _uniController.text = data['university']?.toString() ?? "";
        _gpaController.text = data['gpa']?.toString() ?? "";

        String? apiCollege = data['college']?.toString().trim();
        if (_colleges.contains(apiCollege)) _selectedCollege = apiCollege;

        String? apiDept = data['department']?.toString().trim();
        if (_departments.contains(apiDept)) _selectedDept = apiDept;

        if (_cities.contains(data['city'])) _selectedCity = data['city'];
        if (_levels.contains(data['level'])) _selectedLevel = data['level'];

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("خطأ في تحميل البيانات: $e");
    }
  }

  Future<void> _handleSave(bool isAr) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    List<String> skillsArray = _skillsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

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

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isAr ? "تم حفظ التعديلات بنجاح " : "Changes saved successfully "),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ));

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        appBar: AppBar(
          title: Text(isAr ? "تعديل الملف الشخصي" : "Edit Profile",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          centerTitle: true,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
          leading: IconButton(
            icon: Icon(isAr ? Icons.arrow_back_ios : Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSectionHeader(isAr ? "البيانات الأساسية" : "Basic Info", Icons.person_rounded, isDark),
                _buildPremiumCard([
                  _buildFancyField(isAr ? "الاسم بالكامل" : "Full Name", Icons.badge_outlined, _nameController, isDark),
                  _buildFancyField(isAr ? "رقم الهاتف" : "Phone Number", Icons.phone_android_rounded, _phoneController, isDark, isNumber: true),
                  _buildFancyField(isAr ? "المهارات (افصل بفاصلة)" : "Skills (comma separated)", Icons.auto_awesome_outlined, _skillsController, isDark),
                  _buildFancyField(isAr ? "نبذة تعريفية" : "Bio", Icons.info_outline, _bioController, isDark, maxLines: 3),
                ], isDark),

                const SizedBox(height: 30),
                _buildSectionHeader(isAr ? "البيانات الأكاديمية" : "Academic Info", Icons.school_rounded, isDark),
                _buildPremiumCard([
                  _buildFancyField(isAr ? "الجامعة" : "University", Icons.account_balance_rounded, _uniController, isDark),
                  _buildFancyDropdown(isAr ? "الكلية" : "College", Icons.account_balance_outlined, _colleges, _selectedCollege, (v) => setState(() => _selectedCollege = v), isDark, isAr),
                  _buildFancyDropdown(isAr ? "القسم" : "Department", Icons.account_tree_outlined, _departments, _selectedDept, (v) => setState(() => _selectedDept = v), isDark, isAr),
                  _buildFancyDropdown(isAr ? "المستوى" : "Level", Icons.layers_outlined, _levels, _selectedLevel, (v) => setState(() => _selectedLevel = v), isDark, isAr),
                  _buildFancyField(isAr ? "المعدل (GPA)" : "GPA", Icons.stars_rounded, _gpaController, isDark, isNumber: true),
                  _buildFancyDropdown(isAr ? "المدينة" : "City", Icons.location_city_rounded, _cities, _selectedCity, (v) => setState(() => _selectedCity = v), isDark, isAr),
                ], isDark),

                const SizedBox(height: 50),
                _buildLuxurySaveButton(isAr),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, right: 10, left: 10),
      child: Row(children: [Icon(icon, size: 18, color: AppColors.primaryBlue), const SizedBox(width: 10), Text(title, style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark))]),
    );
  }

  Widget _buildPremiumCard(List<Widget> children, bool isDark) => Container(
    padding: const EdgeInsets.fromLTRB(20, 25, 20, 5),
    decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]
    ),
    child: Column(children: children),
  );

  Widget _buildFancyField(String label, IconData icon, TextEditingController ctrl, bool isDark, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
          filled: true,
          fillColor: isDark ? Colors.black26 : const Color(0xFFF8F9FD),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFancyDropdown(String label, IconData icon, List<String> items, String? val, Function(String?) onChanged, bool isDark, bool isAr) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: val,
        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
        items: items.map((e) => DropdownMenuItem(value: e, alignment: isAr ? Alignment.centerRight : Alignment.centerLeft, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
          filled: true,
          fillColor: isDark ? Colors.black26 : const Color(0xFFF8F9FD),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildLuxurySaveButton(bool isAr) => SizedBox(
    width: double.infinity, height: 60,
    child: ElevatedButton(
      onPressed: _isLoading ? null : () => _handleSave(isAr),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(isAr ? "حفظ التعديلات النهائية" : "Save Final Changes",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}
