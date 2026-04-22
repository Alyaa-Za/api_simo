import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/ui/app_color.dart';

class HomeAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const HomeAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.school_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
            ),
            child: Icon(icon, color: AppColors.white, size: 24),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.80),
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.20),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}