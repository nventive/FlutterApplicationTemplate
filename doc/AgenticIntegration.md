# Azure AI Agent Integration

This document describes the integration of Azure AI agent capabilities into the Flutter application template.

## Overview

The agentic integration provides conversational AI capabilities powered by Azure AI services. Users can interact with an AI assistant through a chat interface, asking questions and receiving intelligent responses.

## Architecture

The agentic feature follows the template's three-layer architecture:

### Access Layer (DAL)
- **Location**: `lib/access/agentic/`
- **Purpose**: Handles communication with Azure AI services
- **Key Components**:
  - `IAgenticApiClient`: Interface defining API contract
  - `AgenticApiClient`: Retrofit implementation for production
  - `AgenticApiClientMock`: Mock implementation for development and testing
  - Data models: `ChatMessageData`, `ChatResponseData`, `ChatRequestData`

### Business Layer
- **Location**: `lib/business/agentic/`
- **Purpose**: Contains business logic and domain models
- **Key Components**:
  - `IAgenticService`: Service interface
  - `AgenticService`: Implementation managing chat sessions and message flow
  - Business models: `ChatMessage`, `ChatSession`, `MessageRole`

### Presentation Layer
- **Location**: `lib/presentation/agentic/`
- **Purpose**: User interface and view logic
- **Key Components**:
  - `AgenticChatPage`: Main chat interface
  - `AgenticChatViewModel`: MVVM ViewModel managing UI state
  - Widgets: `ChatMessageBubble`, `ChatInputField`

## Features

- **Real-time Chat**: Interactive conversation with AI assistant
- **Session Management**: Maintains conversation context across messages
- **Message History**: Displays full conversation history
- **Loading States**: Visual feedback during AI processing
- **Error Handling**: Graceful error messages when issues occur
- **Clear Chat**: Ability to start fresh conversations

## Configuration

### Environment Variables

Add the following variables to your `.env.*` files:

```env
# Azure AI Configuration
AZURE_AI_ENDPOINT=https://your-endpoint.openai.azure.com/
AZURE_AI_API_KEY=your-api-key-here
AZURE_AI_DEPLOYMENT=your-deployment-name
```

### Dependency Injection

The agentic services are registered in `main.dart`:

```dart
// Register API Client (mock or real)
GetIt.I.registerSingleton<IAgenticApiClient>(
  AgenticApiClientMock(), // Replace with AgenticApiClient for production
);

// Register Service
GetIt.I.registerSingleton<IAgenticService>(
  AgenticService(GetIt.I.get<IAgenticApiClient>()),
);
```

### Switching Between Mock and Real Implementation

**Development/Testing** (using mock):
```dart
GetIt.I.registerSingleton<IAgenticApiClient>(AgenticApiClientMock());
```

**Production** (using Azure AI):
```dart
GetIt.I.registerSingleton<IAgenticApiClient>(
  AgenticApiClient(
    GetIt.I.get<Dio>(),
    baseUrl: dotenv.env["AZURE_AI_ENDPOINT"]!,
  ),
);
```

## Usage

### Navigation

The AI Chat page is accessible via the bottom navigation bar (third tab) or programmatically:

```dart
context.go(agenticChatPagePath);
```

### Service Usage

Access the agentic service from any ViewModel:

```dart
final agenticService = GetIt.I<IAgenticService>();

// Send a message
await agenticService.sendMessage('Hello, AI!');

// Observe session state
agenticService.getAndObserveChatSession().listen((session) {
  // Handle session updates
});

// Get message history
final messages = agenticService.getMessageHistory();
```

## Azure AI Setup

### Prerequisites

1. **Azure Subscription**: An active Azure subscription
2. **Azure OpenAI Resource**: Created in Azure Portal
3. **Deployment**: A GPT model deployment (e.g., GPT-4, GPT-3.5-turbo)
4. **Credentials**: API key and endpoint URL

### Authentication

The template assumes you have Azure credentials configured via `az login`. For production apps, consider using:

- **Managed Identity**: For apps running in Azure
- **Service Principal**: For CI/CD pipelines
- **DefaultAzureCredential**: Automatically selects the best authentication method

### API Implementation

When implementing the real API client, structure requests as follows:

```dart
@POST('/openai/deployments/{deploymentId}/chat/completions')
Future<ChatResponseData> sendMessage(
  @Path('deploymentId') String deploymentId,
  @Body() ChatRequestData request,
  @Query('api-version') String apiVersion,
);
```

## Testing

### Unit Tests

Test the business logic independently:

```dart
test('AgenticService sends message successfully', () async {
  final mockClient = MockAgenticApiClient();
  final service = AgenticService(mockClient);
  
  when(mockClient.sendMessage(any, any, any))
      .thenAnswer((_) async => ChatResponseData(...));
  
  await service.sendMessage('Test message');
  
  expect(service.getMessageHistory().length, equals(2)); // user + assistant
});
```

### Integration Tests

Test the full flow with the mock API client:

```dart
testWidgets('Chat page sends and displays messages', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.byIcon(Icons.chat));
  await tester.pumpAndSettle();
  
  await tester.enterText(find.byType(TextField), 'Hello');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pumpAndSettle();
  
  expect(find.text('Hello'), findsOneWidget);
  expect(find.byType(ChatMessageBubble), findsNWidgets(2));
});
```

## Best Practices

1. **Error Handling**: Always wrap API calls in try-catch blocks
2. **Loading States**: Show visual feedback during async operations
3. **Message Validation**: Validate user input before sending
4. **Session Management**: Clear sensitive data when users log out
5. **Rate Limiting**: Implement client-side throttling for API calls
6. **Costs**: Monitor Azure AI usage to control costs

## Troubleshooting

### Common Issues

**Messages not sending**:
- Check network connectivity
- Verify Azure AI endpoint and API key
- Ensure deployment name is correct

**Mock responses not appearing**:
- Verify `AgenticApiClientMock` is registered in DI
- Check console for error messages

**UI not updating**:
- Ensure ViewModel is calling `notifyListeners()`
- Verify stream subscriptions are active

## Future Enhancements

Potential improvements for the agentic feature:

- **Streaming Responses**: Display AI responses token-by-token
- **Multi-modal Support**: Handle images and files
- **Conversation Persistence**: Save chat history to local storage
- **Custom Instructions**: Allow users to set system prompts
- **Voice Input**: Speech-to-text integration
- **Export Conversations**: Save chats as text or PDF

## References

- [Azure OpenAI Service Documentation](https://learn.microsoft.com/en-us/azure/ai-services/openai/)
- [Azure AI Flutter SDK](https://pub.dev/packages/azure_ai)
- [Flutter MVVM Pattern](../Architecture.md)
- [Dependency Injection](../DependencyInjection.md)
