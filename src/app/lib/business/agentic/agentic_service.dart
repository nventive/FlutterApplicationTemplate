import 'dart:async';
import 'package:app/access/agentic/agentic_api_client.dart';
import 'package:app/business/agentic/models/chat_message.dart';
import 'package:app/business/agentic/models/chat_session.dart';
import 'package:rxdart/rxdart.dart';

/// Service that handles AI agent interactions using Azure AI.
/// 
/// This service manages chat sessions, message history, and communication
/// with the Azure AI backend through the API client.
abstract class IAgenticService {
  /// Gets and observes the current chat session.
  /// 
  /// Returns an observable stream of the current [ChatSession].
  Stream<ChatSession?> getAndObserveChatSession();

  /// Gets the current chat session synchronously.
  /// 
  /// Returns the current [ChatSession] or null if no session exists.
  ChatSession? getCurrentSession();

  /// Sends a message to the AI agent.
  /// 
  /// [message] The user message to send.
  /// Returns a [Future] that completes when the message is sent and response is received.
  Future<void> sendMessage(String message);

  /// Creates a new chat session.
  /// 
  /// Clears any existing session and starts fresh.
  Future<void> createNewSession();

  /// Clears the current chat session.
  Future<void> clearSession();

  /// Gets the message history for the current session.
  /// 
  /// Returns a list of [ChatMessage] objects in chronological order.
  List<ChatMessage> getMessageHistory();
}

/// Implementation of [IAgenticService] that interacts with Azure AI.
class AgenticService implements IAgenticService {
  final IAgenticApiClient _apiClient;
  final BehaviorSubject<ChatSession?> _sessionSubject;

  AgenticService(this._apiClient) 
      : _sessionSubject = BehaviorSubject<ChatSession?>.seeded(null);

  @override
  Stream<ChatSession?> getAndObserveChatSession() {
    return _sessionSubject.stream;
  }

  @override
  ChatSession? getCurrentSession() {
    return _sessionSubject.value;
  }

  @override
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }

    var session = _sessionSubject.value;
    if (session == null) {
      // Create a new session if none exists
      await createNewSession();
      session = _sessionSubject.value!;
    }

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatMessage>.from(session.messages)
      ..add(userMessage);

    _sessionSubject.add(session.copyWith(
      messages: updatedMessages,
      isLoading: true,
    ));

    try {
      // Send to API and get response
      final response = await _apiClient.sendMessage(
        session.sessionId,
        message,
        session.messages.map((m) => m.toData()).toList(),
      );

      // Add assistant response
      final assistantMessage = ChatMessage(
        id: response.id,
        content: response.content,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      final finalMessages = List<ChatMessage>.from(updatedMessages)
        ..add(assistantMessage);

      _sessionSubject.add(session.copyWith(
        messages: finalMessages,
        isLoading: false,
      ));
    } catch (e) {
      // Handle error by updating session state
      _sessionSubject.add(session.copyWith(
        isLoading: false,
        lastError: e.toString(),
      ));
      rethrow;
    }
  }

  @override
  Future<void> createNewSession() async {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final newSession = ChatSession(
      sessionId: sessionId,
      messages: [],
      createdAt: DateTime.now(),
      isLoading: false,
    );

    _sessionSubject.add(newSession);
  }

  @override
  Future<void> clearSession() async {
    _sessionSubject.add(null);
  }

  @override
  List<ChatMessage> getMessageHistory() {
    final session = _sessionSubject.value;
    return session?.messages ?? [];
  }

  /// Disposes of the service and closes streams.
  void dispose() {
    _sessionSubject.close();
  }
}
