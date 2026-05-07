import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';

class InternshipMonitor extends StatefulWidget {
  const InternshipMonitor({super.key});

  @override
  State<InternshipMonitor> createState() => _InternshipMonitorState();
}

class _InternshipMonitorState extends State<InternshipMonitor> {
  @override
  Widget build(BuildContext context) {
    final isAr = Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder<List<dynamic>>(
          future: ApiService().getAdminInternships(), // استدعاء دالة الأدمن حصراً
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

            final dynamic rawData = snapshot.data;
            final List<dynamic> list = (rawData is Map && rawData.containsKey('data'))
                ? (rawData['data'] ?? [])
                : (rawData is List ? rawData : []);

            if (list.isEmpty) return Center(child: Text(isAr ? "لا يوجد تدريب نشط حالياً" : "No active internships"));

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final intern = list[index];
                return Card(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.monitor_heart_outlined, color: AppColors.primaryBlue),
                    title: Text(intern['student']?['full_name'] ?? "---", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(intern['opportunity']?['title'] ?? ""),
                    trailing: Text(intern['status'] ?? "", style: const TextStyle(color: Colors.green, fontSize: 11)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
