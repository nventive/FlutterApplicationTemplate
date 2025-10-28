import 'package:app/business/agentic/agentic_service.dart';
import 'package:app/business/agentic/models/chat_message.dart';
import 'package:app/business/agentic/models/chat_session.dart';
import 'package:app/presentation/mvvm/view_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// ViewModel for the AI Agent Chat page.
/// 
/// This ViewModel manages the state and logic for the chat interface,
/// including sending messages, displaying responses, and managing the conversation history.
class AgenticChatViewModel extends ViewModel {
  final IAgenticService _agenticService;
  final TextEditingController messageController = TextEditingController();

  AgenticChatViewModel()
      : _agenticService = GetIt.I<IAgenticService>() {
    // Initialize with a new session
    _agenticService.createNewSession();
  }

  /// Gets the current chat session from the stream.
  ChatSession? get session => getFromStream(
        'session',
        () => _agenticService.getAndObserveChatSession(),
        null,
      );

  /// Gets the list of messages in the current session.
  List<ChatMessage> get messages => session?.messages ?? [];

  /// Indicates whether the agent is currently processing a message.
  bool get isLoading => session?.isLoading ?? false;

  /// Gets the last error message, if any.
  String? get lastError => session?.lastError;

  /// Indicates whether the send button should be enabled.
  bool get canSendMessage => 
      messageController.text.trim().isNotEmpty && !isLoading;

  /// Sends the current message to the AI agent.
  Future<void> sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;

    // Clear the input field immediately
    messageController.clear();
    notifyListeners();

    try {
      await _agenticService.sendMessage(message);
    } catch (e) {
      // Error is already handled in the service and reflected in session state
      debugPrint('Error sending message: $e');
    }
  }

  /// Clears the current chat session and starts a new one.
  Future<void> clearChat() async {
    await _agenticService.clearSession();
    await _agenticService.createNewSession();
    messageController.clear();
    notifyListeners();
  }

  /// Called when the message input field changes.
  void onMessageChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
