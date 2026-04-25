import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: FutureBuilder<List<dynamic>>(
          future: _fetchInterns(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("حدث خطأ في جلب بيانات المتدربين"));
            }

            final list = snapshot.data ?? [];

            if (list.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              itemBuilder: (context, index) => _internCard(list[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _internCard(dynamic intern) {
    final String studentName = intern['student']?['full_name'] ?? "اسم المتدرب";
    final String opportunityTitle = intern['opportunity']?['title'] ?? "الفرصة التدريبية";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          child: const Icon(Icons.person_outline, color: AppColors.primaryBlue),
        ),
        title: Text(
          studentName,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          opportunityTitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),

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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "لا يوجد متدربون نشطون حالياً",
            style: GoogleFonts.tajawal(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
