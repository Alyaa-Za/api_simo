import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';
import 'InternDetails_tabs.dart';

class InternsManagementScreen extends StatefulWidget {
  const InternsManagementScreen({super.key});

  @override
  State<InternsManagementScreen> createState() => _InternsManagementScreenState();
}

class _InternsManagementScreenState extends State<InternsManagementScreen> {
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
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            elevation: 0,
            title: Text(isAr ? "متابعة وتقييم المتدربين" : "Monitoring & Evaluation",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
            bottom: TabBar(
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 3,
              tabs: [
                Tab(text: isAr ? "الطلاب النشطون" : "Active Interns"),
                Tab(text: isAr ? "الطلاب المكتملون" : "Completed"),
              ],
            ),
          ),
          body: FutureBuilder<List<dynamic>>(
            future: ApiService().getInstitutionInternships(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Center(child: Text(isAr ? "فشل جلب البيانات" : "Load Failed"));

              final all = snapshot.data ?? [];
              final activeList = all.where((i) => i['status'] == 'active').toList();
              final completedList = all.where((i) => i['status'] == 'completed').toList();

              return TabBarView(
                children: [
                  _buildInternsList(activeList, true, isAr, isDark),
                  _buildInternsList(completedList, false, isAr, isDark),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInternsList(List<dynamic> list, bool isActive, bool isAr, bool isDark) {
    if (list.isEmpty) return Center(child: Text(isAr ? "القائمة فارغة" : "No interns found"));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final intern = list[index];
        final student = intern['student'] ?? {};
        final String name = student['full_name'] ?? "---";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => InternDetailsTabs(intern: intern)),
              );
              if (result == true) _refresh();
            },
            leading: CircleAvatar(backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                child: Text(name.substring(0,1).toUpperCase(), style: const TextStyle(color: AppColors.primaryBlue))),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(intern['opportunity']?['title'] ?? ""),
            trailing: isActive
                ? const Icon(Icons.arrow_forward_ios, size: 14)
                : const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
    );
  }
}
