import 'package:app/business/agentic/models/chat_message.dart';
import 'package:app/presentation/agentic/agentic_chat_view_model.dart';
import 'package:app/presentation/agentic/widgets/chat_message_bubble.dart';
import 'package:app/presentation/agentic/widgets/chat_input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The main chat page for interacting with the AI agent.
/// 
/// This page provides a conversational interface where users can chat
/// with an AI assistant powered by Azure AI services.
class AgenticChatPage extends StatelessWidget {
  const AgenticChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AgenticChatViewModel(),
      child: const _AgenticChatPageContent(),
    );
  }
}

class _AgenticChatPageContent extends StatefulWidget {
  const _AgenticChatPageContent({Key? key}) : super(key: key);

  @override
  State<_AgenticChatPageContent> createState() => _AgenticChatPageContentState();
}

class _AgenticChatPageContentState extends State<_AgenticChatPageContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AgenticChatViewModel>();

    // Scroll to bottom when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Agent Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await viewModel.clearChat();
            },
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Error banner
          if (viewModel.lastError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Error: ${viewModel.lastError}',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: viewModel.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      final message = viewModel.messages[index];
                      return ChatMessageBubble(message: message);
                    },
                  ),
          ),

          // Loading indicator
          if (viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('AI is thinking...'),
                ],
              ),
            ),

          // Input field
          ChatInputField(
            controller: viewModel.messageController,
            onSend: viewModel.sendMessage,
            onChanged: (_) => viewModel.onMessageChanged(),
            enabled: !viewModel.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
