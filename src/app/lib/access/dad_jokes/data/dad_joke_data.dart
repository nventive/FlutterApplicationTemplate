import 'package:app/access/dad_jokes/data/dad_joke_child_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dad_joke_data.g.dart';

@JsonSerializable(createToJson: false)
final class DadJokeData {
  @JsonKey(name: 'children')
  final List<DadJokeChildData> dadJokeChildrenData;

  const DadJokeData({required this.dadJokeChildrenData});

  factory DadJokeData.fromJson(Map<String, dynamic> json) => _$DadJokeDataFromJson(json);
}