import 'package:app/access/dad_jokes/data/dad_joke_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dad_joke_response_data.g.dart';

@JsonSerializable(createToJson: false)
final class DadJokeResponseData {
  @JsonKey(name: 'data')
  final DadJokeData dadJokeData;

  const DadJokeResponseData({required this.dadJokeData});

  factory DadJokeResponseData.fromJson(Map<String, dynamic> json) => _$DadJokeResponseDataFromJson(json);
}
