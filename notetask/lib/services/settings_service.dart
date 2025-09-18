// lib/services/settings_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  Future<bool> getPasswordProtection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('password') != null;
  }

  Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('password');
  }

  Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
  }

  Future<void> deletePassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('password');
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLightMode') ?? true;
  }

  Future<void> saveThemeMode(bool isLightMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLightMode', isLightMode);
  }
}
