import 'package:json_annotation/json_annotation.dart';

part 'chat_message_data.g.dart';

/// Data transfer object for chat messages.
/// 
/// This class is used for serialization/deserialization when communicating
/// with the API.
@JsonSerializable()
class ChatMessageData {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'role')
  final String role;

  @JsonKey(name: 'timestamp')
  final String timestamp;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  ChatMessageData({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.metadata,
  });

  factory ChatMessageData.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageDataToJson(this);
}
