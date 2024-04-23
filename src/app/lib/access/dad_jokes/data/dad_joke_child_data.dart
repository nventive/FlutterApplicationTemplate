import 'package:app/access/dad_jokes/data/dad_joke_content_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dad_joke_child_data.g.dart';

@JsonSerializable(createToJson: false)
final class DadJokeChildData {
  @JsonKey(name: 'data')
  final DadJokeContentData dadJokeContentData;

  const DadJokeChildData({required this.dadJokeContentData});

  factory DadJokeChildData.fromJson(Map<String, dynamic> json) => _$DadJokeChildDataFromJson(json);
}