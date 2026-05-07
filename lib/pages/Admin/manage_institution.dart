import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';

class ManageInstitutions extends StatefulWidget {
  const ManageInstitutions({super.key});

  @override
  State<ManageInstitutions> createState() => _ManageInstitutionsState();
}

class _ManageInstitutionsState extends State<ManageInstitutions> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isAr = Provider.of<LanguageProvider>(context).locale.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: TabBar(
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: Colors.grey.shade500,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: isAr ? "قيد الانتظار" : "Pending"),
                  Tab(text: isAr ? "المعتمدة" : "Approved"),
                ],
              ),
            ),
          ),
          body: FutureBuilder<List<dynamic>>(
            future: ApiService().getAdminInstitutions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text(isAr ? "حدث خطأ في الاتصال بالسيرفر" : "Server Connection Error"));
              }

              // ── [تأمين الداتا غصب مَسْطرة ملان العين] ──
              final dynamic rawData = snapshot.data;
              final List<dynamic> allList = (rawData is Map && rawData.containsKey('data'))
                  ? (rawData['data'] ?? [])
                  : (rawData is List ? rawData : []);

              // فرز الحالات بناءً على ما يرجعه السيرفر
              final pending = allList.where((i) => i['status'] == 'pending_approval' || i['status'] == 'pending').toList();
              final approved = allList.where((i) => i['status'] == 'active' || i['status'] == 'approved').toList();

              return TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildInstitutionsList(pending, true, isAr, isDark),
                  _buildInstitutionsList(approved, false, isAr, isDark),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInstitutionsList(List<dynamic> list, bool isPending, bool isAr, bool isDark) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center_outlined, size: 60, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 10),
            Text(isAr ? "لا توجد سجلات حالياً" : "No records found", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final inst = list[index];
        final String name = inst['name'] ?? "---";

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    child: const Icon(Icons.business, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(inst['email'] ?? "---", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  if (!isPending)
                    const Icon(Icons.verified_rounded, color: Colors.green, size: 24),
                ],
              ),
              const Divider(height: 30),

              // ── [بيانات بطاقة المؤسسة الضخمة] ──
              _infoRow(isAr ? "جهة الاتصال:" : "Contact:", inst['contact_person'] ?? "---", isDark),
              _infoRow(isAr ? "رقم الجوال:" : "Phone:", inst['contact_phone'] ?? "---", isDark),
              _infoRow(isAr ? "العنوان:" : "Address:", inst['address'] ?? "---", isDark),

              if (isPending) ...[
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // استدعاء دالة الاعتماد الحقيقية من ملفك
                        await ApiService().approveInstitution(inst['institution_id'] ?? inst['id']);
                        _refresh();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isAr ? "تم اعتماد المؤسسة بنجاح ✅" : "Institution approved ✅"), backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: Text(isAr ? "اعتماد الحساب" : "Approve Account", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87))),
        ],
      ),
    );
  }
}
