import 'package:flutter/material.dart';
import '../../../core/ui/app_color.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final bool isProfileComplete = false; // ستأتي من الـ API لاحقاً

  const OpportunityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل الفرصة"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanyHeader(),
                  const SizedBox(height: 25),
                  _sectionTitle("وصف التدريب"),
                  const Text("تدريب مكثف على تقنيات Flutter و Firebase لبناء تطبيقات متكاملة..."),
                  const SizedBox(height: 20),
                  _sectionTitle("المتطلبات"),
                  const Text("• معرفة بأساسيات Dart\n• مهارات في تصميم UI/UX\n• الالتزام بالوقت"),
                ],
              ),
            ),
          ),
          _buildApplyButton(context),
        ],
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(15)),
          child: const Icon(Icons.business, size: 40, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 15),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("مطور تطبيقات", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("شركة الحلول البرمجية", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isProfileComplete ? AppColors.primaryBlue : Colors.grey,
            padding: const EdgeInsets.all(18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: isProfileComplete
              ? () => _showSuccessDialog(context)
              : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يجب إكمال بياناتك بنسبة 100% أولاً"))),
          child: Text(isProfileComplete ? "تقديم الآن" : "التقديم مغلق (أكمل ملفك)"),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(context: context, builder: (c) => const AlertDialog(title: Text("تم التقديم بنجاح")));
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
  );
}
