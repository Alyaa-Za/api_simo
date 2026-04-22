import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/ui/app_color.dart';

class ApplicationCard extends StatelessWidget {
  final String company;
  final String role;
  final String status;
  final Color statusColor;
  final IconData icon;

  const ApplicationCard({
    super.key,
    required this.company,
    required this.role,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _iconBox(icon, AppColors.primaryBlue),

          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _boldText(company, 14),
                const SizedBox(height: 3),
                _greyText(role, 12),
              ],
            ),
          ),

          _statusBadge(status, statusColor),
        ],
      ),
    );
  }
}
class RequestCard extends StatelessWidget {
  final String name;
  final String position;
  final String avatarLetter;
  final Color color;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const RequestCard({
    super.key,
    required this.name,
    required this.position,
    required this.avatarLetter,
    required this.color,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatarLetter,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _boldText(name, 14),
                const SizedBox(height: 3),
                _greyText(position, 12),
              ],
            ),
          ),

          Column(
            children: [
              _actionBtn(
                icon: Icons.check_rounded,
                color: const Color(0xFF34C759),
                onTap: onAccept,
              ),
              const SizedBox(height: 6),
              _actionBtn(
                icon: Icons.close_rounded,
                color: const Color(0xFFFF6B6B),
                onTap: onReject,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}


BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

Widget _iconBox(IconData icon, Color color) {
  return Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: 22),
  );
}

Widget _statusBadge(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

Widget _boldText(String text, double size) {
  return Text(
    text,
    style: GoogleFonts.inter(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: AppColors.textDark,
    ),
  );
}

Widget _greyText(String text, double size) {
  return Text(
    text,
    style: GoogleFonts.inter(
      fontSize: size,
      color: AppColors.textGrey,
    ),
  );
}