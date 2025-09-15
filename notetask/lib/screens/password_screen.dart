import 'package:flutter/material.dart';
import 'package:notetask/services/local_storage_service.dart';

class PasswordScreen extends StatefulWidget {
  final VoidCallback onPasswordSuccess;

  const PasswordScreen({super.key, required this.onPasswordSuccess});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final TextEditingController _passwordController = TextEditingController();

  String? _storedPassword;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPassword();
  }

  // Carrega a senha salva no storage
  Future<void> _loadPassword() async {
    _storedPassword = await _localStorageService.getPassword();
  }

  // Valida a senha digitada pelo usuário
  void _validatePassword() {
    if (_passwordController.text == _storedPassword) {
      // Se a senha estiver correta, limpa o erro e chama a função de sucesso
      setState(() {
        _errorMessage = '';
      });
      widget.onPasswordSuccess();
    } else {
      // Se a senha estiver incorreta, exibe uma mensagem de erro
      setState(() {
        _errorMessage = 'Senha incorreta. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definindo as cores com base no tema (o app ainda não abriu, então o tema padrão é claro)
    const textColor = Colors.black;
    const backgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: textColor),
              const SizedBox(height: 20),
              Text(
                'Digite sua senha',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: textColor.withOpacity(0.4)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: textColor),
                  ),
                ),
                onSubmitted: (_) => _validatePassword(),
              ),
              const SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor,
                  foregroundColor: backgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
