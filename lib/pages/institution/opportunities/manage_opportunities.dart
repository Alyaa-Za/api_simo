import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';
import 'add_opportunity_screen.dart';

class ManageOpportunities extends StatefulWidget {
  final String accountStatus;
  const ManageOpportunities({super.key, required this.accountStatus});

  @override
  State<ManageOpportunities> createState() => _ManageOpportunitiesState();
}

class _ManageOpportunitiesState extends State<ManageOpportunities> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.accountStatus;
    _checkRealStatus();
  }

  Future<void> _checkRealStatus() async {
    try {
      final res = await ApiService().getInstitutionProfile();
      if (mounted) {
        setState(() => _currentStatus = res['data']['status'] ?? 'pending_approval');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isActive = _currentStatus == 'active';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        floatingActionButton: isActive ? Padding(
          padding: const EdgeInsets.only(bottom: 85.0),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const AddOpportunityScreen())
              ).then((_) => setState(() {}));
            },
            backgroundColor: AppColors.primaryBlue,
            elevation: 8,
            child: const Icon(Icons.add_rounded, size: 30, color: Colors.white),
          ),
        ) : null,

        body: Column(
          children: [
            if (!isActive) _buildWarningBar(isAr, isDark),

            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: ApiService().getInstitutionOpportunities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final list = snapshot.data ?? [];

                  if (list.isEmpty) {
                    return _buildEmptyState(isAr, isDark);
                  }

                  return RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                      physics: const BouncingScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) => _opportunityCard(list[index], isDark, isAr),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBar(bool isAr, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isAr
                  ? "حسابك قيد المراجعة، سيتم تفعيل ميزة إضافة الفرص فور اعتماد بيانات مؤسستك."
                  : "Your account is under review. Posting opportunities will be enabled once verified.",
              style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                  fontWeight: FontWeight.w600,
                  height: 1.4
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _opportunityCard(dynamic opp, bool isDark, bool isAr) {
    bool isOppActive = opp['status'] == 'active';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: Text(opp['title'] ?? "",
            style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : AppColors.textDark
            )),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
              "${opp['city'] ?? (isAr ? 'غير محدد' : 'N/A')} • ${opp['training_type'] == 'summer' ? (isAr ? 'تدريب صيفي' : 'Summer') : (isAr ? 'تدريب تعاوني' : 'Coop')}",
              style: const TextStyle(fontSize: 12, color: Colors.grey)
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("${opp['available_seats']} ${isAr ? 'مقعد' : 'Seats'}",
                style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOppActive ? (isAr ? "نشط" : "Active") : (isAr ? "مغلق" : "Closed"),
                  style: TextStyle(fontSize: 10, color: isOppActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Icon(Icons.circle, size: 8, color: isOppActive ? Colors.green : Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isAr, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 70, color: isDark ? Colors.white10 : Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(isAr ? "لا توجد فرص منشورة حالياً" : "No opportunities posted yet",
              style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }
}
