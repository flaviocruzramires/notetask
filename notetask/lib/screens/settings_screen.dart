import 'package:flutter/material.dart';
import 'package:notetask/services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordProtected = false;
  String _currentPassword = '';
  bool _isLightMode = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isPasswordProtected = await _localStorageService.getPasswordProtection();
    _currentPassword = await _localStorageService.getPassword() ?? '';
    _isLightMode = await _localStorageService.getThemeMode();
    setState(() {
      _passwordController.text = _currentPassword;
    });
  }

  Future<void> _togglePasswordProtection(bool value) async {
    if (value && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, defina uma senha primeiro.')),
      );
      return;
    }

    setState(() {
      _isPasswordProtected = value;
    });
    await _localStorageService.setPasswordProtection(value);
  }

  Future<void> _savePassword() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A senha não pode ser vazia.')),
      );
      return;
    }
    await _localStorageService.setPassword(_passwordController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha salva com sucesso!')),
    );
  }

  Future<void> _toggleThemeMode(bool value) async {
    setState(() {
      _isLightMode = value;
    });
    await _localStorageService.setThemeMode(value);
    widget.onThemeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    // Definindo cores para o tema
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final iconColor = isLightMode ? Colors.black : Colors.white;
    final textColor = iconColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text('Proteger entrada com senha', style: TextStyle(color: textColor)),
            value: _isPasswordProtected,
            onChanged: _togglePasswordProtection,
            activeColor: textColor,
          ),
          if (_isPasswordProtected)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _passwordController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Defina uma senha',
                      labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: textColor.withOpacity(0.5))),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: textColor)),
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 10),
                  TextButton( // Alterado de ElevatedButton para TextButton
                    onPressed: _savePassword,
                    child: const Text('Salvar Senha'),
                  ),
                ],
              ),
            ),
          const Divider(),
          SwitchListTile(
            title: Text('Modo Claro/Escuro', style: TextStyle(color: textColor)),
            subtitle: Text(_isLightMode ? 'Modo Claro' : 'Modo Escuro', style: TextStyle(color: textColor.withOpacity(0.7))),
            value: _isLightMode,
            onChanged: _toggleThemeMode,
            activeColor: textColor,
          ),
        ],
      ),
    );
  }
}