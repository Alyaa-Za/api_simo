import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';
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

  void _applyFilter() {
    setState(() {
      _filteredData = _allOpportunities.where((item) {
        final title = (item['title'] ?? "").toString().toLowerCase();
        final matchesSearch = title.contains(_searchQuery.toLowerCase());
        final matchesCity = _selectedCity == "الكل" || _selectedCity == "All" || item['city'] == _selectedCity;
        final matchesType = _selectedType == "الكل" || _selectedType == "All" || item['training_type'] == _selectedType;

        return matchesSearch && matchesCity && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _buildPremiumHeader(isAr, isDark),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredData.isEmpty
                  ? _buildEmptyState(isAr)
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: _filteredData.length,
                itemBuilder: (context, index) => _buildOpportunityCard(_filteredData[index], isAr, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(bool isAr, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isAr ? "استكشف الفرص" : "Explore Opportunities",
              style: GoogleFonts.tajawal(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(isAr ? "ابحث عن مسارك المهني القادم" : "Find your next career path",
              style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.transparent)
                  ),
                  child: TextField(
                    onChanged: (v) {
                      _searchQuery = v;
                      _applyFilter();
                    },
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: isAr ? "بحث عن مسمى فرصة..." : "Search...",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      border: InputBorder.none,
                      icon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showFilterOptions(isAr, isDark),
                child: Container(
                  height: 55, width: 55,
                  decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.transparent)
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── [تصميم الكرت المطور لإبراز الحواف مَسْطرة] ──
  Widget _buildOpportunityCard(dynamic opp, bool isAr, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => OpportunityDetailScreen(opportunity: opp))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 8)
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(18)
              ),
              child: const Icon(Icons.business_center_rounded, color: AppColors.primaryBlue, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opp['title'] ?? "",
                      style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold, fontSize: 16,
                          color: isDark ? Colors.white : AppColors.textDark
                      )),
                  Text(opp['institution']?['name'] ?? "المؤسسة",
                      style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _cardTag(opp['city'] ?? (isAr ? "غير محدد" : "N/A"), Icons.location_on_outlined, Colors.redAccent, isDark),
                      const SizedBox(width: 8),
                      _cardTag(
                          opp['training_type'] == 'summer' ? (isAr ? "صيفي" : "Summer") : (isAr ? "تعاوني" : "Coop"),
                          Icons.history_edu_outlined, Colors.blue, isDark
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(isAr ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
                size: 14, color: isDark ? Colors.white24 : Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _cardTag(String text, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.06),
          borderRadius: BorderRadius.circular(8)
      ),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showFilterOptions(bool isAr, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 25),
                  Text(isAr ? "تصفية النتائج" : "Filter Results",
                      style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 30),
                  _buildFilterSection(isAr ? "المدينة" : "City",
                      isAr ? ["الكل", "صنعاء", "عدن", "تعز", "حضرموت"] : ["All", "Sanaa", "Aden", "Taiz", "Hadramout"],
                      _selectedCity, (val) {
                        setModalState(() => _selectedCity = val);
                        _applyFilter();
                      }, isDark),
                  const SizedBox(height: 30),
                  _buildFilterSection(isAr ? "نوع التدريب" : "Training Type",
                      isAr ? ["الكل", "summer", "cooperative"] : ["All", "summer", "cooperative"],
                      _selectedType, (val) {
                        setModalState(() => _selectedType = val);
                        _applyFilter();
                      }, isDark),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: Text(isAr ? "استمرار" : "Continue", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildFilterSection(String title, List<String> options, String current, Function(String) onSelect, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white70 : Colors.black54)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: options.map((opt) {
            bool isSelected = current == opt;
            String label = opt == 'summer' ? (Provider.of<LanguageProvider>(context, listen: false).locale.languageCode == 'ar' ? "صيفي" : "Summer") :
            opt == 'cooperative' ? (Provider.of<LanguageProvider>(context, listen: false).locale.languageCode == 'ar' ? "تعاوني" : "Coop") : opt;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (s) => onSelect(opt),
              selectedColor: AppColors.primaryBlue.withOpacity(0.2),
              backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              labelStyle: TextStyle(color: isSelected ? AppColors.primaryBlue : (isDark ? Colors.white60 : Colors.black54)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isAr) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.withOpacity(0.2)),
              const SizedBox(height: 15),
              Text(isAr ? "لا توجد نتائج مطابقة لبحثك" : "No matching results found",
                  style: GoogleFonts.tajawal(color: Colors.grey))
            ]
        )
    );
  }
}
