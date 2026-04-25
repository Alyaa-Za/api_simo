import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';

class InstitutionComplaintsScreen extends StatefulWidget {
  const InstitutionComplaintsScreen({super.key});

  @override
  State<InstitutionComplaintsScreen> createState() => _InstitutionComplaintsScreenState();
}

class _InstitutionComplaintsScreenState extends State<InstitutionComplaintsScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          title: Text("مركز البلاغات والدعم", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
        ),
        body: Column(
          children: [
            _buildActionHeader(),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: ApiService().getInstitutionComplaints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) return _buildEmpty();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: list.length,
                    itemBuilder: (context, index) => _complaintCard(list[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              Text("إجمالي البلاغات المقدمة", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _showNewComplaintSheet,
              icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
              label: Text("رفع بلاغ جديد للإدارة", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                shadowColor: Colors.red.withOpacity(0.3),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showNewComplaintSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left: 25, right: 25, top: 20),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              Text("تقديم بلاغ جديد", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              _buildInput("عنوان البلاغ", Icons.title_rounded, _titleCtrl),
              const SizedBox(height: 15),
              _buildInput("تفاصيل المشكلة...", Icons.text_snippet_outlined, _descCtrl, maxLines: 4),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _handleSend,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: const StadiumBorder()),
                  child: _isSending
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("إرسال الآن للجامعة", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSend() async {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await ApiService().createInstitutionComplaint(_titleCtrl.text, _descCtrl.text); // الدالة 18
      if (mounted) {
        Navigator.pop(context);
        _titleCtrl.clear(); _descCtrl.clear();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إرسال بلاغك بنجاح ✅")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل الإرسال: $e")));
    } finally {
      setState(() => _isSending = false);
    }
  }

  Widget _complaintCard(dynamic data) {
    bool isDone = data['status'] == 'resolved';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: ListTile(
        title: Text(data['title'] ?? "", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        subtitle: Text(data['created_at']?.toString().substring(0, 10) ?? "", style: const TextStyle(fontSize: 11)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: isDone ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(isDone ? "محلولة" : "تحت المراجعة", style: TextStyle(color: isDone ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController ctrl, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        filled: true, fillColor: const Color(0xFFF8F9FD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildEmpty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history_edu_rounded, size: 80, color: Colors.grey.shade300), const SizedBox(height: 15), Text("لا يوجد بلاغات سابقة", style: GoogleFonts.tajawal(color: Colors.grey, fontWeight: FontWeight.bold))]));
}
