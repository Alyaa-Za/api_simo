import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final dynamic opportunity;
  // هذا المتغير يجب أن يأتي من الباك أند، سنفترض هنا قيمته للتجربة
  final bool isProfileComplete = false;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // الهيدر المتدرج الفخم
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: const BoxDecoration(
                gradient: AppColors.splashGradient,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          _buildMainInfoCard(opportunity),
                          const SizedBox(height: 25),

                          // إضافة تاريخ بدء الدورة هنا
                          _buildDetailCard("موعد بدء التدريب", opportunity['start_date'] ?? "يحدد لاحقاً", Icons.calendar_month_outlined),
                          const SizedBox(height: 15),

                          _buildDetailCard("وصف التدريب", opportunity['description'] ?? "لا يوجد وصف", Icons.description_outlined),
                          const SizedBox(height: 15),

                          _buildDetailCard("المهارات المطلوبة", opportunity['skills'] ?? "غير محددة", Icons.psychology_outlined),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // زر التقديم الفخم
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildApplyButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
          Text("تفاصيل الفرصة", style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard(dynamic opp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.business_center_rounded, size: 40, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 15),
          Text(opp['title'] ?? "", style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.w900)),
          Text(opp['institution']?['name'] ?? "", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(height: 1.6, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            shadowColor: AppColors.primaryBlue.withOpacity(0.4),
          ),
          onPressed: () {
            if (isProfileComplete) {
              _showSuccessDialog(context);
            } else {
              _showWarningDialog(context); // تفعيل الـ Warning
            }
          },
          child: const Text("تقديم الآن ✨", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 70),
              const SizedBox(height: 20),
              Text("ملفك غير مكتمل!", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              const Text("يجب إكمال بيانات ملفك الشخصي وصورتك بنسبة 100% لتتمكن من التقديم على هذه الفرصة.", textAlign: TextAlign.center),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(c),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: StadiumBorder()),
                child: const Text("فهمت، سأكمله الآن", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(context: context, builder: (c) => const AlertDialog(title: Text("تم التقديم بنجاح ✅")));
  }
}
