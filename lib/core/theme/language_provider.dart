import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String code = prefs.getString('lang') ?? 'ar';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> changeLanguage(String type) async {
    _locale = Locale(type);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', type);
    notifyListeners();
  }
}
