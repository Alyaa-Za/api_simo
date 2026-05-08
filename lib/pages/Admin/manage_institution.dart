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
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _allInstitutions = [];
  List<dynamic> _filteredInstitutions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService().getAdminInstitutions();
      setState(() {
        _allInstitutions = data;
        _filteredInstitutions = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredInstitutions = _allInstitutions.where((inst) {
        final name = (inst['name'] ?? "").toString().toLowerCase();
        final email = (inst['email'] ?? "").toString().toLowerCase();
        return name.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _refresh() {
    _searchCtrl.clear();
    setState(() => _isLoading = true);
    _loadData();
  }

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
                title: Text(isAr ? "إدارة الجهات التدريبية" : "Institutions Management",
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryBlue)),
              ),
              actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue))],
            ),

            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: isAr ? "ابحث باسم الجهة أو البريد..." : "Search by name or email...",
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    border: InputBorder.none,
                    icon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchCtrl.clear();
                        _onSearchChanged('');
                      },
                    )
                        : null,
                  ),
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_filteredInstitutions.isEmpty)
              SliverFillRemaining(child: Center(child: Text(isAr ? "لا توجد نتائج" : "No results found")))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 150),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildInstitutionCard(_filteredInstitutions[index], isAr, isDark),
                    childCount: _filteredInstitutions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstitutionCard(dynamic inst, bool isAr, bool isDark) {
    final String name = inst['name'] ?? "---";
    final String responsible = inst['contact_person'] ?? "---";
    final String city = inst['address'] ?? "---";
    final bool isActive = inst['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 45, width: 45,
                decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.business_center_rounded, color: AppColors.primaryBlue, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                Text(inst['email'] ?? "", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ])),
              _statusBadge(isActive, isAr),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(thickness: 0.2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniDetail(isAr ? "المسؤول" : "Responsible", responsible, isDark),
              _miniDetail(isAr ? "المدينة" : "City", city, isDark),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (!isActive)
                Expanded(child: _actionBtn(isAr ? "اعتماد" : "Approve", Icons.check_circle_outline, Colors.green, () async {
                  await ApiService().approveInstitution(inst['institution_id'] ?? inst['id']);
                  _refresh();
                })),
              if (!isActive) const SizedBox(width: 10),
              Expanded(child: _actionBtn(isAr ? "عرض التفاصيل" : "View Details", Icons.visibility_outlined, AppColors.primaryBlue, () => _showFullDetails(inst, isAr, isDark))),
            ],
          )
        ],
      ),
    );
  }

  Widget _statusBadge(bool active, bool isAr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: active ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(isAr ? (active ? "نشطة" : "معلقة") : (active ? "Active" : "Pending"), style: TextStyle(color: active ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _miniDetail(String label, String value, bool d) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)), Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: d ? Colors.white70 : Colors.black54))]);

  Widget _actionBtn(String label, IconData icon, Color col, VoidCallback onTap) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: col.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: col), const SizedBox(width: 8), Text(label, style: TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.bold))]),
    ),
  );

  void _showFullDetails(dynamic inst, bool isAr, bool isDark) {
    final bool isActive = inst['status'] == 'active';
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      pageBuilder: (ctx, anim1, anim2) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
                decoration: const BoxDecoration(gradient: AppColors.splashGradient, borderRadius: BorderRadius.vertical(bottom: Radius.circular(35))),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const SizedBox(width: 30), Container(height: 90, width: 90, decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: const Icon(Icons.business_rounded, color: Colors.white, size: 45)), IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28))]),
                    const SizedBox(height: 15),
                    Text(inst['name'] ?? "", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 5),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: Text(isAr ? (isActive ? "نشطة" : "معلقة") : (isActive ? "Active" : "Pending"), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Row(children: [_buildWebInfoBox(isAr ? "الموظف المسؤول" : "Contact Person", inst['contact_person'], Icons.person_outline, isDark, isAr), const SizedBox(width: 15), _buildWebInfoBox(isAr ? "رقم التواصل" : "Phone Number", inst['contact_phone'], Icons.phone_android_rounded, isDark, isAr)]),
                      const SizedBox(height: 15),
                      Row(children: [_buildWebInfoBox(isAr ? "البريد الإلكتروني" : "Email", inst['email'], Icons.alternate_email_rounded, isDark, isAr), const SizedBox(width: 15), _buildWebInfoBox(isAr ? "الموقع الإلكتروني" : "Website", inst['website'], Icons.language_rounded, isDark, isAr)]),
                      const SizedBox(height: 25),
                      _buildAboutBox(isAr ? "عن المؤسسة" : "About Institution", inst['description'], isDark, isAr),
                      const SizedBox(height: 40),
                      SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(onPressed: () async {
                        final String newStatus = isActive ? 'suspended' : 'active';
                        await ApiService().changeInstitutionStatus(inst['institution_id'] ?? inst['id'], newStatus);
                        Navigator.pop(ctx); _refresh();
                      }, icon: Icon(isActive ? Icons.person_off_rounded : Icons.person_add_alt_1_rounded, color: Colors.white), label: Text(isAr ? (isActive ? "إيقاف حساب المؤسسة" : "تفعيل الحساب") : (isActive ? "Deactivate" : "Activate"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: isActive ? Colors.redAccent : Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebInfoBox(
      String label,
      dynamic value,
      IconData icon,
      bool d, bool ar) => Expanded(
      child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: d ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(15)),
          child: Column(crossAxisAlignment: ar ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [Row(mainAxisAlignment: ar ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [if (!ar) Icon(icon,
                      size: 16,
                      color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
    Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)), if (ar) ...[const SizedBox(width: 8), Icon(icon, size: 16, color: AppColors.primaryBlue)]]), const SizedBox(height: 8), Text(value?.toString() ?? "---", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: d ? Colors.white : Colors.black87), textAlign: ar ? TextAlign.right : TextAlign.left)])));
  Widget _buildAboutBox(String label, dynamic desc, bool d, bool ar) => Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: d ? Colors.white.withOpacity(0.05) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))), child: Column(crossAxisAlignment: ar ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text(desc?.toString() ?? (ar ? "لا يوجد وصف متاح" : "No description"), style: TextStyle(fontSize: 13, height: 1.5, color: d ? Colors.white70 : Colors.black54), textAlign: ar ? TextAlign.right : TextAlign.left)]));
}
