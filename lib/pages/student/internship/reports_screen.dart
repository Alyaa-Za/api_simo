import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  int _week = 1;
  bool _loading = false;
  File? _selectedFile;

  Future<void> _pickDocument(bool isAr) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showMsg(isAr ? "خطأ في الوصول للملفات: $e" : "File access error: $e", isError: true);
    }
  }

  Future<void> _submit(bool isAr) async {
    if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty || _selectedFile == null) {
      _showMsg(isAr ? "يرجى كتابة التفاصيل وإرفاق ملف التقرير" : "Please fill details and attach report file", isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiService().submitReport(
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        weekNumber: _week,
        filePath: _selectedFile!.path,
      );

      if (!mounted) return;
      _showPremiumSuccess(isAr);
    } catch (e) {
      _showMsg(isAr ? "فشل الرفع: $e" : "Upload failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMsg(String m, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m, style: GoogleFonts.tajawal()),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          title: Text(isAr ? "رفع التقرير الدوري" : "Submit Periodical Report",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          centerTitle: true,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
          leading: IconButton(
            icon: Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              _buildHint(isAr, isDark),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 20)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel(isAr ? "اختر أسبوع التدريب" : "Select Training Week", Icons.calendar_today_outlined),
                    _buildDropdown(isDark),
                    const SizedBox(height: 20),

                    _sectionLabel(isAr ? "عنوان الإنجاز" : "Achievement Title", Icons.edit_note_rounded),
                    _buildTextField(_titleCtrl, isAr ? "مثال: إدارة المهام التقنية" : "e.g. IT Task Management", isDark),
                    const SizedBox(height: 20),

                    _sectionLabel(isAr ? "ملخص الأداء" : "Performance Summary", Icons.description_outlined),
                    _buildLargeField(_contentCtrl, isAr ? "اكتب نبذة مختصرة عما أنجزته..." : "Write a brief about your achievement...", isDark),
                    const SizedBox(height: 25),

                    _sectionLabel(isAr ? "ملف التقرير (PDF/Word)" : "Report File (PDF/Word)", Icons.cloud_upload_outlined),
                    _buildFilePickerBox(isAr, isDark),

                    const SizedBox(height: 40),
                    _buildSubmitButton(isAr),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePickerBox(bool isAr, bool isDark) {
    return InkWell(
      onTap: () => _pickDocument(isAr),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.black26 : const Color(0xFFF8F9FD),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _selectedFile != null ? Colors.green : (isDark ? Colors.white10 : Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Icon(
              _selectedFile != null ? Icons.insert_drive_file : Icons.upload_file_rounded,
              color: _selectedFile != null ? Colors.green : AppColors.primaryBlue,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                _selectedFile != null
                    ? _selectedFile!.path.split('/').last
                    : (isAr ? "اضغط لاختيار ملف التقرير" : "Tap to select report file"),
                style: TextStyle(color: _selectedFile != null ? (isDark ? Colors.white : Colors.black87) : Colors.grey, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String t, IconData i) => Padding(
    padding: const EdgeInsets.only(bottom: 10, right: 5, left: 5),
    child: Row(children: [Icon(i, size: 18, color: AppColors.primaryBlue), const SizedBox(width: 8), Text(t, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14))]),
  );

  Widget _buildDropdown(bool isDark) => DropdownButtonFormField<int>(
    value: _week,
    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
    decoration: InputDecoration(filled: true, fillColor: isDark ? Colors.black12 : const Color(0xFFF8F9FD), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(Provider.of<LanguageProvider>(context, listen: false).locale.languageCode == 'ar' ? "الأسبوع ${i + 1}" : "Week ${i + 1}"))).toList(),
    onChanged: (v) => setState(() => _week = v!),
  );

  Widget _buildTextField(TextEditingController c, String h, bool isDark) => TextField(
    controller: c,
    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
    decoration: InputDecoration(hintText: h, hintStyle: const TextStyle(fontSize: 13, color: Colors.grey), filled: true, fillColor: isDark ? Colors.black12 : const Color(0xFFF8F9FD), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
  );

  Widget _buildLargeField(TextEditingController c, String h, bool isDark) => TextField(
    controller: c, maxLines: 4,
    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
    decoration: InputDecoration(hintText: h, hintStyle: const TextStyle(fontSize: 13, color: Colors.grey), filled: true, fillColor: isDark ? Colors.black12 : const Color(0xFFF8F9FD), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
  );

  Widget _buildSubmitButton(bool isAr) => SizedBox(
    width: double.infinity, height: 60,
    child: ElevatedButton(
      onPressed: _loading ? null : () => _submit(isAr),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text(isAr ? "اعتماد ورفع الآن" : "Submit Now", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildHint(bool isAr, bool isDark) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
        color: isDark ? AppColors.primaryBlue.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1))
    ),
    child: Row(children: [
      const Icon(Icons.info_outline, color: AppColors.primaryBlue),
      const SizedBox(width: 10),
      Expanded(child: Text(isAr ? "يرجى التأكد من أن الملف بصيغة PDF أو Word لضمان القبول." : "Please ensure the file is in PDF or Word format for acceptance.",
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.blueGrey)))
    ]),
  );

  void _showPremiumSuccess(bool isAr) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            Text(isAr ? "تم الرفع بنجاح" : "Uploaded Successfully", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 10),
            Text(isAr ? "سيتم مراجعة تقريرك من قبل المشرف قريباً." : "Your report will be reviewed by the supervisor soon.",
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(c), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: const StadiumBorder()), child: Text(isAr ? "إغلاق" : "Close", style: const TextStyle(color: Colors.white)))
          ],
        ),
      ),
    );
  }
}
