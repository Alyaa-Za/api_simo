import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isAr = Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder<List<dynamic>>(
          future: ApiService().getAdminRequests(), // استدعاء دالة الأدمن حصراً
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text(isAr ? "فشل جلب البيانات" : "Load Failed"));

            final dynamic rawData = snapshot.data;
            final List<dynamic> list = (rawData is Map && rawData.containsKey('data'))
                ? (rawData['data'] ?? [])
                : (rawData is List ? rawData : []);

            if (list.isEmpty) return Center(child: Text(isAr ? "لا توجد طلبات معلقة" : "No requests"));

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final request = list[index];
                final student = request['student'] ?? {};
                final opp = request['opportunity'] ?? {};

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student['full_name'] ?? "---", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(opp['title'] ?? "---", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const Divider(height: 20),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await ApiService().approveAdminRequest(request['id'] ?? request['request_id']);
                              _refresh();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: Text(isAr ? "اعتماد" : "Approve", style: const TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              await ApiService().rejectAdminRequest(request['id'] ?? request['request_id'], "رفض من الإدارة");
                              _refresh();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            child: Text(isAr ? "رفض" : "Reject", style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                    ],
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
