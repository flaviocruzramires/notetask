// Em lib/screens/ai_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:notetask/services/gemini_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _promptController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  String _response = '';
  bool _isLoading = false;

  Future<void> _getGeminiResponse() async {
    final prompt = _promptController.text;
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _geminiService.getResponse(prompt);
      setState(() {
        _response = response;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final iconColor = isLightMode ? Colors.black : Colors.white;
    final textColor = iconColor;
    final bgColor = isLightMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat com IA'),
        backgroundColor: bgColor,
        foregroundColor: iconColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _response.isEmpty ? 'Aguardando sua pergunta...' : _response,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: CircularProgressIndicator(),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Digite seu prompt aqui...',
                      hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: iconColor),
                  onPressed: _isLoading ? null : _getGeminiResponse,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
