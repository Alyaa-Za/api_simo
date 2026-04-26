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
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7FF),
          appBar: AppBar(
            title: Text("مركز الدعم والبلاغات",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
            flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
            bottom: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "تقديم بلاغ", icon: Icon(Icons.edit_notifications_outlined)),
                Tab(text: "بلاغاتي السابقة", icon: Icon(Icons.history_rounded)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildNewComplaintTab(),
              _buildMyComplaintsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewComplaintTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoNote(),
          const SizedBox(height: 30),
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
                _label("عنوان الموضوع"),
                _buildField(_titleCtrl, "ما هي المشكلة باختصار؟", Icons.title_rounded),
                const SizedBox(height: 20),
                _label("تفاصيل البلاغ"),
                _buildField(_descCtrl, "اشرح المشكلة بالتفصيل لمساعدتنا في حلها...", Icons.description_outlined, maxLines: 5),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyComplaintsTab() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService().getComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => _buildComplaintCard(snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildComplaintCard(dynamic data) {
    String status = data['status'] ?? 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status).withOpacity(0.1),
          child: Icon(Icons.info_outline_rounded, color: _getStatusColor(status)),
        ),
        title: Text(data['title'] ?? "", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        subtitle: Text(data['description'] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(_getStatusText(status), style: TextStyle(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildInfoNote() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.orange.withOpacity(0.1))),
    child: const Row(children: [Icon(Icons.tips_and_updates_outlined, color: Colors.orange), SizedBox(width: 10), Expanded(child: Text("سيتم مراجعة بلاغك من قبل إدارة النظام والرد عليك خلال 24 ساعة.", style: TextStyle(fontSize: 12, color: Colors.orange)))]),
  );

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl, maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint, prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        filled: true, fillColor: const Color(0xFFF8F9FD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity, height: 60,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      onPressed: _isSending ? null : _send,
      child: _isSending ? const CircularProgressIndicator(color: Colors.white) : const Text("إرسال البلاغ الآن ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );

  void _send() async {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await ApiService().createComplaint(_titleCtrl.text, _descCtrl.text);
      _titleCtrl.clear(); _descCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إرسال بلاغك بنجاح "), backgroundColor: Colors.green));
    } finally { setState(() => _isSending = false); }
  }

  Color _getStatusColor(String s) => s == 'resolved' ? Colors.green : (s == 'rejected' ? Colors.red : Colors.orange);
  String _getStatusText(String s) => s == 'resolved' ? "تم الحل" : (s == 'rejected' ? "مرفوض" : "قيد المراجعة");
  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8, right: 5), child: Text(t, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14)));
  Widget _buildEmptyState() => const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inbox_rounded, size: 80, color: Colors.grey), Text("لا توجد بلاغات سابقة")]));
}
