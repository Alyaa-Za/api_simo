import 'package:flutter/material.dart';
import 'package:ftms_final/pages/splash_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;
  runApp(TrainEx(isDarkMode: isDark));
}

class TrainEx extends StatelessWidget {
  final bool isDarkMode;
  const TrainEx({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trainex',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}