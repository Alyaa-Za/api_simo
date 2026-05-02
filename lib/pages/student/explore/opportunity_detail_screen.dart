import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final dynamic opportunity;
  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  State<OpportunityDetailScreen> createState() => _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  bool _isChecking = false;
  final List<TextEditingController> _customControllers = [];

  @override
  void dispose() {
    for (var c in _customControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleApply(bool isAr) async {
    setState(() => _isChecking = true);
    try {
      final res = await ApiService().getProfile();
      final data = res['data'] ?? {};
      bool isComplete = data['is_profile_complete'] ?? false;
      int percentage = int.tryParse(data['completion_percentage']?.toString() ?? '0') ?? 0;

      if (isComplete || percentage >= 100) {
        _showDynamicQuestionsSheet(isAr);
      } else {
        _showPremiumWarning(percentage, isAr);
      }
    } catch (e) {
      _showSweetMessage(
          title: isAr ? "خطأ في الاتصال" : "Connection Error",
          msg: isAr ? "تعذر التحقق من حالة الملف الشخصي." : "Could not verify profile status.",
          isError: true
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _showDynamicQuestionsSheet(bool isAr) {
    final dynamic rawQs = widget.opportunity['custom_questions'];
    List<String> questions = [];
    if (rawQs is List) {
      questions = List<String>.from(rawQs);
    } else if (rawQs is String && rawQs.isNotEmpty) questions = rawQs.split(',');

    _customControllers.clear();
    for (var i = 0; i < questions.length; i++) {
      _customControllers.add(TextEditingController());
    }

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 30,
              left: 30, right: 30, top: 20
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 30),
                const Icon(Icons.assignment_turned_in_rounded, size: 50, color: AppColors.primaryBlue),
                const SizedBox(height: 15),
                Text(isAr ? "متطلبات التقديم" : "Application Requirements", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w900)),
                Text(isAr ? "يرجى الإجابة على أسئلة المؤسسة لإتمام الطلب" : "Please answer the questions to complete your request", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 30),

                if (questions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(isAr ? "لا توجد أسئلة إضافية، يمكنك التقديم مباشرة." : "No extra questions, you can apply directly."),
                  )
                else
                  ...List.generate(questions.length, (index) {
                    return _buildLargeQuestionInput(questions[index].trim(), _customControllers[index], isAr, isDark);
                  }),

                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: Text(isAr ? "إلغاء" : "Cancel"),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _submitWithAnswers(questions, isAr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: Text(isAr ? "إرسال الطلب" : "Submit Request", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildLargeQuestionInput(String label, TextEditingController ctrl, bool isAr, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : AppColors.textDark)),
          const SizedBox(height: 10),
          TextField(
            controller: ctrl,
            maxLines: 3,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: isAr ? "اكتب إجابتك هنا..." : "Type your answer here...",
              filled: true,
              fillColor: isDark ? Colors.black12 : const Color(0xFFF8F9FD),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitWithAnswers(List<String> qs, bool isAr) async {
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
      _showSweetMessage(
          title: isAr ? "تم بنجاح!" : "Applied Successfully!",
          msg: isAr ? "طلبك قيد المراجعة الآن " : "Your request is under review ✅",
          isError: false
      );
    } catch (e) {
      _showSweetMessage(
          title: isAr ? "فشل التقديم" : "Application Failed",
          msg: e.toString(),
          isError: true
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _showSweetMessage({required String title, required String msg, required bool isError}) {
    showDialog(
      context: context,
      builder: (c) => Directionality(
        textDirection: Provider.of<LanguageProvider>(context, listen: false).locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Theme.of(context).cardColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              CircleAvatar(
                radius: 35,
                backgroundColor: isError ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                child: Icon(isError ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded, color: isError ? Colors.redAccent : Colors.green, size: 40),
              ),
              const SizedBox(height: 25),
              Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 12),
              Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(c),
                  style: ElevatedButton.styleFrom(backgroundColor: isError ? Colors.redAccent : AppColors.primaryBlue, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text("موافق", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPremiumWarning(int p, bool isAr) {
    showDialog(
      context: context,
      builder: (c) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Theme.of(context).cardColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              const Icon(Icons.info_outline_rounded, size: 60, color: Colors.orange),
              const SizedBox(height: 20),
              Text(isAr ? "ملف غير مكتمل" : "Incomplete Profile", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 12),
              Text(
                isAr ? "ملفك الشخصي غير مكتمل ($p%). يجب إكمال البيانات الأكاديمية أولاً لتتمكن من التقديم."
                    : "Your profile is incomplete ($p%). Please complete your academic data to apply.",
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(c),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: const StadiumBorder()),
                child: Text(isAr ? "فهمت" : "Got it", style: const TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final opp = widget.opportunity;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            _buildHeaderBg(),
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  _buildTopBar(isAr),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          _buildHeroCard(opp, isDark),
                          const SizedBox(height: 20),
                          _buildInfoCard(isAr ? "تاريخ البدء" : "Start Date", opp['start_date'] ?? (isAr ? "غير محدد" : "N/A"), Icons.calendar_today, Colors.orange, isDark),
                          const SizedBox(height: 15),
                          _buildInfoCard(isAr ? "الوصف" : "Description", opp['description'] ?? (isAr ? "لا يوجد وصف" : "No desc"), Icons.description, AppColors.primaryBlue, isDark),
                          const SizedBox(height: 15),
                          _buildInfoCard(isAr ? "المتطلبات" : "Requirements", opp['required_skills'] ?? (isAr ? "غير محددة" : "N/A"), Icons.psychology, Colors.teal, isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(alignment: Alignment.bottomCenter, child: _buildApplyBtn(isAr)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBg() => Container(height: 250, decoration: const BoxDecoration(gradient: AppColors.splashGradient, borderRadius: BorderRadius.vertical(bottom: Radius.circular(50))));

  Widget _buildTopBar(bool isAr) => Row(children: [
    IconButton(icon: Icon(isAr ? Icons.arrow_back_ios : Icons.arrow_forward_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
    Text(isAr ? "تفاصيل الفرصة" : "Opportunity Details", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold))
  ]);

  Widget _buildHeroCard(dynamic opp, bool isDark) => Container(
    width: double.infinity, padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 20)]
    ),
    child: Column(children: [
      const Icon(Icons.business_center, size: 40, color: AppColors.primaryBlue),
      const SizedBox(height: 15),
      Text(opp['title'] ?? "", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : AppColors.textDark)),
      Text(opp['institution']?['name'] ?? "", style: const TextStyle(color: Colors.grey))
    ]),
  );

  Widget _buildInfoCard(String t, String d, IconData i, Color c, bool isDark) => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: isDark ? Border.all(color: Colors.white10) : null,
    ),
    child: Row(children: [
      Icon(i, color: c),
      const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(d, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87))
      ]))
    ]),
  );

  Widget _buildApplyBtn(bool isAr) => Container(
      padding: const EdgeInsets.all(25),
      child: ElevatedButton(
          onPressed: _isChecking ? null : () => _handleApply(isAr),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          child: _isChecking ? const CircularProgressIndicator(color: Colors.white) : Text(isAr ? "إرسال طلب التقديم" : "Submit Application", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
      )
  );
}
