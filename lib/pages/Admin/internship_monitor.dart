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
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isAr = Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120, pinned: true,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                title: Text(isAr ? "مراقبة التدريب والزيارات" : "Internship Monitor",
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryBlue)),
              ),
              actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue))],
            ),

            FutureBuilder<List<dynamic>>(
              future: ApiService().getAdminInternships(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                }

                final list = snapshot.data ?? [];

                return SliverList(
                  delegate: SliverChildListDelegate([
                    if (list.isNotEmpty) _buildActiveCounter(list.length, isAr, isDark),

                    if (list.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Center(child: Text(isAr ? "لا توجد سجلات حالياً" : "No active logs")),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 150),
                        itemCount: list.length,
                        itemBuilder: (context, index) => _buildMonitorCard(list[index], isAr, isDark),
                      ),
                  ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCounter(int count, bool isAr, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Text(
            isAr ? "$count تدريبات نشطة حالياً" : "$count Active Internships",
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitorCard(dynamic intern, bool isAr, bool isDark) {
    final student = intern['student'] ?? {};
    final inst = intern['institution'] ?? {};
    final String startDate = intern['actual_start_date']?.toString().split(' ')[0] ?? (isAr ? "غير محدد" : "N/A");

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _avatarBox(student['full_name'] ?? "S"),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(student['full_name'] ?? "---", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(isAr ? "سجل متابعة ميداني" : "Field follow-up log", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ])),
              _statusBadge(isAr),
            ],
          ),
          const Divider(height: 35, thickness: 0.1),
          _infoRow(Icons.business_rounded, isAr ? "الجهة:" : "Entity:", inst['name'] ?? "---", isDark),
          const SizedBox(height: 10),
          _infoRow(Icons.event_available_rounded, isAr ? "بدأ في:" : "Started:", startDate, isDark),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openInternshipDetails(intern['internship_id'] ?? intern['id'], isAr, isDark),
              icon: const Icon(Icons.assignment_outlined, size: 16),
              label: Text(isAr ? "عرض سجل المتابعة والمهام" : "View Follow-up Log"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                foregroundColor: AppColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _openInternshipDetails(int id, bool isAr, bool isDark) async {
    showDialog(context: context, builder: (c) => const Center(child: CircularProgressIndicator()));

    try {
      final details = await ApiService().getAdminInternshipDetails(id);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isAr ? "تم جلب السجل بنجاح " : "Log fetched successfully "))
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error fetching details")));
    }
  }

  Widget _avatarBox(String name) => CircleAvatar(radius: 22, backgroundColor: AppColors.primaryBlue.withOpacity(0.1), child: Text(name.substring(0,1), style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)));

  Widget _statusBadge(bool isAr) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(isAr ? "قيد التدريب" : "In Training", style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)));

  Widget _infoRow(IconData i, String l, String v, bool d) => Row(children: [Icon(i, size: 14, color: Colors.grey), const SizedBox(width: 8), Text(l, style: const TextStyle(fontSize: 11, color: Colors.grey)), const SizedBox(width: 5), Expanded(child: Text(v, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: d ? Colors.white70 : Colors.black87)))]);
}
