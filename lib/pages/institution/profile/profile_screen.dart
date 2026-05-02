import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/api/api_s.dart';
import '../../../core/theme/language_provider.dart';

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
  String _registerNum = "...";

  @override
  void initState() {
    super.initState();
    _loadDataFromApi();
  }

  String _cleanUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    const String realLiveServer = "https://aladdiniot.com";
    String finalUrl = url;
    if (finalUrl.startsWith('http')) return finalUrl.replaceFirst('http://', 'https://');
    if (finalUrl.startsWith('/')) finalUrl = finalUrl.substring(1);
    if (!finalUrl.startsWith('storage/')) finalUrl = "storage/$finalUrl";
    return "$realLiveServer/$finalUrl";
  }

  Future<void> _loadDataFromApi() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().getInstitutionProfile();
      final data = res['data']?['institution'] ?? res['data'] ?? {};

      if (data.isNotEmpty) {
        setState(() {
          _nameCtrl.text = (data['name'] ?? "").toString();
          _addressCtrl.text = (data['address'] ?? "").toString();
          _descCtrl.text = (data['description'] ?? "").toString();
          _webCtrl.text = (data['website'] ?? "").toString();
          _personCtrl.text = (data['contact_person'] ?? "").toString();
          _phoneCtrl.text = (data['contact_phone'] ?? "").toString();
          _registerNum = (data['commercial_register'] ?? "N/A").toString();
          _serverLogoUrl = _cleanUrl(data['profile_picture_url'] ?? data['logo_url']);
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave(bool isAr) async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> data = {
        "name": _nameCtrl.text,
        "address": _addressCtrl.text,
        "description": _descCtrl.text,
        "website": _webCtrl.text,
        "contact_person": _personCtrl.text,
        "contact_phone": _phoneCtrl.text,
        "_method": "PATCH",
      };

      await ApiService().updateInstitutionProfile(data);
      await _loadDataFromApi();
      _showSnack(isAr ? "تم حفظ التعديلات بنجاح" : "Saved successfully", Colors.green);
    } catch (e) {
      _showSnack(isAr ? "فشل الحفظ: $e" : "Save failed: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadLogo(bool isAr) async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (img != null) {
      setState(() => _selectedLogo = File(img.path));
      try {
        await ApiService().uploadInstitutionLogo(img.path);
        await _loadDataFromApi();
        _showSnack(isAr ? "تم تحديث الشعار" : "Logo updated ", Colors.green);
      } catch (e) {
        _showSnack(isAr ? "فشل رفع الشعار" : "Logo upload failed", Colors.red);
      }
    }
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildLogoHeader(isAr, isDark),
              const SizedBox(height: 30),

              _sectionTitle(isAr ? "معلومات المنشأة" : "Entity Information", isAr),
              _buildCard([
                _buildField(isAr ? "اسم المؤسسة" : "Institution Name", _nameCtrl, Icons.business_rounded, isDark),
                _buildField(isAr ? "الموقع / العنوان" : "Location", _addressCtrl, Icons.location_on_outlined, isDark),
                _buildField(isAr ? "نبذة تعريفية" : "Bio", _descCtrl, Icons.description_outlined, isDark, maxLines: 3),
                _buildField(isAr ? "الموقع الإلكتروني" : "Website", _webCtrl, Icons.language_rounded, isDark),
              ], isDark),

              const SizedBox(height: 25),
              _sectionTitle(isAr ? "بيانات التواصل" : "Contact", isAr),
              _buildCard([
                _buildField(isAr ? "اسم مسؤول التواصل" : "Contact Person", _personCtrl, Icons.person_pin_outlined, isDark),
                _buildField(isAr ? "رقم الهاتف" : "Phone", _phoneCtrl, Icons.phone_android_rounded, isDark),
              ], isDark),

              const SizedBox(height: 25),
              _sectionTitle(isAr ? "التوثيق" : "Verification", isAr),
              _buildCard([
                _buildReadOnlyField(isAr ? "رقم السجل التجاري" : "CR Number", _registerNum, Icons.verified_user_outlined, isDark),
              ], isDark),

              const SizedBox(height: 40),
              _buildSaveButton(isAr),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader(bool isAr, bool isDark) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 130, height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2), width: 5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)],
          ),
          child: ClipOval(
            child: _selectedLogo != null
                ? Image.file(_selectedLogo!, fit: BoxFit.cover)
                : (_serverLogoUrl != null && _serverLogoUrl!.isNotEmpty)
                ? Image.network(_serverLogoUrl!, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _buildPlaceholder(isDark))
                : _buildPlaceholder(isDark),
          ),
        ),
        GestureDetector(
          onTap: () => _pickAndUploadLogo(isAr),
          child: const CircleAvatar(
            radius: 20, backgroundColor: Colors.orange,
            child: Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _buildPlaceholder(bool isDark) => Container(
    color: isDark ? Colors.white10 : const Color(0xFFF1F4F8),
    child: Icon(Icons.business_rounded, size: 55, color: isDark ? Colors.white24 : const Color(0xFFB0BCC7)),
  );

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, bool isDark, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines,
      style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
        border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      subtitle: Text(value, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      trailing: const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
    );
  }

  Widget _buildCard(List<Widget> children, bool isDark) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(25),
      border: isDark ? Border.all(color: Colors.white10) : null,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 10)],
    ),
    child: Column(children: children),
  );

  Widget _sectionTitle(String title, bool isAr) => Align(
    alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
    child: Padding(padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
        child: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlue))),
  );

  Widget _buildSaveButton(bool isAr) => Container(
    width: double.infinity, height: 60,
    decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]
    ),
    child: ElevatedButton(
      onPressed: _isLoading ? null : () => _handleSave(isAr),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(isAr ? "حفظ التعديلات النهائية " : "Save Changes ",
          style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
      backgroundColor: color, behavior: SnackBarBehavior.floating,
    ));
  }
}
