import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/token_manager.dart'; // تأكدي من مسار مدير التوكن
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

  // ── [دالة تصحيح الروابط]: تحويل localhost إلى الدومين الحقيقي ──
  String? _fixUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    // استبدلي 'https://your-domain.com' برابط السيرفر المرفوع الحقيقي
    const String liveServer = "https://your-domain.com";
    if (url.contains('localhost')) {
      return url.replaceFirst(RegExp(r'http://localhost(:\d+)?'), liveServer);
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        body: FutureBuilder<Map<String, dynamic>>(
          future: ApiService().getProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final response = snapshot.data?['data'] ?? {};
            final String name = response['full_name']?.toString() ?? "المتدرب";
            final String email = response['email']?.toString() ?? "";
            final int percentage = response['completion_percentage'] ?? 0;
            final String? serverPicUrl = _fixUrl(response['profile_picture_url']);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(serverPicUrl, name, email, percentage),
                  const SizedBox(height: 40),
                  _buildEditButton(),
                  const SizedBox(height: 35),
                  _buildInternshipCircle(context),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String? serverPic, String name, String email, int percentage) {
    double completion = percentage / 100;
    bool isComplete = percentage >= 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 60, 30, 40),
      decoration: const BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 4),
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white10,
                  child: ClipOval(
                    child: _localImage != null
                        ? Image.file(_localImage!, fit: BoxFit.cover, width: 110, height: 110)
                        : (serverPic != null && serverPic.isNotEmpty)
                        ? Image.network(
                      serverPic,
                      fit: BoxFit.cover,
                      width: 110, height: 110,
                      // 👈 الحل السحري لخطأ 403: إرسال التوكن مع الصورة
                      headers: {
                        "Authorization": "Bearer ${TokenManager.getToken()}",
                      },
                      // 👈 معالجة الخطأ لضمان عدم ظهور الشاشة الحمراء
                      errorBuilder: (context, error, stackTrace) => _placeholder(),
                    )
                        : _placeholder(),
                  ),
                ),
              ),
              Positioned(
                bottom: 5, right: 5,
                child: GestureDetector(
                  onTap: _pickAndUploadPhoto,
                  child: const CircleAvatar(
                    radius: 18, backgroundColor: Colors.orange,
                    child: Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(name, style: GoogleFonts.tajawal(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(email, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 25),

          // شريط النسبة الشفاف
          Container(
            width: 200, padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isComplete ? "مكتمل ✅" : "نسبة الإنجاز", style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text("$percentage%", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(value: completion, backgroundColor: Colors.white12, color: isComplete ? Colors.greenAccent : Colors.orangeAccent, minHeight: 6),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _placeholder() => const Icon(Icons.person_rounded, size: 65, color: Colors.white70);

  Future<void> _pickAndUploadPhoto() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _localImage = File(img.path));
      try {
        await ApiService().uploadProfilePhoto(img.path);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تحديث الصورة بنجاح ✅")));
      } catch (e) { debugPrint(e.toString()); }
    }
  }

  Widget _buildEditButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Container(
      width: double.infinity, height: 55,
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))]),
      child: ElevatedButton.icon(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfileScreen()));
          if (result == true) setState(() {});
        },
        icon: const Icon(Icons.edit_note_rounded, size: 22),
        label: Text("تعديل بياناتي", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white, shape: const StadiumBorder(), elevation: 0),
      ),
    ),
  );

  Widget _buildInternshipCircle(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const InternshipScreen())),
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))], border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1), width: 2)),
            child: const Icon(Icons.workspace_premium_rounded, size: 50, color: AppColors.primaryBlue),
          ),
        ),
        const SizedBox(height: 12),
        Text("تدريبي الحالي", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
