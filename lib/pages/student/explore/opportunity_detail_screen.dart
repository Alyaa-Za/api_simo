import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final dynamic opportunity;
  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  State<OpportunityDetailScreen> createState() => _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  bool _isChecking = false;
  // قائمة لتخزين وحدات التحكم الخاصة بالأسئلة التي تضعها المؤسسة
  final List<TextEditingController> _customControllers = [];

  @override
  void dispose() {
    for (var c in _customControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── 1. فحص حالة الملف ──
  Future<void> _handleApply() async {
    setState(() => _isChecking = true);
    try {
      final res = await ApiService().getProfile();
      final data = res['data'] ?? {};
      bool isComplete = data['is_profile_complete'] ?? false;
      int percentage = int.tryParse(data['completion_percentage']?.toString() ?? '0') ?? 0;

      if (isComplete || percentage >= 100) {
        _showDynamicQuestionsSheet(); // فتح نافذة الأسئلة الضخمة
      } else {
        _showPremiumWarning(percentage);
      }
    } catch (e) {
      _showPremiumMessage("خطأ في الاتصال", "تعذر التحقق من حالة الملف الشخصي.", true);
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  // ── 2. نافذة الأسئلة الضخمة (المطلوب تعديلها فقط) ──
  void _showDynamicQuestionsSheet() {
    // استخراج الأسئلة من بيانات الفرصة
    final dynamic rawQs = widget.opportunity['custom_questions'];
    List<String> questions = [];
    if (rawQs is List) questions = List<String>.from(rawQs);
    else if (rawQs is String && rawQs.isNotEmpty) questions = rawQs.split(',');

    // تجهيز الـ Controllers
    _customControllers.clear();
    for (var i = 0; i < questions.length; i++) {
      _customControllers.add(TextEditingController());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 30,
              left: 30, right: 30, top: 20
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(50)), // حواف ضخمة
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 30),
                const Icon(Icons.assignment_turned_in_rounded, size: 50, color: AppColors.primaryBlue),
                const SizedBox(height: 15),
                Text("متطلبات التقديم", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w900)),
                const Text("يرجى الإجابة على أسئلة المؤسسة لإتمام الطلب", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 30),

                // توليد حقول الأسئلة ديناميكياً بتصميم "ضخم"
                if (questions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text("لا توجد أسئلة إضافية، يمكنك التقديم مباشرة."),
                  )
                else
                  ...List.generate(questions.length, (index) {
                    return _buildLargeQuestionInput(questions[index].trim(), _customControllers[index]);
                  }),

                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: const Text("إلغاء"),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _submitWithAnswers(questions),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                        ),
                        child: const Text("إرسال الطلب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ويدجت حقل السؤال الضخم
  Widget _buildLargeQuestionInput(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
          const SizedBox(height: 10),
          TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "اكتب إجابتك هنا...",
              filled: true, fillColor: const Color(0xFFF8F9FD),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. إرسال الطلب الفعلي ──
  Future<void> _submitWithAnswers(List<String> qs) async {
    String msg = "";
    for (int i = 0; i < qs.length; i++) {
      msg += "${qs[i]}: ${_customControllers[i].text}\n";
    }

    final dynamic rawId = widget.opportunity['id'] ?? widget.opportunity['opportunity_id'];
    final int oppId = int.tryParse(rawId.toString()) ?? 0;

    Navigator.pop(context);
    setState(() => _isChecking = true);
    try {
      await ApiService().applyToOpportunity(oppId, msg, "تم التقديم عبر الجوال");
      _showPremiumMessage("تم بنجاح!", "طلبك قيد المراجعة الآن ✅", false);
    } catch (e) {
      _showPremiumMessage("فشل التقديم", e.toString(), true);
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final opp = widget.opportunity;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        body: Stack(
          children: [
            _buildPremiumHeaderBackground(),
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          _buildHeroCard(opp),
                          const SizedBox(height: 25),
                          _buildInfoCard("تاريخ بدء الدورة", opp['start_date'] ?? "يحدد لاحقاً", Icons.calendar_month, Colors.orange),
                          const SizedBox(height: 15),
                          _buildInfoCard("وصف التدريب", opp['description'] ?? "لا يوجد وصف", Icons.description_outlined, AppColors.primaryBlue),
                          const SizedBox(height: 15),
                          _buildInfoCard("المتطلبات المهارية", opp['required_skills'] ?? opp['skills']?.toString() ?? "غير محددة", Icons.psychology_outlined, Colors.teal),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(alignment: Alignment.bottomCenter, child: _buildApplyButtonWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeaderBackground() => Container(height: MediaQuery.of(context).size.height * 0.35, decoration: const BoxDecoration(gradient: AppColors.splashGradient, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50))));
  Widget _buildTopBar() => Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)), Text("تفاصيل الفرصة", style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]));
  Widget _buildHeroCard(dynamic opp) => Container(width: double.infinity, padding: const EdgeInsets.all(25), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]), child: Column(children: [Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.business_center, size: 40, color: AppColors.primaryBlue)), const SizedBox(height: 15), Text(opp['title'] ?? "", textAlign: TextAlign.center, style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w900)), Text(opp['institution']?['name'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 14))]));
  Widget _buildInfoCard(String title, String desc, IconData icon, Color color) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 10), Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14))]), const SizedBox(height: 10), Text(desc, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.6))]));
  Widget _buildApplyButtonWidget() => Container(padding: const EdgeInsets.all(25), child: ElevatedButton(onPressed: _isChecking ? null : _handleApply, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, minimumSize: const Size(double.infinity, 65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))), child: _isChecking ? const CircularProgressIndicator(color: Colors.white) : Text("إرسال طلب الانضمام", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))));
  void _showPremiumMessage(String title, String msg, bool isError) { showDialog(context: context, builder: (c) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), title: Text(title, textAlign: TextAlign.center), content: Text(msg, textAlign: TextAlign.center), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("موافق"))])); }
  void _showPremiumWarning(int p) { showDialog(context: context, builder: (c) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), title: const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange), content: Text("ملفك غير مكتمل ($p%). أكمل بياناتك أولاً."), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("فهمت"))])); }
}
