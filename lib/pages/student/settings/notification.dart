import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("الإشعارات"),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final notify = snapshot.data![index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notify['is_read'] == 1 ? Colors.grey[200] : AppColors.primaryBlue.withOpacity(0.1),
                    child: Icon(Icons.notifications_active_outlined,
                        color: notify['is_read'] == 1 ? Colors.grey : AppColors.primaryBlue),
                  ),
                  title: Text(notify['message'] ?? "", style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(notify['created_at'] ?? "", style: const TextStyle(fontSize: 11)),
                ),
              );
            },
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
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text("لا توجد تنبيهات حالياً", style: GoogleFonts.tajawal(color: Colors.grey)),
        ],
      ),
    );
  }
}
