// lib/screens/ai_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:notetask/services/gemini_service.dart';
import 'package:notetask/models/chat_message.dart';
import 'package:flutter/services.dart'; // Importe para usar Clipboard

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _promptController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _promptController.text = widget.initialQuery!;
      _sendMessage();
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(content: prompt, sender: MessageSender.user));
      _isLoading = true;
    });

    _promptController.clear();

    try {
      final response = await _geminiService.getResponse(prompt);
      setState(() {
        _messages.add(ChatMessage(content: response, sender: MessageSender.ai));
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            content: 'Erro: Não foi possível obter a resposta da IA.',
            sender: MessageSender.ai,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copiado para a área de transferência!'),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.onBackground.withOpacity(0.6),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat com IA'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1,
      ),
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, colorScheme);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          _buildInputArea(colorScheme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ColorScheme colorScheme) {
    final bool isUser = message.sender == MessageSender.user;

    Widget content = Text(
      message.content,
      style: TextStyle(
        color: isUser ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      ),
    );

    // Se a mensagem for da IA, adiciona o ícone de copiar
    if (!isUser) {
      content = Stack(
        clipBehavior:
            Clip.none, // Permite que o ícone fique fora dos limites do balão
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              right: 28,
            ), // Adiciona padding para o ícone
            child: Text(
              message.content,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          Positioned(
            top: -4,
            right: -20,
            child: IconButton(
              icon: Icon(
                Icons.copy,
                size: 16,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              onPressed: () => _copyToClipboard(message.content),
            ),
          ),
        ],
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: content,
      ),
    );
  }

  Widget _buildInputArea(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promptController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: colorScheme.primary),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
