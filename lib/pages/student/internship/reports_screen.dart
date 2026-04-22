import 'package:flutter/material.dart';
import '../../../core/api/api_s.dart';

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

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ApiService().submitReport({
        "title": _titleCtrl.text,
        "content": _contentCtrl.text,
        "week_number": _week,
        "submitted_by": "student"
      });
      Navigator.pop(context);
      _showSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة تقرير أسبوعي")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<int>(
            initialValue: _week,
            decoration: const InputDecoration(labelText: "رقم الأسبوع"),
            items: List.generate(12, (i) => DropdownMenuItem(value: i+1, child: Text("الأسبوع ${i+1}"))).toList(),
            onChanged: (v) => setState(() => _week = v!),
          ),
          const SizedBox(height: 15),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: "عنوان التقرير")),
          const SizedBox(height: 15),
          TextField(controller: _contentCtrl, maxLines: 5, decoration: const InputDecoration(labelText: "تفاصيل الإنجاز")),
          const SizedBox(height: 30),
          _loading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submit, child: const Text("إرسال التقرير")),
        ],
      ),
    );
  }

  void _showSuccess() {
    showDialog(context: context, builder: (c) => const AlertDialog(title: Text("نجاح"), content: Text("تم رفع التقرير الميداني بنجاح ✅")));
  }
}
