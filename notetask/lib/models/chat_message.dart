// lib/models/chat_message.dart
enum MessageSender { user, ai }

class ChatMessage {
  final String content;
  final MessageSender sender;

  ChatMessage({required this.content, required this.sender});
}
