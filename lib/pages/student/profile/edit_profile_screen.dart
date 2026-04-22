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

  final TextEditingController _uniController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();

  String? _selectedCity;
  String? _selectedLevel;

  final List<String> _cities = ["صنعاء", "عدن", "تعز", "حضرموت", "إب", "الحديدة"];
  final List<String> _levels = ["Level 1", "Level 2", "Level 3", "Level 4", "Graduate"];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().getProfile();
      final data = response['data'];
      setState(() {
        _uniController.text = data['university'] ?? "";
        _deptController.text = data['department'] ?? "";
        _gpaController.text = data['gpa']?.toString() ?? "";

        // 2. حل مشكلة الشاشة الحمراء (التأكد من وجود القيمة في القائمة قبل تعيينها)
        if (_cities.contains(data['city'])) _selectedCity = data['city'];
        if (_levels.contains(data['level'])) _selectedLevel = data['level'];

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    Map<String, dynamic> body = {
      "department": _deptController.text.trim(),
      "level": _selectedLevel,
      "gpa": double.tryParse(_gpaController.text.trim()),
      "city": _selectedCity,
      "university": _uniController.text.trim(),
    };

    try {
      await ApiService().updateProfile(body);
      if (!mounted) return;
      _showPopup("نجاح", "تم حفظ البيانات بنجاح ✅", false);
    } catch (e) {
      _showPopup("خطأ", e.toString(), true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // الرجوع لتصميمك الأصلي (App Bar الأزرق والخلفية الفاتحة)
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text("تعديل الملف الشخصي", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // تصميمك الأصلي (البطاقات البيضاء)
              _buildCard([
                _buildTextField("الجامعة", Icons.school, _uniController),
                _buildTextField("القسم", Icons.account_tree, _deptController),
              ]),
              const SizedBox(height: 20),
              _buildCard([
                _buildDropdown("المستوى", Icons.trending_up, _levels, _selectedLevel, (v) => setState(() => _selectedLevel = v)),
                _buildDropdown("المدينة", Icons.location_city, _cities, _selectedCity, (v) => setState(() => _selectedCity = v)),
                _buildTextField("المعدل", Icons.grade, _gpaController, isNumber: true),
              ]),
              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- دوال البناء (Widgets) بنفس ستايلك السابق ---
  Widget _buildTextField(String label, IconData icon, TextEditingController ctrl, {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: AppColors.primaryBlue)),
    );
  }

  Widget _buildDropdown(String label, IconData icon, List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: AppColors.primaryBlue)),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("حفظ التغييرات", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  void _showPopup(String title, String msg, bool isError) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title, style: TextStyle(color: isError ? Colors.red : Colors.green)),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("موافق"))],
      ),
    );
  }
}
