import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
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
    bool isActive = _currentStatus == 'active';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),

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
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ) : null,

      body: Column(
        children: [
          if (!isActive) _buildWarningBar(),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: ApiService().getInstitutionOpportunities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = snapshot.data ?? [];

                if (list.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                    itemCount: list.length,
                    itemBuilder: (context, index) => _opportunityCard(list[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBar() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "حسابك قيد المراجعة، سيتم تفعيل ميزة إضافة الفرص فور اعتماد بيانات مؤسستك",
              style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.w600,
                  height: 1.4
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _opportunityCard(dynamic opp) {
    bool isOppActive = opp['status'] == 'active';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(opp['title'] ?? "",
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
              "${opp['city'] ?? 'غير محدد'} • ${opp['training_type'] == 'summer' ? 'تدريب صيفي' : 'تدريب تعاوني'}",
              style: const TextStyle(fontSize: 12, color: Colors.grey)
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${opp['available_seats']} مقعد",
                style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Icon(Icons.circle, size: 10, color: isOppActive ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text("لا توجد فرص منشورة حالياً",
              style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }
}
