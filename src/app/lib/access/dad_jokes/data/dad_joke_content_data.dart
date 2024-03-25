import 'package:json_annotation/json_annotation.dart';

part 'dad_joke_content_data.g.dart';

@JsonSerializable()
final class DadJokeContentData {
  final String id;
  final String title;

  @JsonKey(name: 'selftext')
  final String selfText;

  const DadJokeContentData({
    required this.id,
    required this.title,
    required this.selfText,
  });

  factory DadJokeContentData.fromJson(Map<String, dynamic> json) =>
      _$DadJokeContentDataFromJson(json);

      Map<String, dynamic> toJson() => _$DadJokeContentDataToJson(this);
}
