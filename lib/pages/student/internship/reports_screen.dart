import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart'; // المكتبة المطلوبة للملفات
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';

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
  File? _selectedFile; // هنا سيتم حفظ ملف الـ PDF أو الـ Word

  // ── الدالة المصلحة لاختيار الملفات (بدون خطأ platform getter) ──
  Future<void> _pickDocument() async {
    try {
      // الطريقة الصحيحة للاستدعاء في الإصدارات الجديدة
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'], // السماح بالملفات الأكاديمية
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showMsg("خطأ في الوصول للملفات: $e", isError: true);
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty || _selectedFile == null) {
      _showMsg("يرجى كتابة التفاصيل وإرفاق ملف التقرير", isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      // إرسال البيانات للباك أند مع مسار الملف الحقيقي
      await ApiService().submitReport(
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        weekNumber: _week,
        filePath: _selectedFile!.path,
      );

      if (!mounted) return;
      _showPremiumSuccess();
    } catch (e) {
      _showMsg("فشل الرفع: $e", isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMsg(String m, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        appBar: AppBar(
          title: Text("رفع التقرير الدوري", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              _buildHint(),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel("اختر أسبوع التدريب", Icons.calendar_today_outlined),
                    _buildDropdown(),
                    const SizedBox(height: 20),

                    _sectionLabel("عنوان الإنجاز", Icons.edit_note_rounded),
                    _buildTextField(_titleCtrl, "مثال: إدارة المهام التقنية"),
                    const SizedBox(height: 20),

                    _sectionLabel("ملخص الأداء", Icons.description_outlined),
                    _buildLargeField(_contentCtrl, "اكتب نبذة مختصرة عما أنجزته..."),
                    const SizedBox(height: 25),

                    _sectionLabel("ملف التقرير (PDF/Word)", Icons.cloud_upload_outlined),
                    _buildFilePickerBox(), // الزر الفخم لاختيار الملف

                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePickerBox() {
    return InkWell(
      onTap: _pickDocument,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FD),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _selectedFile != null ? Colors.green : Colors.grey.shade200),
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
                    ? _selectedFile!.path.split('/').last // عرض اسم الملف المختار
                    : "اضغط لاختيار ملف التقرير",
                style: TextStyle(color: _selectedFile != null ? Colors.black87 : Colors.grey, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- دوال التصميم المساعدة ---
  Widget _sectionLabel(String t, IconData i) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [Icon(i, size: 18, color: AppColors.primaryBlue), const SizedBox(width: 8), Text(t, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14))]),
  );

  Widget _buildDropdown() => DropdownButtonFormField<int>(
    value: _week,
    decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF8F9FD), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text("الأسبوع ${i + 1}"))).toList(),
    onChanged: (v) => setState(() => _week = v!),
  );

  Widget _buildTextField(TextEditingController c, String h) => TextField(
    controller: c,
    decoration: InputDecoration(hintText: h, filled: true, fillColor: const Color(0xFFF8F9FD), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
  );

  Widget _buildLargeField(TextEditingController c, String h) => TextField(
    controller: c, maxLines: 4,
    decoration: InputDecoration(hintText: h, filled: true, fillColor: const Color(0xFFF8F9FD), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity, height: 60,
    child: ElevatedButton(
      onPressed: _loading ? null : _submit,
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text("اعتماد ورفع الآن", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildHint() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1))),
    child: Row(children: [const Icon(Icons.info_outline, color: AppColors.primaryBlue), const SizedBox(width: 10), Expanded(child: Text("يرجى التأكد من أن الملف بصيغة PDF أو Word لضمان القبول.", style: TextStyle(fontSize: 12, color: Colors.blueGrey)))]),
  );

  void _showPremiumSuccess() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            Text("تم الرفع بنجاح", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
            const Text("سيتم مراجعة تقريرك من قبل المشرف.", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () { Navigator.pop(c); Navigator.pop(context); }, child: const Text("موافق")),
          ],
        ),
      ),
    );
  }
}
