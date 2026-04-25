import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/ui/app_color.dart';
import '../../../core/token_manager.dart';
import '../../login_screen.dart';
import 'InstitutionComplaints.dart';
import 'PrivacyPolicyScreen.dart';

class InstitutionSettingsSideBar extends StatefulWidget {
  const InstitutionSettingsSideBar({super.key});

  @override
  State<InstitutionSettingsSideBar> createState() =>
      _InstitutionSettingsSideBarState();
}

class _InstitutionSettingsSideBarState
    extends State<InstitutionSettingsSideBar> {

  bool _isObscureOld = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildPremiumHeader(),
          const SizedBox(height: 20),

          _buildMenuTile(
            context,
            Icons.lock_reset_rounded,
            "تغيير كلمة المرور",
                () => _showChangePasswordModal(context),
          ),

          _buildMenuTile(
            context,
            Icons.support_agent_rounded,
            "مركز الدعم والشكاوى",
                () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => const InstitutionComplaintsScreen(),
                ),
              );
            },
          ),

          _buildMenuTile(
            context,
            Icons.privacy_tip_outlined,
            "سياسة الخصوصية",
                () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          const Spacer(),

          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 70, 20, 40),
    decoration: const BoxDecoration(
      gradient: AppColors.splashGradient,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(50),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundColor: Colors.white24,
          child: Icon(Icons.settings_outlined,
              color: Colors.white, size: 35),
        ),
        const SizedBox(height: 15),
        Text(
          "الإعدادات والخصوصية",
          style: GoogleFonts.tajawal(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "تحكم في حسابك وأمان مؤسستك",
          style: GoogleFonts.tajawal(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  Widget _buildMenuTile(
      BuildContext ctx,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) =>
      ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey,
        ),
      );

  Widget _buildLogoutButton(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(25, 10, 25, 40),
    child: ElevatedButton.icon(
      onPressed: () async {
        await TokenManager.clearToken();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (c) => const LoginScreen()),
              (r) => false,
        );
      },
      icon: const Icon(Icons.logout_rounded, color: Colors.white),
      label: const Text("تسجيل الخروج"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        minimumSize: const Size(double.infinity, 60),
      ),
    ),
  );

  void _showChangePasswordModal(BuildContext context) {}
}