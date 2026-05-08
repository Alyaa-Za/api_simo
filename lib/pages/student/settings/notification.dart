import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isAr = langProvider.locale.languageCode == 'ar';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(isAr ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(isAr ? "مركز التنبيهات" : "Notifications Center",
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
              return _buildEmptyState(isAr, isDark);
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];

                final String title = item['data']?['title'] ?? (isAr ? "تنبيه جديد" : "New Notification");
                final String message = item['data']?['message'] ?? item['message'] ?? "";
                final bool isRead = item['read_at'] != null || item['is_read'] == 1;
                final String time = item['created_at']?.toString().substring(0, 10) ?? "";

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: isDark
                        ? (isRead ? Colors.black12 : const Color(0xFF1E293B))
                        : (isRead ? Colors.white.withOpacity(0.8) : Colors.white),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                        color: isDark
                            ? (isRead ? Colors.white10 : Colors.white.withOpacity(0.08))
                            : (isRead ? Colors.transparent : AppColors.primaryBlue.withOpacity(0.1)),
                        width: 1
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : (isRead ? 0.01 : 0.04)),
                          blurRadius: 15,
                          offset: const Offset(0, 8)
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.grey.withOpacity(0.1) : AppColors.primaryBlue.withOpacity(0.15),
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
                        color: isDark ? (isRead ? Colors.white38 : Colors.white) : (isRead ? Colors.black54 : AppColors.textDark),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          message,
                          style: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : (isRead ? Colors.grey : Colors.blueGrey),
                              height: 1.4
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 5),
                            Text(time, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
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

  Widget _buildEmptyState(bool isAr, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]
            ),
            child: Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.withOpacity(0.4)),
          ),
          const SizedBox(height: 25),
          Text(isAr ? "صندوق الإشعارات فارغ" : "Notification box is empty",
              style: GoogleFonts.tajawal(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(isAr ? "سيتم إعلامك فور وجود تحديثات جديدة" : "You will be notified when there are new updates",
              style: GoogleFonts.tajawal(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }
}
