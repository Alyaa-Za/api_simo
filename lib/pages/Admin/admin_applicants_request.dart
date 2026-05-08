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
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                title: Text(isAr ? "مراجعة طلبات التدريب" : "Applications Review",
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryBlue)),
              ),
              actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue))],
            ),
            FutureBuilder<List<dynamic>>(
              future: ApiService().getAdminRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                }
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return SliverFillRemaining(child: Center(child: Text(isAr ? "لا توجد طلبات حالياً" : "No requests found")));
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 150),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildRequestWebCard(list[index], isAr, isDark),
                      childCount: list.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestWebCard(dynamic req, bool isAr, bool isDark) {
    final student = req['student'] ?? {};
    final opp = req['opportunity'] ?? {};
    final String date = req['submission_date']?.toString().substring(0, 10) ?? "---";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _iconBox(Icons.person_pin_rounded),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(student['full_name'] ?? "---", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("${isAr ? 'الرقم:' : 'ID:'} ${student['student_number'] ?? '---'}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ])),
              _dateBadge(date),
            ],
          ),
          const Divider(height: 30, thickness: 0.2),
          _infoRow(Icons.work_outline_rounded, opp['title'] ?? "---", isDark),
          const SizedBox(height: 8),
          _infoRow(Icons.business_rounded, opp['institution_name'] ?? "---", isDark, isSub: true),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(child: _actionBtn(isAr ? "موافقة" : "Approve", Icons.done_all_rounded, Colors.green, () => _handleDecision(req['request_id'], true, isAr, isDark))),
              const SizedBox(width: 10),
              Expanded(child: _actionBtn(isAr ? "رفض" : "Reject", Icons.close_rounded, Colors.redAccent, () => _handleDecision(req['request_id'], false, isAr, isDark))),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconBox(IconData i) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(i, color: AppColors.primaryBlue, size: 22));

  Widget _dateBadge(String d) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(d, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)));

  Widget _infoRow(IconData i, String t, bool d, {bool isSub = false}) => Row(children: [Icon(i, size: 14, color: Colors.grey), const SizedBox(width: 8), Expanded(child: Text(t, style: TextStyle(fontSize: isSub ? 11 : 13, fontWeight: isSub ? FontWeight.normal : FontWeight.w600, color: d ? Colors.white70 : Colors.black87)))]);

  Widget _actionBtn(String l, IconData i, Color c, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withValues(alpha: 0.2))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 16, color: c), const SizedBox(width: 8), Text(l, style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.bold))])));

  void _handleDecision(int id, bool approve, bool ar, bool dark) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => Directionality(textDirection: ar ? TextDirection.rtl : TextDirection.ltr, child: AlertDialog(backgroundColor: dark ? const Color(0xFF1E293B) : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Text(ar ? (approve ? "تأكيد الموافقة" : "سبب الرفض") : "Confirm"), content: TextField(controller: ctrl, maxLines: 3, decoration: InputDecoration(hintText: ar ? "اكتب ملاحظاتك..." : "Notes...", filled: true, fillColor: dark ? Colors.black26 : Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ar ? "إلغاء" : "Cancel")), ElevatedButton(onPressed: () async { if (!approve && ctrl.text.isEmpty) return; if (approve) { await ApiService().approveAdminRequest(id, notes: ctrl.text); } else { await ApiService().rejectAdminRequest(id, ctrl.text); } Navigator.pop(ctx); _refresh(); }, style: ElevatedButton.styleFrom(backgroundColor: approve ? Colors.green : Colors.redAccent), child: Text(ar ? "تأكيد" : "Confirm"))])));
  }
}
