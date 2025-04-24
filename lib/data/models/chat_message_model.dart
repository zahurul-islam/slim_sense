class ChatMessageModel {
  final String id;
  final String content;
  final String role; // 'user' or 'assistant'
  final DateTime timestamp;
  
  ChatMessageModel({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });
  
  Map<String, String> toApiFormat() {
    return {
      'role': role,
      'content': content,
    };
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      role: map['role'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
    );
  }
}
