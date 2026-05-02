import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';
import 'InternDetails_tabs.dart';

class ActiveInternsList extends StatefulWidget {
  const ActiveInternsList({super.key});

  @override
  State<ActiveInternsList> createState() => _ActiveInternsListState();
}

class _ActiveInternsListState extends State<ActiveInternsList> {
  Future<List<dynamic>> _fetchInterns() async {
    return await ApiService().getActiveInterns();
  }

  @override
  Widget build(BuildContext context) {
    // جلب حالة اللغة والوضع الليلي
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder<List<dynamic>>(
          future: _fetchInterns(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  isAr ? "حدث خطأ في جلب بيانات المتدربين" : "Error fetching interns data",
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }

            final list = snapshot.data ?? [];

            if (list.isEmpty) {
              return _buildEmptyState(isAr, isDark);
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) => _internCard(list[index], isDark, isAr),
            );
          },
        ),
      ),
    );
  }

  Widget _internCard(dynamic intern, bool isDark, bool isAr) {
    final String studentName = intern['student']?['full_name'] ?? (isAr ? "اسم المتدرب" : "Intern Name");
    final String opportunityTitle = intern['opportunity']?['title'] ?? (isAr ? "الفرصة التدريبية" : "Training Opportunity");

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          child: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
        ),
        title: Text(
          studentName,
          style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black87
          ),
        ),
        subtitle: Text(
          opportunityTitle,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey),
        ),
        trailing: Icon(
            isAr ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
            size: 16,
            color: Colors.grey.shade400
        ),
        onTap: () {
          final Map<String, dynamic> dataToPass = {
            'internship_id': intern['internship_id'],
            'full_name': studentName,
          };

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InternDetailsTabs(intern: dataToPass),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isAr, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              Icons.group_off_rounded,
              size: 80,
              color: isDark ? Colors.white10 : Colors.grey.shade300
          ),
          const SizedBox(height: 20),
          Text(
            isAr ? "لا يوجد متدربون نشطون حالياً" : "No active interns at the moment",
            style: GoogleFonts.tajawal(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16
            ),
          ),
        ],
      ),
    );
  }
}
