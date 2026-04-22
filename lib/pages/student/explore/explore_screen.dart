import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<dynamic> _allOpportunities = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = true;

  String _searchQuery = "";
  String _selectedCity = "الكل";
  String _selectedType = "الكل";

  @override
  void initState() {
    super.initState();
    _fetchOpportunities();
  }

  Future<void> _fetchOpportunities() async {
    try {
      final data = await ApiService().getOpportunities();
      if (mounted) {
        setState(() {
          _allOpportunities = data;
          _filteredData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog("فشل جلب البيانات: ${e.toString()}");
      }
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredData = _allOpportunities.where((item) {
        final title = (item['title'] ?? "").toString().toLowerCase();
        final dept = (item['department'] ?? "").toString().toLowerCase();
        final query = _searchQuery.toLowerCase();

        final matchesSearch = title.contains(query) || dept.contains(query);
        final matchesCity = _selectedCity == "الكل" || item['city'] == _selectedCity;
        final matchesType = _selectedType == "الكل" || item['training_type'] == _selectedType;

        return matchesSearch && matchesCity && matchesType;
      }).toList();
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 15),
                  Text("تصفية النتائج", style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildFilterTile("المدينة", ["الكل", "صنعاء", "عدن", "تعز", "حضرموت"], _selectedCity, (val) {
                            setModalState(() => _selectedCity = val);
                            _applyFilter();
                          }),
                          const Divider(),
                          _buildFilterTile("نوع التدريب", ["الكل", "summer", "cooperative"], _selectedType, (val) {
                            setModalState(() => _selectedType = val);
                            _applyFilter();
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text("استمرار", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterTile(String title, List<String> options, String currentVal, Function(String) onSelect) {
    return ExpansionTile(
      title: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 15)),
      leading: const Icon(Icons.tune_rounded, color: AppColors.primaryBlue, size: 20),
      children: options.map((opt) => ListTile(
        title: Text(opt == 'summer' ? "صيفي" : opt == 'cooperative' ? "تعاوني" : opt, style: GoogleFonts.tajawal(fontSize: 14)),
        trailing: currentVal == opt ? const Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 18) : null,
        onTap: () => onSelect(opt),
      )).toList(),
    );
  }

  void _showOpportunityDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 30, backgroundColor: AppColors.primaryBlue.withOpacity(0.1), child: const Icon(Icons.business_rounded, color: AppColors.primaryBlue, size: 30)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title'] ?? "", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(item['department'] ?? "قسم عام", style: GoogleFonts.tajawal(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildDetailInfoRow(Icons.location_on_rounded, "الموقع", item['city'] ?? "غير محدد"),
                    _buildDetailInfoRow(Icons.category_rounded, "النوع", item['training_type'] == 'summer' ? "صيفي" : "تعاوني"),
                    _buildDetailInfoRow(Icons.event_note_rounded, "الموعد", item['start_date'] ?? "يحدد لاحقاً"),
                    const Divider(height: 40),
                    Text("الوصف والمتطلبات", style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(item['description'] ?? "لا يوجد وصف متوفر.", style: GoogleFonts.tajawal(color: Colors.grey[700], height: 1.6)),
                    const SizedBox(height: 15),
                    Text("المهارات:", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
                    Text(item['required_skills'] ?? "غير محددة"),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleApply(item['opportunity_id']),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: const EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: const Text("تقديم الآن", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleApply(dynamic id) async {
    try {
      await ApiService().applyToOpportunity(int.parse(id.toString()), "بدون إجابات", "مهتم بالتقديم");
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم التقديم بنجاح! ✅"), backgroundColor: Colors.green));
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Column(
        children: [
          _buildSearchAndFilterHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredData.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _filteredData.length,
              itemBuilder: (context, index) => _buildOpportunityCard(_filteredData[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _applyFilter();
              },
              decoration: InputDecoration(
                hintText: "ابحث عن فرصة...",
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue, size: 20),
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _showFilterOptions,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: ListTile(
        onTap: () => _showOpportunityDetails(item),
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(backgroundColor: AppColors.primaryBlue.withOpacity(0.1), child: const Icon(Icons.business_center_rounded, color: AppColors.primaryBlue)),
        title: Text(item['title'] ?? "", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text("${item['city'] ?? ''} | ${item['department'] ?? ''}", style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildDetailInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [Icon(icon, size: 18, color: Colors.grey), const SizedBox(width: 10), Text("$label: $value", style: GoogleFonts.tajawal())]),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off_rounded, size: 50, color: Colors.grey),
        Text("لا توجد فرص مطابقة", style: GoogleFonts.tajawal(color: Colors.grey)),
      ],
    ));
  }

  void _showErrorDialog(String message) {
    showDialog(context: context, builder: (c) => AlertDialog(title: const Text(" تنبيه ⭕️"), content: Text(message)));
  }
}
