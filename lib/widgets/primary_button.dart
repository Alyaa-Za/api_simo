import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/ui/app_color.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 58,
    this.width,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _ctrl.forward() : null,
      onTapUp: isEnabled ? (_) => _ctrl.reverse() : null,
      onTapCancel: isEnabled ? () => _ctrl.reverse() : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.primaryBlue
                : AppColors.primaryBlue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isEnabled
                ? [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2.5,
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: AppColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}