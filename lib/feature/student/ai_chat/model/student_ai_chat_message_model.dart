enum StudentAiChatMessageType { text, audio, file }

class StudentAiChatMessageModel {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? audioUrl;
  final List<String>? fileUrls;

  StudentAiChatMessageModel({
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.audioUrl,
    this.fileUrls,
  });
}
