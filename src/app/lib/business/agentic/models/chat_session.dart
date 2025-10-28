import 'package:app/business/agentic/models/chat_message.dart';
import 'package:equatable/equatable.dart';

/// Business model representing a chat session with the AI agent.
/// 
/// A session contains the conversation history and metadata about the interaction.
class ChatSession extends Equatable {
  /// Unique identifier for this session
  final String sessionId;
  
  /// List of messages in this session
  final List<ChatMessage> messages;
  
  /// When this session was created
  final DateTime createdAt;
  
  /// Whether the session is currently processing a request
  final bool isLoading;
  
  /// Last error that occurred, if any
  final String? lastError;

  const ChatSession({
    required this.sessionId,
    required this.messages,
    required this.createdAt,
    this.isLoading = false,
    this.lastError,
  });

  /// Creates a copy of this session with optional field replacements
  ChatSession copyWith({
    String? sessionId,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    bool? isLoading,
    String? lastError,
  }) {
    return ChatSession(
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      isLoading: isLoading ?? this.isLoading,
      lastError: lastError,
    );
  }

  @override
  List<Object?> get props => [sessionId, messages, createdAt, isLoading, lastError];

  @override
  bool get stringify => true;
}
