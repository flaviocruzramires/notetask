import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definindo as cores com base no tema atual
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final textColor = isLightMode ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App'),
        backgroundColor: isLightMode ? Colors.white : Colors.black,
        foregroundColor: textColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.note_alt_outlined, size: 80),
            const SizedBox(height: 20),
            Text(
              'NoteTask',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Versão 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'O NoteTask é um aplicativo simples e intuitivo para organizar suas anotações e gerenciar tarefas. Mantenha-se produtivo e focado no que realmente importa.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Desenvolvido por [Seu Nome]',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: textColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}