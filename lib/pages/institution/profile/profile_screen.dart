import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';

class InstitutionProfile extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const InstitutionProfile({super.key, this.profile});

  @override
  State<InstitutionProfile> createState() => _InstitutionProfileState();
}

class _InstitutionProfileState extends State<InstitutionProfile> {
  bool _isLoading = false;
  File? _selectedLogo;
  String? _serverLogoUrl;

  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _webCtrl = TextEditingController();
  final _personCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _registerNum = "جاري التحميل...";

  @override
  void initState() {
    super.initState();
    _loadDataFromApi();
  }

  Future<void> _loadDataFromApi() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final res = await ApiService().getInstitutionProfile();

      debugPrint("Full API Response: $res");

      final data = res['data']?['institution'] ?? res['data'] ?? res['institution'] ?? {};

      if (data.isNotEmpty) {
        setState(() {
          _nameCtrl.text = (data['name'] ?? "").toString();
          _addressCtrl.text = (data['address'] ?? "").toString();
          _descCtrl.text = (data['description'] ?? "").toString();
          _webCtrl.text = (data['website'] ?? "").toString();
          _personCtrl.text = (data['contact_person'] ?? "").toString();
          _phoneCtrl.text = (data['contact_phone'] ?? "").toString();
          _registerNum = (data['commercial_register'] ?? "غير متوفر").toString();

          _serverLogoUrl = data['profile_picture_url'] ?? data['logo_url'];
        });
      }
    } catch (e) {
      debugPrint("❌ فشل جلب البيانات من السيرفر: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadLogo() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _selectedLogo = File(img.path));
      try {
        await ApiService().uploadInstitutionLogo(img.path);
        await _loadDataFromApi();
        _showSnack("تم حفظ الشعار في ملفك الشخصي ", Colors.green);
      } catch (e) {
        _showSnack("فشل رفع وحفظ الشعار", Colors.red);
      }
    }
  }

  String _formatUrl(String url) {
    if (url.isEmpty) return url;
    String trimmed = url.trim();
    if (!trimmed.startsWith('http')) {
      return 'https://$trimmed';
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildLogoHeader(),
            const SizedBox(height: 30),

            _sectionTitle("معلومات المنشأة"),
            _buildCard([
              _buildField("اسم المؤسسة", _nameCtrl, Icons.business_rounded),
              const Divider(height: 1),
              _buildField("الموقع / العنوان", _addressCtrl, Icons.location_on_outlined),
              const Divider(height: 1),
              _buildField("نبذة تعريفية", _descCtrl, Icons.description_outlined, maxLines: 3),
              const Divider(height: 1),
              _buildField("الموقع الإلكتروني", _webCtrl, Icons.language_rounded),
            ]),

            const SizedBox(height: 25),
            _sectionTitle("بيانات التواصل"),
            _buildCard([
              _buildField("اسم مسؤول التواصل", _personCtrl, Icons.person_pin_outlined),
              const Divider(height: 1),
              _buildField("رقم هاتف التواصل", _phoneCtrl, Icons.phone_android_rounded),
            ]),

            const SizedBox(height: 25),
            _sectionTitle("بيانات التوثيق"),
            _buildCard([
              _buildReadOnlyField("رقم السجل التجاري", _registerNum, Icons.verified_user_outlined),
            ]),

            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 125, height: 125,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1), width: 5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
          ),
          child: ClipOval(
            child: _selectedLogo != null
                ? Image.file(_selectedLogo!, fit: BoxFit.cover)
                : (_serverLogoUrl != null && _serverLogoUrl!.isNotEmpty)
                ? Image.network(_serverLogoUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildPlaceholder())
                : _buildPlaceholder(),
          ),
        ),
        GestureDetector(
          onTap: _pickAndUploadLogo,
          child: const CircleAvatar(
            radius: 18, backgroundColor: Colors.orange,
            child: Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _buildPlaceholder() => Container(
    color: const Color(0xFFF1F4F8),
    child: const Icon(Icons.business_rounded, size: 55, color: Color(0xFFB0BCC7)),
  );

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines,
      style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
        border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey),
      title: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      subtitle: Text(value, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: Colors.black87)),
      trailing: const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
    );
  }

  Widget _buildCard(List<Widget> children) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
    child: Column(children: children),
  );

  Widget _sectionTitle(String title) => Align(
    alignment: Alignment.centerRight,
    child: Padding(padding: const EdgeInsets.only(right: 10, bottom: 8), child: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlue))),
  );

  Widget _buildSaveButton() => SizedBox(
    width: double.infinity, height: 60,
    child: ElevatedButton(
      onPressed: () async {
        setState(() => _isLoading = true);
        try {
          await ApiService().updateInstitutionProfile({
            "name": _nameCtrl.text,
            "address": _addressCtrl.text,
            "description": _descCtrl.text,
            "website": _formatUrl(_webCtrl.text),
            "contact_person": _personCtrl.text,
            "contact_phone": _phoneCtrl.text,
          });
          await _loadDataFromApi();
          _showSnack("تم حفظ التعديلات في قاعدة البيانات بنجاح ✅", Colors.green);
        } catch (e) {
          _showSnack("فشل الحفظ: تأكد من الاتصال بالإنترنت", Colors.red);
        } finally {
          setState(() => _isLoading = false);
        }
      },
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0),
      child: Text("حفظ التغييرات", style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
