import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/theme/language_provider.dart';
import 'edit_profile_screen.dart';
import '../internship/internship_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});
  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  File? _localImage;
  final ImagePicker _picker = ImagePicker();

  String _cleanUrl(String? url) {
    if (url == null || url.isEmpty) return "";

    const String realLiveServer = "https://trainex.aladdiniot.com";
    String finalUrl = url;

    if (finalUrl.contains('localhost') || finalUrl.contains('127.0.0.1')) {
      finalUrl = finalUrl.replaceFirst(RegExp(r'https?://(localhost|127\.0\.0\.1)(:\d+)?'), realLiveServer);
    }

    if (finalUrl.startsWith('http')) {
      finalUrl = finalUrl.replaceFirst('http://', 'https://');
    } else {
      if (finalUrl.startsWith('/')) finalUrl = finalUrl.substring(1);
      if (!finalUrl.contains('storage/')) {
        finalUrl = "storage/$finalUrl";
      }
      finalUrl = "$realLiveServer/$finalUrl";
    }

    // debugPrint("Final Image URL: $finalUrl");
    return finalUrl;
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
        body: FutureBuilder<Map<String, dynamic>>(
          future: ApiService().getProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final response = snapshot.data?['data'] ?? {};
            final String name = response['full_name']?.toString() ?? (isAr ? "اسم المتدرب" : "Student Name");
            final String email = response['email']?.toString() ?? "";
            final int percentage = response['completion_percentage'] ?? 0;

            final String picUrl = _cleanUrl(response['profile_picture_url']);
            final List history = response['internships_history'] ?? [];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. الهيدر الملكي (VIP)
                SliverToBoxAdapter(
                  child: _buildVipHeader(picUrl, name, email, percentage, isDark, isAr),
                ),

                // 2. أزرار التحكم السريعة
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                    child: Row(
                      children: [
                        Expanded(child: _buildLuxuryButton(isAr ? "تعديل الحساب" : "Edit Profile", Icons.edit_note_rounded, AppColors.primaryBlue, () async {
                          final res = await Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfileScreen()));
                          if (res == true) setState(() {});
                        })),
                        const SizedBox(width: 15),
                        _buildCircleAction(Icons.workspace_premium_rounded, () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => const InternshipScreen()));
                        }, isDark),
                      ],
                    ),
                  ),
                ),

                // 3. قسم المسيرة التدريبية
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
                    child: Text(isAr ? "المسيرة التدريبية" : "Internship Journey",
                        style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: isDark ? Colors.white : AppColors.textDark
                        )),
                  ),
                ),

                history.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState(isAr, isDark))
                    : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildHistoryCard(history[index], isDark, isAr),
                      childCount: history.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildVipHeader(String picUrl, String name, String email, int percentage, bool isDark, bool isAr) {
    return Container(
      height: 380,
      child: Stack(
        children: [
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: AppColors.splashGradient,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
            ),
          ),
          Positioned(top: -50, left: -50, child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.05))),

          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140, height: 140,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 6,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                      ),
                    ),
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 4),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                      ),
                      child: ClipOval(
                        child: _localImage != null
                            ? Image.file(_localImage!, fit: BoxFit.cover, width: 120, height: 120)
                            : Image.network(
                          picUrl,
                          fit: BoxFit.cover,
                          width: 120, height: 120,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                                color: isDark ? Colors.white10 : Colors.grey[200],
                                child: Icon(Icons.person, size: 60, color: isDark ? Colors.white24 : Colors.grey)
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(bottom: 0, right: 10, child: GestureDetector(
                      onTap: _pickImage,
                      child: const CircleAvatar(radius: 18, backgroundColor: Colors.orange, child: Icon(Icons.camera_alt, size: 16, color: Colors.white)),
                    )),
                  ],
                ),
                const SizedBox(height: 15),
                Text(name, style: GoogleFonts.tajawal(color: isDark ? Colors.white : AppColors.textDark, fontSize: 24, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text("${isAr ? 'إكمال الملف:' : 'Profile:'} $percentage%", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map item, bool isDark, bool isAr) {
    final opp = item['opportunity'] ?? {};
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.business_rounded, color: AppColors.primaryBlue)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opp['title'] ?? (isAr ? "تدريب ميداني" : "Internship"),
                        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                    Text(opp['institution_name'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
            ],
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Divider(color: isDark ? Colors.white10 : const Color(0xFFF0F4FD))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile(Icons.person_pin_rounded, "${isAr ? 'المشرف:' : 'Mentor:'} ${item['mentor_name'] ?? 'N/A'}", isDark),
              _infoTile(Icons.calendar_today_rounded, item['actual_end_date']?.toString() ?? (isAr ? "قيد التنفيذ" : "Ongoing"), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text, bool isDark) => Row(children: [Icon(icon, size: 14, color: Colors.grey), const SizedBox(width: 5), Text(text, style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54))]);

  Widget _buildLuxuryButton(String label, IconData icon, Color color, VoidCallback onTap) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 20),
    label: Text(label, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
    style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
  );

  Widget _buildCircleAction(IconData icon, VoidCallback onTap, bool isDark) => GestureDetector(
    onTap: onTap,
    child: Container(width: 55, height: 55, decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(20), border: isDark ? Border.all(color: Colors.white10) : null, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Icon(icon, color: AppColors.primaryBlue)),
  );

  Widget _buildEmptyState(bool isAr, bool isDark) => Container(
      margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Center(child: Text(isAr ? "لا توجد سجلات سابقة مسجلة" : "No previous records found", style: const TextStyle(color: Colors.grey))));

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (img != null) {
      setState(() => _localImage = File(img.path));
      try {
        await ApiService().uploadProfilePhoto(img.path);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅"), behavior: SnackBarBehavior.floating));
      } catch (e) { debugPrint("Upload Error: $e"); }
    }
  }
}
