import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});
  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  String? _subject;
  final _descCtrl = TextEditingController();
  final List<String> _subjects = ["تأخر الرد", "مشكلة تقنية", "سلوك المؤسسة", "أخرى"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الدعم الفني والشكاوى"), backgroundColor: Colors.white, elevation: 0),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().getComplaints(), // [استدعاء]: جلب شكاواك السابقة
        builder: (context, snapshot) {
          final list = snapshot.data ?? [];
          return Column(
            children: [
              _buildTopBanner(),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text("لم تقدم أي شكاوى بعد"))
                    : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  itemBuilder: (c, i) => _complaintCard(list[i]),
                ),
              ),
              _buildFloatingAddButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBanner() => Container(
    margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(20)),
    child: Row(children: [const Icon(Icons.help_center, color: Colors.white, size: 40), const SizedBox(width: 15), const Expanded(child: Text("نحن هنا لمساعدتك، لا تتردد في طرح مشكلتك", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))]),
  );

  Widget _buildFloatingAddButton() => Padding(
    padding: const EdgeInsets.all(20),
    child: ElevatedButton.icon(
      onPressed: () => _showAddDialog(),
      icon: const Icon(Icons.add), label: const Text("تقديم شكوى جديدة"),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: const StadiumBorder()),
    ),
  );

  void _showAddDialog() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left: 25, right: 25, top: 25),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("تذكرة دعم جديدة", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
          DropdownButtonFormField<String>(initialValue: _subject, items: _subjects.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _subject = v), decoration: const InputDecoration(labelText: "الموضوع")),
          TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "التفاصيل")),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () async {
            await ApiService().createComplaint(_subject!, _descCtrl.text); // [استدعاء]: إرسال للقاعدة
            Navigator.pop(c); setState(() {});
          }, child: const Text("إرسال الشكوى الآن")),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _complaintCard(dynamic item) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(title: Text(item['title'] ?? ""), subtitle: Text(item['status'] ?? ""), trailing: const Icon(Icons.info_outline)),
  );
}
