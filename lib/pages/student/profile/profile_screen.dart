import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_s.dart';
import '../../../core/ui/app_color.dart';
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

  // ✅ هذا هو التعديل (base url)
  final String _baseImageUrl = "http://192.168.205.158:8000/";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService().getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?['data'] ?? {};

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(data),
              const SizedBox(height: 40),
              _buildEditButton(),
              const SizedBox(height: 30),
              _buildInternshipCircle(context),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInternshipCircle(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InternshipScreen()),
            );
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1), width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 50,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "تدريبي القائم",
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        Text(
          "اضغط لمتابعة التفاصيل",
          style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildHeader(Map<String, dynamic> data) {
    int rawPercentage = data['completion_percentage'] ?? 0;
    double completion = rawPercentage.toDouble() / 100;
    bool isComplete = rawPercentage >= 100;

    // ✅ تجهيز رابط الصورة بشكل صحيح
    final imageUrl = data['profile_picture_url'] != null
        ? _baseImageUrl + data['profile_picture_url']
        : null;

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
                    : (imageUrl != null ? NetworkImage(imageUrl) : null),
                child: (_localImage == null && imageUrl == null)
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAndUploadPhoto,
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            data['full_name']?.toString() ?? "User",
            style: GoogleFonts.tajawal(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            data['email']?.toString() ?? "",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: 180,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isComplete ? "الملف مكتمل ✅" : "نسبة إكمال الملف",
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    Text(
                      "$rawPercentage%",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: completion,
                    backgroundColor: Colors.white24,
                    color: isComplete ? Colors.greenAccent : Colors.orangeAccent,
                    minHeight: 6,
                  ),
                ),
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

  Widget _buildEditButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: ElevatedButton.icon(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const EditProfileScreen()),
        );
        setState(() {});
      },
      icon: const Icon(Icons.edit_note_rounded),
      label: const Text("تعديل البيانات الأكاديمية"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 5,
      ),
    ),
  );
}