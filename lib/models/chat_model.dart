import 'dart:convert';

class Message {
  final String id;
  final String sender;
  final String receiver;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      sender: json['sender'] ?? '',
      receiver: json['receiver'] ?? '',
      text: json['text'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ChatResponse {
  final bool success;
  final String message;
  final List<Message> messages;
  final Map<String, dynamic> user;

  ChatResponse({
    required this.success,
    required this.message,
    required this.messages,
    required this.user,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      messages: (json['messages'] as List? ?? []).map((item) => Message.fromJson(item)).toList(),
      user: json['user'] as Map<String, dynamic>? ?? {},
    );
  }
}