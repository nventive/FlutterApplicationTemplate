import 'package:json_annotation/json_annotation.dart';

part 'chat_response_data.g.dart';

/// Data transfer object for AI agent responses.
@JsonSerializable()
class ChatResponseData {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'role')
  final String role;

  @JsonKey(name: 'timestamp')
  final String? timestamp;

  @JsonKey(name: 'model')
  final String? model;

  @JsonKey(name: 'usage')
  final Map<String, dynamic>? usage;

  ChatResponseData({
    required this.id,
    required this.content,
    required this.role,
    this.timestamp,
    this.model,
    this.usage,
  });

  factory ChatResponseData.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatResponseDataToJson(this);
}
