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

  // ── 1. فحص حالة الملف قبل التقديم ──
  Future<void> _handleApply() async {
    setState(() => _isChecking = true);
    try {
      final res = await ApiService().getProfile();
      final data = res['data'] ?? {};
      bool isComplete = data['is_profile_complete'] ?? false;
      int percentage = int.tryParse(data['completion_percentage']?.toString() ?? '0') ?? 0;

      if (isComplete || percentage >= 100) {
        _showFancyConfirmSheet(); // فتح نافذة التأكيد الفخمة
      } else {
        _showPremiumWarning(percentage);
      }
    } catch (e) {
      _showPremiumMessage("خطأ في الاتصال", "تعذر التحقق من حالة الملف الشخصي حالياً.", true);
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  // ── 2. نافذة التأكيد المنبثقة (تصميم ملكي) ──
  void _showFancyConfirmSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              const Icon(Icons.verified_user_outlined, size: 60, color: AppColors.primaryBlue),
              const SizedBox(height: 20),
              Text("تأكيد إرسال الطلب", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("عند التأكيد، سيتم إرسال ملفك الأكاديمي لمراجعة الإدارة والمؤسسة.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, height: 1.5)),
              const SizedBox(height: 35),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Text("تراجع"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitApplication,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Text("تأكيد التقديم", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3. إرسال الطلب الفعلي (إصلاح خطأ الـ Null) ──
  Future<void> _submitApplication() async {
    // حل مشكلة الـ ID عبر فحص كل الاحتمالات الممكنة للمسمى
    final dynamic rawId = widget.opportunity['id'] ?? widget.opportunity['opportunity_id'];
    final int oppId = int.tryParse(rawId.toString()) ?? 0;

    Navigator.pop(context); // إغلاق الـ BottomSheet

    if (oppId == 0) {
      _showPremiumMessage("خطأ فني", "لم يتم العثور على معرف الفرصة (ID NULL)", true);
      return;
    }

    setState(() => _isChecking = true);
    try {
      // إرسال الطلب للباك أند
      await ApiService().applyToOpportunity(oppId, "أرغب في الانضمام للتدريب الميداني", "تم التقديم عبر التطبيق");

      _showPremiumMessage("تم بنجاح!", "تم إرسال طلبك للأدمن. يمكنك متابعة الحالة من الداش بورد ✅", false);
    } catch (e) {
      _showPremiumMessage("فشل التقديم", e.toString().replaceAll("Exception: ", ""), true);
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
                          _buildInfoCard("المتطلبات", opp['skills']?.toString() ?? "غير محددة", Icons.psychology_outlined, Colors.teal),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(alignment: Alignment.bottomCenter, child: _buildApplyButton()),
          ],
        ),
      ),
    );
  }

  // ── عناصر التصميم الفخمة ──
  Widget _buildPremiumHeaderBackground() => Container(
    height: MediaQuery.of(context).size.height * 0.35,
    decoration: const BoxDecoration(
      gradient: AppColors.splashGradient,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
    ),
  );

  Widget _buildTopBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Row(children: [
      IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
      Text("تفاصيل الفرصة", style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
    ]),
  );

  Widget _buildHeroCard(dynamic opp) => Container(
    width: double.infinity, padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
    child: Column(children: [
      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.business_center, size: 40, color: AppColors.primaryBlue)),
      const SizedBox(height: 15),
      Text(opp['title'] ?? "", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.w900)),
      Text(opp['institution']?['name'] ?? "", style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.location_on, size: 16, color: Colors.redAccent), Text(" ${opp['city'] ?? ''}")])
    ]),
  );

  Widget _buildInfoCard(String t, String c, IconData i, Color col) => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.shade50)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(i, color: col, size: 18), const SizedBox(width: 10), Text(t, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15))]),
      const SizedBox(height: 10),
      Text(c, style: const TextStyle(height: 1.6, color: Colors.black87)),
    ]),
  );

  Widget _buildApplyButton() => Container(
    padding: const EdgeInsets.all(25),
    child: Container(
      width: double.infinity, height: 65,
      decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        onPressed: _isChecking ? null : _handleApply,
        child: _isChecking ? const CircularProgressIndicator(color: Colors.white) : Text("إرسال طلب الانضمام ✨", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    ),
  );

  void _showPremiumMessage(String title, String msg, bool isError) {
    showDialog(
      context: context,
      builder: (c) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isError ? Icons.error_rounded : Icons.check_circle, size: 60, color: isError ? Colors.red : Colors.green),
              const SizedBox(height: 20),
              Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(c), child: const Text("موافق"))),
            ],
          ),
        ),
      ),
    );
  }

  void _showPremiumWarning(int per) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 60, color: Colors.orange),
            const SizedBox(height: 20),
            Text("ملفك غير مكتمل ($per%)", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
            const Text("أكمل بيانات ملفك الشخصي لتتمكن من التقديم.", textAlign: TextAlign.center),
            const SizedBox(height: 25),
            ElevatedButton(onPressed: () => Navigator.pop(c), child: const Text("حسناً")),
          ],
        ),
      ),
    );
  }
}
