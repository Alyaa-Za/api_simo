import 'package:flutter/material.dart';
import '../../../core/ui/app_color.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إعدادات الحساب")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _settingTile("تغيير كلمة المرور", Icons.lock_outline, () {}),
          _settingTile("اللغة", Icons.language, () {}),
          _settingTile("سياسة الخصوصية", Icons.privacy_tip_outlined, () {}),
          _settingTile("حول التطبيق", Icons.info_outline, () {}),
          const SizedBox(height: 30),
          _settingTile("حذف الحساب", Icons.delete_forever, () {}, color: Colors.red),
        ],
      ),
    );
  }

  Widget _settingTile(String title, IconData icon, VoidCallback onTap, {Color? color}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? AppColors.primaryBlue),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}
