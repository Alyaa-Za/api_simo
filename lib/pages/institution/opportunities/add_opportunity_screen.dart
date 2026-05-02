import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';

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

  Future<void> _handleSave(bool isAr) async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isAr ? "يرجى تحديد تواريخ التدريب" : "Please select training dates")));
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
      _showSuccess(isAr);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess(bool isAr) {
    showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
      content: Text(isAr ? "تم نشر الفرصة بنجاح " : "Opportunity published ",
          textAlign: TextAlign.center, style: GoogleFonts.tajawal()),
      actions: [
        TextButton(
            onPressed: () { Navigator.pop(c); Navigator.pop(context); },
            child: Text(isAr ? "موافق" : "OK")
        )
      ],
    ));
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
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
          title: Text(isAr ? "نشر فرصة جديدة" : "Post New Opportunity",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
          leading: IconButton(
            icon: Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildCard(isAr ? "المعلومات الأساسية" : "Basic Information", [
                  _field(isAr ? "عنوان الفرصة *" : "Opportunity Title *", Icons.work_outline, _title, isDark),
                  _field(isAr ? "القسم المستهدف" : "Target Department", Icons.account_tree_outlined, _dept, isDark),
                  _field(isAr ? "الوصف التفصيلي" : "Detailed Description", Icons.description, _desc, isDark, maxLines: 3),
                  _field(isAr ? "المهارات المطلوبة" : "Required Skills", Icons.star_border_rounded, _skills, isDark),
                  Row(children: [
                    Expanded(child: _field(isAr ? "المقاعد *" : "Seats *", Icons.people_outline, _seats, isDark, isNum: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _field(isAr ? "المدينة" : "City", Icons.location_on_outlined, _city, isDark)),
                  ]),
                ], isDark),

                const SizedBox(height: 20),

                _buildCard(isAr ? "نوع التدريب" : "Training Type", [
                  RadioListTile<String>(
                    title: Text(isAr ? "تدريب صيفي (Summer)" : "Summer Training",
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14)),
                    value: "summer",
                    activeColor: AppColors.primaryBlue,
                    groupValue: _trainingType,
                    onChanged: (v) => setState(() => _trainingType = v!),
                  ),
                  RadioListTile<String>(
                    title: Text(isAr ? "تدريب تعاوني (Coop)" : "Cooperative Training",
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14)),
                    value: "cooperative",
                    activeColor: AppColors.primaryBlue,
                    groupValue: _trainingType,
                    onChanged: (v) => setState(() => _trainingType = v!),
                  ),
                ], isDark),

                const SizedBox(height: 20),

                _buildCard(isAr ? "المواعيد" : "Important Dates", [
                  _datePicker(isAr ? "تاريخ البدء *" : "Start Date *", _startDate, (d) => setState(() => _startDate = d), isDark, isAr),
                  _datePicker(isAr ? "تاريخ الانتهاء *" : "End Date *", _endDate, (d) => setState(() => _endDate = d), isDark, isAr),
                  _datePicker(isAr ? "آخر موعد للتقديم" : "Apply Deadline", _deadline, (d) => setState(() => _deadline = d), isDark, isAr),
                ], isDark),

                const SizedBox(height: 20),

                _buildCard(isAr ? "الأسئلة المخصصة للمتقدمين" : "Custom Questions", [
                  ...List.generate(_customQuestions.length, (i) => Row(children: [
                    Expanded(child: _field(isAr ? "سؤال ${i+1}" : "Question ${i+1}", Icons.help_outline, _customQuestions[i], isDark)),
                    IconButton(onPressed: ()=> setState(()=> _customQuestions.removeAt(i)), icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                  ])),
                  TextButton.icon(
                      onPressed: ()=> setState(()=> _customQuestions.add(TextEditingController())),
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(isAr ? "إضافة سؤال مخصص" : "Add Custom Question")
                  ),
                ], isDark),

                const SizedBox(height: 40),
                _submitBtn(isAr),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String t, List<Widget> c, bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.only(right: 10, left: 10, bottom: 8),
          child: Text(t, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.primaryBlue))),
      Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: isDark ? Border.all(color: Colors.white10) : null,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 10)]
          ),
          child: Column(children: c)
      ),
    ],
  );

  Widget _field(String l, IconData i, TextEditingController c, bool isDark, {bool isNum = false, int maxLines = 1}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: l,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        prefixIcon: Icon(i, color: AppColors.primaryBlue, size: 20),
        filled: true,
        fillColor: isDark ? Colors.black26 : const Color(0xFFF9FBFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty && l.contains('*') ? "!" : null,
    ),
  );

  Widget _datePicker(String l, DateTime? d, Function(DateTime) onP, bool isDark, bool isAr) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    subtitle: Text(d == null ? (isAr ? "اختر التاريخ" : "Select Date") : DateFormat('yyyy-MM-dd').format(d!),
        style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
    trailing: const Icon(Icons.calendar_month, color: AppColors.primaryBlue, size: 22),
    onTap: () async {
      DateTime? p = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: isDark ? ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(primary: AppColors.primaryBlue),
              ) : ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
              ),
              child: child!,
            );
          }
      );
      if (p != null) onP(p);
    },
  );

  Widget _submitBtn(bool isAr) => Container(
    width: double.infinity, height: 60,
    decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
    ),
    child: ElevatedButton(
      onPressed: _isLoading ? null : () => _handleSave(isAr),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(isAr ? "نشر الفرصة الآن " : "Post Opportunity Now ",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}
