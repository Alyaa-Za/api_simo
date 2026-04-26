import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("مركز التنبيهات",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.splashGradient)),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: ApiService().getNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];

                final String title = item['data']?['title'] ?? "تنبيه جديد";
                final String message = item['data']?['message'] ?? item['message'] ?? "";
                final bool isRead = item['read_at'] != null || item['is_read'] == 1;
                final String time = item['created_at']?.toString().substring(0, 10) ?? "";

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white.withOpacity(0.8) : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(isRead ? 0.01 : 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 8)
                      )
                    ],
                    border: isRead ? null : Border.all(color: AppColors.primaryBlue.withOpacity(0.1), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.grey.withOpacity(0.1) : AppColors.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                          isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                          color: isRead ? Colors.grey : AppColors.primaryBlue,
                          size: 24
                      ),
                    ),
                    title: Text(
                      title,
                      style: GoogleFonts.tajawal(
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                        fontSize: 15,
                        color: isRead ? Colors.black54 : AppColors.textDark,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          message,
                          style: GoogleFonts.tajawal(fontSize: 13, color: isRead ? Colors.grey : Colors.blueGrey, height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 5),
                            Text(time, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
            child: Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 25),
          Text("صندوق الإشعارات فارغ", style: GoogleFonts.tajawal(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text("سيتم إعلامك فور وجود تحديثات جديدة", style: GoogleFonts.tajawal(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }
}
