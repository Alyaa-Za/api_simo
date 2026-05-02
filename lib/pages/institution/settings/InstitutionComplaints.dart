import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';

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
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(isAr ? "مركز البلاغات والدعم" : "Support & Tickets",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
        ),
        body: Column(
          children: [
            _buildActionHeader(isAr, isDark),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: ApiService().getInstitutionComplaints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) return _buildEmpty(isAr, isDark);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) => _complaintCard(list[index], isDark, isAr),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionHeader(bool isAr, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              Text(isAr ? "سجل البلاغات المقدمة" : "Ticket History",
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () => _showNewComplaintSheet(isAr, isDark),
              icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
              label: Text(isAr ? "رفع بلاغ جديد للإدارة" : "Submit New Ticket",
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showNewComplaintSheet(bool isAr, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom + 30, left: 25, right: 25, top: 20),
          decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              Text(isAr ? "تقديم بلاغ جديد" : "New Support Ticket",
                  style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 25),
              _buildInput(isAr ? "عنوان البلاغ" : "Subject", Icons.title_rounded, _titleCtrl, isDark),
              const SizedBox(height: 15),
              _buildInput(isAr ? "تفاصيل المشكلة..." : "Issue details...", Icons.text_snippet_outlined, _descCtrl, isDark, maxLines: 4),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSending ? null : () => _handleSend(isAr),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: const StadiumBorder()),
                  child: _isSending
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isAr ? "إرسال الآن للجامعة" : "Submit to University",
                      style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSend(bool isAr) async {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await ApiService().createInstitutionComplaint(_titleCtrl.text, _descCtrl.text);
      if (mounted) {
        Navigator.pop(context);
        _titleCtrl.clear(); _descCtrl.clear();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isAr ? "تم إرسال بلاغك بنجاح " : "Ticket sent successfully "),
            backgroundColor: Colors.green, behavior: SnackBarBehavior.floating
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: $e"), backgroundColor: Colors.redAccent
      ));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget _complaintCard(dynamic data, bool isDark, bool isAr) {
    bool isDone = data['status'] == 'resolved';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        title: Text(data['title'] ?? "",
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text(data['created_at']?.toString().substring(0, 10) ?? "",
            style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: isDone ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)
          ),
          child: Text(
              isDone ? (isAr ? "محلولة" : "Resolved") : (isAr ? "قيد المراجعة" : "Pending"),
              style: TextStyle(color: isDone ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController ctrl, bool isDark, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        filled: true,
        fillColor: isDark ? Colors.black26 : const Color(0xFFF8F9FD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildEmpty(bool isAr, bool isDark) => Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_edu_rounded, size: 80, color: isDark ? Colors.white10 : Colors.grey.shade300),
            const SizedBox(height: 15),
            Text(isAr ? "لا يوجد بلاغات سابقة" : "No previous tickets",
                style: GoogleFonts.tajawal(color: Colors.grey, fontWeight: FontWeight.bold))
          ]
      )
  );
}
