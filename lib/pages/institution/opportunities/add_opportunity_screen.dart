import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';

class AddOpportunityScreen extends StatefulWidget {
  const AddOpportunityScreen({super.key});
  @override
  State<AddOpportunityScreen> createState() => _AddOpportunityScreenState();
}

class _AddOpportunityScreenState extends State<AddOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _title = TextEditingController();
  final _dept = TextEditingController();
  final _desc = TextEditingController();
  final _skills = TextEditingController();
  final _seats = TextEditingController(text: "1");
  final _city = TextEditingController();

  String _trainingType = "summer";
  DateTime? _startDate, _endDate, _deadline;
  final List<TextEditingController> _customQuestions = [];

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى تحديد تواريخ التدريب")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      List<String> questionsArray = _customQuestions
          .map((e) => e.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      Map<String, dynamic> body = {
        "title": _title.text.trim(),
        "department": _dept.text.trim(),
        "description": _desc.text.trim(),
        "required_skills": _skills.text.trim(),
        "start_date": DateFormat('yyyy-MM-dd').format(_startDate!),
        "end_date": DateFormat('yyyy-MM-dd').format(_endDate!),
        "application_deadline": _deadline != null ? DateFormat('yyyy-MM-dd').format(_deadline!) : null,
        "available_seats": int.parse(_seats.text),
        "city": _city.text.trim(),
        "training_type": _trainingType,
        "custom_questions": questionsArray,
        "status": "active",
      };

      await ApiService().createInstitutionOpportunity(body);
      if (!mounted) return;
      _showSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess() {
    showDialog(context: context, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
      content: const Text("تم نشر الفرصة بنجاح ", textAlign: TextAlign.center),
      actions: [TextButton(onPressed: () { Navigator.pop(c); Navigator.pop(context); }, child: const Text("موافق"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          title: Text("نشر فرصة جديدة", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
          centerTitle: true,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildCard("المعلومات الأساسية", [
                  _field("عنوان الفرصة *", Icons.work_outline, _title),
                  _field("القسم المستهدف", Icons.account_tree_outlined, _dept),
                  _field("الوصف التفصيلي", Icons.description, _desc, maxLines: 3),
                  _field("المهارات المطلوبة", Icons.star_border_rounded, _skills),
                  Row(children: [
                    Expanded(child: _field("عدد المقاعد *", Icons.people_outline, _seats, isNum: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _field("المدينة", Icons.location_on_outlined, _city)),
                  ]),
                ]),
                const SizedBox(height: 20),
                _buildCard("نوع التدريب", [
                  RadioListTile<String>(
                    title: const Text("تدريب صيفي (Summer)"),
                    value: "summer",
                    groupValue: _trainingType,
                    onChanged: (v) => setState(() => _trainingType = v!),
                  ),
                  RadioListTile<String>(
                    title: const Text("تدريب تعاوني (Cooperative)"),
                    value: "cooperative",
                    groupValue: _trainingType,
                    onChanged: (v) => setState(() => _trainingType = v!),
                  ),
                ]),
                const SizedBox(height: 20),
                _buildCard("المواعيد", [
                  _datePicker("تاريخ البدء *", _startDate, (d) => setState(() => _startDate = d)),
                  _datePicker("تاريخ الانتهاء *", _endDate, (d) => setState(() => _endDate = d)),
                  _datePicker("آخر موعد للتقديم", _deadline, (d) => setState(() => _deadline = d)),
                ]),
                const SizedBox(height: 20),
                _buildCard("الأسئلة المخصصة للمتقدمين", [
                  ...List.generate(_customQuestions.length, (i) => Row(children: [
                    Expanded(child: _field("سؤال ${i+1}", Icons.help_outline, _customQuestions[i])),
                    IconButton(onPressed: ()=> setState(()=> _customQuestions.removeAt(i)), icon: const Icon(Icons.delete_outline, color: Colors.red)),
                  ])),
                  TextButton.icon(
                      onPressed: ()=> setState(()=> _customQuestions.add(TextEditingController())),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("إضافة سؤال مخصص")
                  ),
                ]),
                const SizedBox(height: 40),
                _submitBtn(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String t, List<Widget> c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.only(right: 10, bottom: 8), child: Text(t, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.primaryBlue))),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]), child: Column(children: c)),
    ],
  );

  Widget _field(String l, IconData i, TextEditingController c, {bool isNum = false, int maxLines = 1}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: l,
        prefixIcon: Icon(i, color: AppColors.primaryBlue, size: 20),
        filled: true,
        fillColor: const Color(0xFFF9FBFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty && l.contains('*') ? "هذا الحقل مطلوب" : null,
    ),
  );

  Widget _datePicker(String l, DateTime? d, Function(DateTime) onP) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(l, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    subtitle: Text(d == null ? "اختر التاريخ" : DateFormat('yyyy-MM-dd').format(d!)),
    trailing: const Icon(Icons.calendar_month, color: AppColors.primaryBlue),
    onTap: () async {
      DateTime? p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
      if (p != null) onP(p);
    },
  );

  Widget _submitBtn() => Container(
    width: double.infinity, height: 60,
    decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 10)]
    ),
    child: ElevatedButton(
      onPressed: _isLoading ? null : _handleSave,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("نشر الفرصة الآن", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}
