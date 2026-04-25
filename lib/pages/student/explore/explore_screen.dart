import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import 'opportunity_detail_screen.dart';

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

  // جلب البيانات من الـ API
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // منطق الفلترة الموحد
  void _applyFilter() {
    setState(() {
      _filteredData = _allOpportunities.where((item) {
        final title = (item['title'] ?? "").toString().toLowerCase();
        final matchesSearch = title.contains(_searchQuery.toLowerCase());
        final matchesCity = _selectedCity == "الكل" || item['city'] == _selectedCity;
        final matchesType = _selectedType == "الكل" || item['training_type'] == _selectedType;

        return matchesSearch && matchesCity && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: Column(
          children: [
            // ── الهيدر الفخم مع حقل البحث وزر الفلترة ──
            _buildPremiumHeader(),

            // ── قائمة الفرص بالكروت العائمة ──
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredData.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: _filteredData.length,
                itemBuilder: (context, index) => _buildOpportunityCard(_filteredData[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("استكشف الفرص", style: GoogleFonts.tajawal(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("ابحث عن مسارك المهني القادم ✨", style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: TextField(
                    onChanged: (v) {
                      _searchQuery = v;
                      _applyFilter();
                    },
                    decoration: const InputDecoration(
                      hintText: "بحث عن مسمى فرصة...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search_rounded, color: AppColors.primaryBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // زر الفلترة المعتمد
              GestureDetector(
                onTap: _showFilterOptions,
                child: Container(
                  height: 55, width: 55,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.tune_rounded, color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(dynamic opp) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => OpportunityDetailScreen(opportunity: opp))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.business_center_rounded, color: AppColors.primaryBlue, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opp['title'] ?? "", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(opp['institution']?['name'] ?? "المؤسسة", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _cardTag(opp['city'] ?? "غير محدد", Icons.location_on_outlined, Colors.redAccent),
                      const SizedBox(width: 8),
                      _cardTag(opp['training_type'] == 'summer' ? "صيفي" : "تعاوني", Icons.history_edu_outlined, Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _cardTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 20),
                  Text("تصفية النتائج", style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  _buildFilterSection("المدينة", ["الكل", "صنعاء", "عدن", "تعز", "حضرموت"], _selectedCity, (val) {
                    setModalState(() => _selectedCity = val);
                    _applyFilter();
                  }),
                  const SizedBox(height: 25),
                  _buildFilterSection("نوع التدريب", ["الكل", "summer", "cooperative"], _selectedType, (val) {
                    setModalState(() => _selectedType = val);
                    _applyFilter();
                  }),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
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

  Widget _buildFilterSection(String title, List<String> options, String current, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: options.map((opt) {
            bool isSelected = current == opt;
            String label = opt == 'summer' ? "صيفي" : opt == 'cooperative' ? "تعاوني" : opt;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (s) => onSelect(opt),
              selectedColor: AppColors.primaryBlue.withOpacity(0.2),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300), const SizedBox(height: 15), Text("لا توجد نتائج مطابقة لبحثك", style: GoogleFonts.tajawal(color: Colors.grey))]));
  }
}
