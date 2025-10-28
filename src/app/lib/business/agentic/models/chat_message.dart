import 'package:app/access/agentic/models/chat_message_data.dart';
import 'package:equatable/equatable.dart';

/// Represents the role of a message sender in the chat.
enum MessageRole {
  /// Message from the user
  user,
  
  /// Message from the AI assistant
  assistant,
  
  /// System message
  system,
}

/// Business model representing a single chat message.
/// 
/// This is an immutable model that represents a message in the chat conversation.
class ChatMessage extends Equatable {
  /// Unique identifier for the message
  final String id;
  
  /// The content/text of the message
  final String content;
  
  /// The role of the message sender
  final MessageRole role;
  
  /// When the message was created
  final DateTime timestamp;
  
  /// Optional metadata associated with the message
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.metadata,
  });

  /// Creates a copy of this message with optional field replacements
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converts this business model to a data transfer object
  ChatMessageData toData() {
    return ChatMessageData(
      id: id,
      content: content,
      role: role.name,
      timestamp: timestamp.toIso8601String(),
      metadata: metadata,
    );
  }

  /// Creates a business model from a data transfer object
  factory ChatMessage.fromData(ChatMessageData data) {
    return ChatMessage(
      id: data.id,
      content: data.content,
      role: _parseRole(data.role),
      timestamp: DateTime.parse(data.timestamp),
      metadata: data.metadata,
    );
  }

  static MessageRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return MessageRole.user;
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.user;
    }
  }

  @override
  List<Object?> get props => [id, content, role, timestamp, metadata];

  @override
  bool get stringify => true;
}
