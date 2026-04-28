import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/token_manager.dart';
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

  // ── [دالة تنظيف وبناء الروابط الذكية المعتمدة على دومينك] ──
  String _cleanUrl(String? url) {
    if (url == null || url.isEmpty) return "";

    // الدومين الحقيقي الخاص بكِ
    const String realLiveServer = "https://trainex.aladdiniot.com";

    String finalUrl = url;

    // 1. استبدال أي شكل من أشكال اللوكال هوست بالدومين الحقيقي (مع دعم http و https)
    if (finalUrl.contains('localhost') || finalUrl.contains('127.0.0.1')) {
      finalUrl = finalUrl.replaceFirst(RegExp(r'https?://(localhost|127\.0\.0\.1)(:\d+)?'), realLiveServer);
    }

    // 2. إذا وصل المسار مقطوعاً من السيرفر (بدون http)
    if (!finalUrl.startsWith('http')) {
      if (finalUrl.startsWith('/')) finalUrl = finalUrl.substring(1);
      // التأكد من وجود كلمة storage في المسار
      if (!finalUrl.startsWith('storage/')) {
        finalUrl = "storage/$finalUrl";
      }
      finalUrl = "$realLiveServer/$finalUrl";
    }

    // 3. التأكد من استخدام بروتوكول الأمان https دائماً
    if (finalUrl.startsWith('http://')) {
      finalUrl = finalUrl.replaceFirst('http://', 'https://');
    }

    return finalUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4FD),
        body: FutureBuilder<Map<String, dynamic>>(
          future: ApiService().getProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final response = snapshot.data?['data'] ?? {};
            final String name = response['full_name']?.toString() ?? "اسم المتدرب";
            final String email = response['email']?.toString() ?? "";
            final int percentage = response['completion_percentage'] ?? 0;

            // جلب وتصحيح الرابط
            final String picUrl = _cleanUrl(response['profile_picture_url']);
            final List history = response['internships_history'] ?? [];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. الهيدر الملكي (الواو واو)
                SliverToBoxAdapter(
                  child: _buildVipHeader(picUrl, name, email, percentage),
                ),

                // 2. أزرار التحكم السريعة
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                    child: Row(
                      children: [
                        Expanded(child: _buildLuxuryButton("تعديل الحساب", Icons.edit_note_rounded, AppColors.primaryBlue, () async {
                          final res = await Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfileScreen()));
                          if (res == true) setState(() {});
                        })),
                        const SizedBox(width: 15),
                        _buildCircleAction(Icons.workspace_premium_rounded, () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) => const InternshipScreen()));
                        }),
                      ],
                    ),
                  ),
                ),

                // 3. قسم المسيرة التدريبية
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
                    child: Text("المسيرة التدريبية", style: GoogleFonts.tajawal(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textDark)),
                  ),
                ),

                history.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildHistoryCard(history[index]),
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

  Widget _buildVipHeader(String picUrl, String name, String email, int percentage) {
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
                    // دائرة النسبة المئوية
                    SizedBox(
                      width: 140, height: 140,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 6,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                      ),
                    ),
                    // الصورة الشخصية
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                      ),
                      child: ClipOval(
                        child: _localImage != null
                            ? Image.file(_localImage!, fit: BoxFit.cover, width: 120, height: 120)
                            : (picUrl.isNotEmpty)
                            ? Image.network(
                          picUrl,
                          fit: BoxFit.cover,
                          width: 120, height: 120,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint("❌ Image Failed. Cleaned URL: $picUrl");
                            return Container(color: Colors.grey[200], child: const Icon(Icons.person, size: 60, color: Colors.grey));
                          },
                        )
                            : Container(color: Colors.grey[200], child: const Icon(Icons.person, size: 60, color: Colors.grey)),
                      ),
                    ),
                    Positioned(bottom: 0, right: 10, child: GestureDetector(
                      onTap: _pickImage,
                      child: const CircleAvatar(radius: 18, backgroundColor: Colors.orange, child: Icon(Icons.camera_alt, size: 16, color: Colors.white)),
                    )),
                  ],
                ),
                const SizedBox(height: 15),
                Text(name, style: GoogleFonts.tajawal(color: AppColors.textDark, fontSize: 24, fontWeight: FontWeight.bold)),
                Text(email, style: GoogleFonts.tajawal(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text("إكمال الملف: $percentage%", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map item) {
    final opp = item['opportunity'] ?? {};
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF0F4FD), borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.business_rounded, color: AppColors.primaryBlue)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opp['title'] ?? "تدريب ميداني", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(opp['institution_name'] ?? "جهة التدريب", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Color(0xFFF0F4FD))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile(Icons.person_pin_rounded, "المشرف: ${item['mentor_name'] ?? 'غير محدد'}"),
              _infoTile(Icons.calendar_today_rounded, item['actual_end_date']?.toString() ?? "قيد التنفيذ"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) => Row(children: [Icon(icon, size: 14, color: Colors.grey), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 11, color: Colors.black54))]);

  Widget _buildLuxuryButton(String label, IconData icon, Color color, VoidCallback onTap) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 20),
    label: Text(label, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
    style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
  );

  Widget _buildCircleAction(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(width: 55, height: 55, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Icon(icon, color: AppColors.primaryBlue)),
  );

  Widget _buildEmptyState() => Container(
      margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: const Center(child: Text("لا توجد سجلات سابقة مسجلة")));

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _localImage = File(img.path));
      try {
        await ApiService().uploadProfilePhoto(img.path);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم رفع الصورة بنجاح ✅")));
      } catch (e) { debugPrint("Upload Error: $e"); }
    }
  }
}
