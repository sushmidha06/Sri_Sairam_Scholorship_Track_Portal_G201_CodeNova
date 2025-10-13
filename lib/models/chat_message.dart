class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final bool isTyping;
  final DateTime timestamp;
  final int? typingId;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
    this.typingId,
    String? id,
    DateTime? timestamp,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    bool? isTyping,
    int? typingId,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isTyping: isTyping ?? this.isTyping,
      typingId: typingId ?? this.typingId,
      timestamp: timestamp,
    );
  }
}
