import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
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
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(isAr ? "مركز الدعم والبلاغات" : "Support & Complaints",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            centerTitle: true,
            flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
            leading: IconButton(
              icon: Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: isAr ? "تقديم بلاغ" : "New Ticket", icon: const Icon(Icons.edit_notifications_outlined)),
                Tab(text: isAr ? "بلاغاتي" : "My History", icon: const Icon(Icons.history_rounded)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildNewComplaintTab(isAr, isDark),
              _buildMyComplaintsTab(isAr, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewComplaintTab(bool isAr, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoNote(isAr, isDark),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(35),
              border: isDark ? Border.all(color: Colors.white10) : null,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 20)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label(isAr ? "عنوان الموضوع" : "Subject", isDark),
                _buildField(_titleCtrl, isAr ? "ما هي المشكلة باختصار؟" : "Briefly describe the issue", Icons.title_rounded, isDark),
                const SizedBox(height: 20),
                _label(isAr ? "تفاصيل البلاغ" : "Ticket Details", isDark),
                _buildField(_descCtrl, isAr ? "اشرح المشكلة بالتفصيل..." : "Details...", Icons.description_outlined, isDark, maxLines: 5),
                const SizedBox(height: 40),
                _buildSubmitButton(isAr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyComplaintsTab(bool isAr, bool isDark) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService().getComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState(isAr);

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => _buildComplaintCard(snapshot.data![index], isDark, isAr),
        );
      },
    );
  }

  Widget _buildComplaintCard(dynamic data, bool isDark, bool isAr) {
    String status = data['status'] ?? 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status).withOpacity(0.1),
          child: Icon(Icons.info_outline_rounded, color: _getStatusColor(status)),
        ),
        title: Text(data['title'] ?? "", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
        subtitle: Text(data['description'] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(_getStatusText(status, isAr), style: TextStyle(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildInfoNote(bool isAr, bool isDark) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
        color: Colors.orange.withOpacity(isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.2))
    ),
    child: Row(children: [
      const Icon(Icons.tips_and_updates_outlined, color: Colors.orange),
      const SizedBox(width: 10),
      Expanded(child: Text(
          isAr ? "سيتم مراجعة بلاغك من قبل الإدارة والرد خلال 24 ساعة." : "Your report will be reviewed within 24 hours.",
          style: const TextStyle(fontSize: 12, color: Colors.orange)))
    ]),
  );

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, bool isDark, {int maxLines = 1}) {
    return TextField(
      controller: ctrl, maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
        filled: true,
        fillColor: isDark ? Colors.black26 : const Color(0xFFF8F9FD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSubmitButton(bool isAr) => SizedBox(
    width: double.infinity, height: 60,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      onPressed: _isSending ? null : () => _send(isAr),
      child: _isSending ? const CircularProgressIndicator(color: Colors.white) : Text(isAr ? "إرسال البلاغ الآن" : "Send Report Now", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );

  void _send(bool isAr) async {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await ApiService().createComplaint(_titleCtrl.text, _descCtrl.text);
      _titleCtrl.clear(); _descCtrl.clear();
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isAr ? "تم إرسال بلاغك بنجاح " : "Ticket sent successfully "),
            backgroundColor: Colors.green
        ));
      }
    } finally { if(mounted) setState(() => _isSending = false); }
  }

  Color _getStatusColor(String s) => s == 'resolved' ? Colors.green : (s == 'rejected' ? Colors.red : Colors.orange);

  String _getStatusText(String s, bool isAr) {
    if (s == 'resolved') return isAr ? "تم الحل" : "Resolved";
    if (s == 'rejected') return isAr ? "مرفوض" : "Rejected";
    return isAr ? "قيد المراجعة" : "Pending";
  }

  Widget _label(String t, bool isDark) => Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 5, left: 5),
      child: Text(t, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white70 : Colors.black87))
  );

  Widget _buildEmptyState(bool isAr) => Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
        Text(isAr ? "لا توجد بلاغات سابقة" : "No previous reports", style: const TextStyle(color: Colors.grey))
      ])
  );
}
