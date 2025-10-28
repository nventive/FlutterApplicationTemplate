import 'package:json_annotation/json_annotation.dart';
import 'package:app/access/agentic/models/chat_message_data.dart';

part 'chat_request_data.g.dart';

/// Data transfer object for chat requests sent to the API.
@JsonSerializable()
class ChatRequestData {
  @JsonKey(name: 'sessionId')
  final String sessionId;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'history')
  final List<ChatMessageData>? history;

  @JsonKey(name: 'maxTokens')
  final int? maxTokens;

  @JsonKey(name: 'temperature')
  final double? temperature;

  ChatRequestData({
    required this.sessionId,
    required this.message,
    this.history,
    this.maxTokens,
    this.temperature,
  });

  factory ChatRequestData.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRequestDataToJson(this);
}
