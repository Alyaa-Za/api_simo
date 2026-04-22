import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryBlue      = Color(0xFF3D9BF0);
  static const Color primaryBlueDark  = Color(0xFF2B7ED4);
  static const Color primaryBlueLight = Color(0xFF5BB3F5);

  static const Color splashBg    = Color(0xFF4AABF7);
  static const Color onboardBg   = Color(0xFFF0F4F8);
  static const Color white       = Color(0xFFFFFFFF);
  static const Color cardBg      = Color(0xFFF0F6FF);

  static const Color textDark    = Color(0xFF1A1A2E);
  static const Color textGrey    = Color(0xFF7A8599);
  static const Color textWhite   = Color(0xFFFFFFFF);

  static const Color splashBubble1  = Color(0x40FFFFFF);
  static const Color splashBubble2  = Color(0x30FFFFFF);
  static const Color splashBubble3  = Color(0x20FFFFFF);

  static const Color onboardBubble1 = Color(0x55AECFF5);
  static const Color onboardBubble2 = Color(0x70BDD9F7);
  static const Color onboardBubble3 = Color(0x45C8E0FA);

  static const Color inputBorder = Color(0xFFE0E8F0);
  static const Color inputFill   = Color(0xFFFFFFFF);

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF5BB8FF), Color(0xFF2E90E8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF4AABF7), Color(0xFF2B7ED4)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}