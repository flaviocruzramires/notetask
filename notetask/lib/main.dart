import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:notetask/screens/home_screen.dart';
import 'package:notetask/screens/password_screen.dart';
import 'package:notetask/services/settings_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SettingsService _localStorageService = SettingsService();
  bool _isLoading = true;
  bool _isPasswordProtected = false;
  bool _isLightMode = true;

  @override
  void initState() {
    super.initState();
    _loadSettingsAndData();
  }

  Future<void> _loadSettingsAndData() async {
    _isPasswordProtected = await _localStorageService.getPasswordProtection();
    _isLightMode = await _localStorageService.getThemeMode();

    setState(() {
      _isLoading = false;
    });
  }

  void _onPasswordSuccess() {
    setState(() {
      _isPasswordProtected = false;
    });
  }

  void _onThemeChanged(bool isLightMode) {
    setState(() {
      _isLightMode = isLightMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'NoteTask',
      debugShowCheckedModeBanner: false,
      theme: _isLightMode ? ThemeData.light() : ThemeData.dark(),
      home: _isPasswordProtected
          ? PasswordScreen(onPasswordSuccess: _onPasswordSuccess)
          : HomeScreen(onThemeChanged: _onThemeChanged),
    );
  }
}
