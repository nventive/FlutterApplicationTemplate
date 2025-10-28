import 'package:app/access/agentic/agentic_api_client.dart';
import 'package:app/access/agentic/models/chat_message_data.dart';
import 'package:app/access/agentic/models/chat_response_data.dart';

/// Mock implementation of the agentic API client for development and testing.
/// 
/// This mock simulates AI responses without requiring an actual Azure AI backend.
class AgenticApiClientMock implements IAgenticApiClient {
  static const _mockResponses = [
    'Hello! I\'m your AI assistant. How can I help you today?',
    'That\'s an interesting question. Let me think about that...',
    'Based on what you\'ve told me, I would suggest...',
    'I understand what you\'re asking. Here\'s my perspective...',
    'That\'s a great point! Let me elaborate on that...',
  ];

  int _responseIndex = 0;

  @override
  Future<ChatResponseData> sendMessage(
    String sessionId,
    String message,
    List<ChatMessageData>? history,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple mock logic: rotate through predefined responses
    final response = _mockResponses[_responseIndex % _mockResponses.length];
    _responseIndex++;

    // Create a more contextual response if the message contains certain keywords
    String contextualResponse = response;
    if (message.toLowerCase().contains('help')) {
      contextualResponse = 'I\'m here to help! You can ask me questions about '
          'various topics, and I\'ll do my best to provide useful answers.';
    } else if (message.toLowerCase().contains('how are you')) {
      contextualResponse = 'I\'m functioning well, thank you for asking! '
          'How can I assist you today?';
    } else if (message.toLowerCase().contains('thank')) {
      contextualResponse = 'You\'re welcome! Is there anything else I can help you with?';
    }

    return ChatResponseData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: contextualResponse,
      role: 'assistant',
      timestamp: DateTime.now().toIso8601String(),
      model: 'mock-model-v1',
      usage: {
        'prompt_tokens': message.length,
        'completion_tokens': contextualResponse.length,
        'total_tokens': message.length + contextualResponse.length,
      },
    );
  }

  @override
  Future<String> createSession() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock deletion - no action needed
  }
}
