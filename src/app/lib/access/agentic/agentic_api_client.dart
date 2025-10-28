import 'package:app/access/agentic/models/chat_message_data.dart';
import 'package:app/access/agentic/models/chat_request_data.dart';
import 'package:app/access/agentic/models/chat_response_data.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'agentic_api_client.g.dart';

/// API client interface for Azure AI agent interactions.
/// 
/// This interface defines the contract for communicating with the Azure AI backend.
abstract class IAgenticApiClient {
  /// Sends a chat message to the AI agent.
  /// 
  /// [sessionId] The unique identifier for the chat session.
  /// [message] The user's message to send.
  /// [history] Optional list of previous messages for context.
  /// 
  /// Returns a [Future] that completes with the AI's response.
  Future<ChatResponseData> sendMessage(
    String sessionId,
    String message,
    List<ChatMessageData>? history,
  );

  /// Starts a new chat session.
  /// 
  /// Returns a [Future] that completes with the new session ID.
  Future<String> createSession();

  /// Deletes a chat session.
  /// 
  /// [sessionId] The unique identifier for the chat session to delete.
  Future<void> deleteSession(String sessionId);
}

/// Retrofit implementation of the agentic API client.
/// 
/// This client communicates with Azure AI services using REST APIs.
@RestApi()
abstract class AgenticApiClient implements IAgenticApiClient {
  factory AgenticApiClient(Dio dio, {String baseUrl}) = _AgenticApiClient;

  @override
  @POST('/api/chat/message')
  Future<ChatResponseData> sendMessage(
    @Body() String sessionId,
    @Body() String message,
    @Body() List<ChatMessageData>? history,
  );

  @override
  @POST('/api/chat/session')
  Future<String> createSession();

  @override
  @DELETE('/api/chat/session/{sessionId}')
  Future<void> deleteSession(@Path() String sessionId);
}
