import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';

class SupportCenterScreen extends StatefulWidget {
  const SupportCenterScreen({super.key});

  @override
  State<SupportCenterScreen> createState() => _SupportCenterScreenState();
}

class _SupportCenterScreenState extends State<SupportCenterScreen> {
  final List<String> _subjects = ["مشكلة في التسجيل", "تأخر الرد على الطلب", "خطأ في البيانات الأكاديمية", "مشكلة تقنية في الموقع", "أخرى"];
  String? _selectedSubject;
  final _detailsCtrl = TextEditingController();
  bool _isOther = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("مركز الدعم الفني"),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Column(
        children: [

          _buildPremiumHeader(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text("تذاكرك السابقة", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 17)),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: ApiService().getComplaints(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final list = snapshot.data ?? [];
                if (list.isEmpty) return const Center(child: Text("لم تقم بتقديم أي شكوى بعد"));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _buildComplaintCard(list[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildPremiumFab(),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent_rounded, size: 60, color: Colors.white),
          const SizedBox(height: 15),
          Text("كيف يمكننا مساعدتك اليوم؟",
              style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("فريقنا متواجد دائماً لحل مشاكلك",
              style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(dynamic data) {
    Color statusColor = data['status'] == 'resolved' ? Colors.green : Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: ListTile(
        title: Text(data['title'] ?? "", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(data['created_at'] ?? "", style: const TextStyle(fontSize: 10)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(data['status'] == 'resolved' ? "تم الحل" : "قيد المعالجة",
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildPremiumFab() {
    return FloatingActionButton.extended(
      onPressed: () => _showNewComplaintSheet(),
      backgroundColor: AppColors.primaryBlue,
      icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
      label: Text("إضافة شكوى", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  void _showNewComplaintSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (c) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left: 25, right: 25, top: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text("تقديم شكوى جديدة", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),

              DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                decoration: const InputDecoration(labelText: "موضوع الشكوى", prefixIcon: Icon(Icons.subject)),
                items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.tajawal(fontSize: 14)))).toList(),
                onChanged: (val) {
                  setModalState(() {
                    _selectedSubject = val;
                    _isOther = (val == "أخرى");
                  });
                },
              ),

              if (_isOther) ...[
                const SizedBox(height: 15),
                TextField(
                  controller: _detailsCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: "اكتب تفاصيل الشكوى هنا...", alignLabelWithHint: true),
                ),
              ],

              const SizedBox(height: 30),

              GestureDetector(
                onTap: () async {
                  if (_selectedSubject == null) return;
                  try {
                    String finalTitle = _isOther ? "أخرى" : _selectedSubject!;
                    await ApiService().createComplaint(finalTitle, _detailsCtrl.text);

                    if (!mounted) return;
                    Navigator.pop(context);
                    _showSuccessPopup();
                    setState(() {});
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("فشل الإرسال، حاول لاحقاً")));
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Center(
                    child: Text("إرسال الشكوى الآن",
                        style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
        content: Text("تم إرسال شكواك بنجاح \nسيقوم الفريق بمراجعتها والرد عليك قريباً.",
            textAlign: TextAlign.center, style: GoogleFonts.tajawal()),
      ),
    );
  }
}
