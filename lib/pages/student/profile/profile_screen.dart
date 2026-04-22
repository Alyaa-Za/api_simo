import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_service.dart';
import 'edit_profile_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});
  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  File? _localImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService().getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        // جلب البيانات من حقل 'data' حسب استجابة السيرفر
        final data = snapshot.data?['data'] ?? {};

        return SingleChildScrollView(
          child: Column(
            children: [
              // الهيدر المحدث بالحقول الجديدة
              _buildHeader(data),

              const SizedBox(height: 20),
              _buildEditButton(),

              // عرض البيانات الأكاديمية الحقيقية
              _buildInfoSection(data),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Map<String, dynamic> data) {
    // نسبة الإكمال القادمة من الباك أند
    double completion = (data['completion_percentage'] ?? 0).toDouble() / 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white24,
                backgroundImage: _localImage != null
                    ? FileImage(_localImage!)
                    : (data['profile_picture_url'] != null ? NetworkImage(data['profile_picture_url']) : null),
                child: (_localImage == null && data['profile_picture_url'] == null)
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              Positioned(bottom: 0, right: 0, child: GestureDetector(
                onTap: _pickAndUploadPhoto,
                child: const CircleAvatar(radius: 18, backgroundColor: Colors.orange, child: Icon(Icons.camera_alt, size: 16, color: Colors.white)),
              )),
            ],
          ),
          const SizedBox(height: 15),
          Text(data['full_name']?.toString() ?? "زائر", style: GoogleFonts.tajawal(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(data['email']?.toString() ?? "", style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 15),

          // بار نسبة الإكمال الجديد
          SizedBox(
            width: 200,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("نسبة إكمال الملف", style: TextStyle(color: Colors.white, fontSize: 10)),
                    Text("${(completion * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(value: completion, backgroundColor: Colors.white24, color: Colors.orange),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _localImage = File(img.path));
      try {
        await ApiService().uploadProfilePhoto(img.path);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _infoTile("الرقم الجامعي", data['student_number'], Icons.badge),
          _infoTile("الجامعة", data['university'], Icons.school),
          _infoTile("القسم", data['department'], Icons.account_tree),
          _infoTile("المعدل", data['gpa']?.toString(), Icons.grade),
          _infoTile("المدينة", data['city'], Icons.location_city),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String? value, IconData icon) => ListTile(
    leading: Icon(icon, color: AppColors.primaryBlue),
    title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    subtitle: Text(value ?? "غير محدد", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
  );

  Widget _buildEditButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ElevatedButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfileScreen())),
      child: const Text("تعديل البيانات الأكاديمية"),
    ),
  );
}
