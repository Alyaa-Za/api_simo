import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedStatus = 'all';
  String _selectedSenderType = 'all';
  List<dynamic> _complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService().getAdminComplaints(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );

      setState(() {
        _complaints = data.where((item) {
          final sender = item['sender'] ?? {};
          final matchesSender = _selectedSenderType == 'all' || sender['user_type'] == _selectedSenderType;
          final matchesSearch = _searchCtrl.text.isEmpty ||
              (item['title'] ?? "").toString().toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
              (sender['full_name'] ?? "").toString().toLowerCase().contains(_searchCtrl.text.toLowerCase());
          return matchesSender && matchesSearch;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _refresh() => _fetchData();

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
              expandedHeight: 140, pinned: true,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              elevation: 0.5,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                title: Row(
                  children: [
                    Text(isAr ? "صندوق المراسلات" : "Messages Box",
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryBlue)),
                    const SizedBox(width: 10),
                    _buildNewBadge(_complaints.length, isAr),
                  ],
                ),
              ),
              actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue))],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSearchBar(isAr, isDark),
                    const SizedBox(height: 15),
                    _buildFilterRow(isAr, isDark),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (_complaints.isEmpty)
              SliverFillRemaining(child: Center(child: Text(isAr ? "لا توجد رسائل مطابقة" : "No messages found")))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 150),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildComplaintCard(_complaints[index], isAr, isDark),
                    childCount: _complaints.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewBadge(int count, bool ar) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text("$count ${ar ? 'رسائل' : 'Msgs'}", style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSearchBar(bool ar, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: dark ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => _fetchData(),
        decoration: InputDecoration(
          hintText: ar ? "ابحث في العنوان أو الوصف..." : "Search in title or desc...",
          border: InputBorder.none,
          icon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
        ),
      ),
    );
  }

  Widget _buildFilterRow(bool ar, bool dark) {
    return Row(
      children: [
        Expanded(child: _buildDropdown(ar ? "الحالة" : "Status", ['all', 'pending', 'in_progress', 'resolved'], _selectedStatus, (v) => setState(() { _selectedStatus = v!; _fetchData(); }), ar, dark)),
        const SizedBox(width: 10),
        Expanded(child: _buildDropdown(ar ? "نوع المرسل" : "Sender", ['all', 'student', 'institution'], _selectedSenderType, (v) => setState(() { _selectedSenderType = v!; _fetchData(); }), ar, dark)),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String current, Function(String?) onChange, bool ar, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: dark ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isExpanded: true,
          style: GoogleFonts.tajawal(fontSize: 12, color: dark ? Colors.white : Colors.black87),
          onChanged: onChange,
          items: items.map((String val) => DropdownMenuItem(value: val, child: Text(val == 'all' ? label : val))).toList(),
        ),
      ),
    );
  }

  Widget _buildComplaintCard(dynamic c, bool ar, bool dark) {
    final sender = c['sender'] ?? {};
    final String status = c['status'] ?? 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: dark ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(dark ? 0.2 : 0.02), blurRadius: 15)]),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: AppColors.primaryBlue.withOpacity(0.1), child: const Icon(Icons.person_outline, color: AppColors.primaryBlue, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(sender['full_name'] ?? "---", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(c['sent_at']?.toString().substring(0, 10) ?? "", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ])),
              _statusBadge(status, ar),
            ],
          ),
          const SizedBox(height: 15),
          Align(alignment: ar ? Alignment.centerRight : Alignment.centerLeft, child: Text(c['title'] ?? "", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13))),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _showComplaintDetails(c, ar, dark),
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: Text(ar ? "التفاصيل" : "Details"),
              style: TextButton.styleFrom(foregroundColor: Colors.blueGrey, backgroundColor: Colors.blueGrey.withOpacity(0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          )
        ],
      ),
    );
  }

  Widget _statusBadge(String s, bool ar) {
    Color col = s == 'resolved' ? Colors.green : (s == 'in_progress' ? Colors.blue : Colors.orange);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(s, style: TextStyle(color: col, fontSize: 9, fontWeight: FontWeight.bold)));
  }

  void _showComplaintDetails(dynamic c, bool ar, bool dark) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      pageBuilder: (ctx, a1, a2) => Directionality(
        textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: dark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          body: Column(
            children: [
              Container(
                width: double.infinity, padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
                decoration: const BoxDecoration(gradient: AppColors.splashGradient, borderRadius: BorderRadius.vertical(bottom: Radius.circular(35))),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const SizedBox(width: 40),
                    const CircleAvatar(radius: 35, backgroundColor: Colors.white24, child: Icon(Icons.mail_outline_rounded, color: Colors.white, size: 35)),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded, color: Colors.white))
                  ]),
                  const SizedBox(height: 15),
                  Text(c['title'] ?? "", textAlign: TextAlign.center, style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("${ar ? 'المرسل:' : 'From:'} ${c['sender']?['full_name']}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _infoLabel(ar ? "تاريخ الإرسال" : "Sent Date", Icons.access_time_rounded),
                    Text(c['sent_at'] ?? "---", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 25),
                    _infoLabel(ar ? "المحتوى" : "Content", Icons.description_outlined),
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: dark ? Colors.white.withOpacity(0.05) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                      child: Text(c['description'] ?? "", style: TextStyle(fontSize: 14, height: 1.6, color: dark ? Colors.white70 : Colors.black87)),
                    ),
                    const SizedBox(height: 30),
                    _infoLabel(ar ? "تحديث الحالة" : "Update Status", Icons.sync_rounded),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      _statusBtn('pending', Colors.orange, ar, c['complaint_id'] ?? c['id']),
                      _statusBtn('in_progress', Colors.blue, ar, c['complaint_id'] ?? c['id']),
                      _statusBtn('resolved', Colors.green, ar, c['complaint_id'] ?? c['id']),
                    ]),
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoLabel(String l, IconData i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(i, size: 16, color: AppColors.primaryBlue), const SizedBox(width: 8), Text(l, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))]));

  Widget _statusBtn(String s, Color col, bool ar, int id) => InkWell(
    onTap: () async { await ApiService().updateComplaintStatus(id, s); Navigator.pop(context); _refresh(); },
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: col.withOpacity(0.3))), child: Text(s, style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold))),
  );
}
