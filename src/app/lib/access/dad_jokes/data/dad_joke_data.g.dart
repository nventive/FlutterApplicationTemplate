// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dad_joke_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DadJokeData _$DadJokeDataFromJson(Map<String, dynamic> json) => DadJokeData(
      dadJokeChildrenData: (json['children'] as List<dynamic>)
          .map((e) => DadJokeChildData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
