import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("سياسة الخصوصية"), centerTitle: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Icon(Icons.verified_user_outlined, size: 80, color: AppColors.primaryBlue),
              const SizedBox(height: 30),
              Text("التزامنا بخصوصيتكم", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(
                "نحن في Trainex ندرك تماماً أهمية البيانات الخاصة بمؤسستكم. جميع المعلومات المتعلقة بالفرص التدريبية، تقييمات الطلاب، والبيانات الشخصية يتم التعامل معها بأعلى معايير التشفير والأمان. لا يتم مشاركة بياناتكم مع أي جهات خارجية، ويهدف النظام فقط لربط المؤسسة بالجامعة لضمان جودة العملية التدريبية.",
                textAlign: TextAlign.justify,
                style: GoogleFonts.tajawal(fontSize: 15, height: 2.0, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              const Text("آخر تحديث: أبريل 2026", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
