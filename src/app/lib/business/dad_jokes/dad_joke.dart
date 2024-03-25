import 'package:app/access/dad_jokes/data/dad_joke_content_data.dart';
import 'package:equatable/equatable.dart';

/// Represents a dad joke.
final class DadJoke extends Equatable {
  final String id;
  final String title;
  final String text;
  final bool isFavorite;

  const DadJoke({
    required this.id,
    required this.title,
    required this.text,
    required this.isFavorite,
  });

  DadJoke.fromData(DadJokeContentData dadJokeContentData, {required bool isFavorite}) : this(
    id: dadJokeContentData.id,
    title: dadJokeContentData.title,
    text: dadJokeContentData.selfText,
    isFavorite: isFavorite,
  );

  DadJoke copyWith({
    String? id,
    String? title,
    String? text,
    bool? isFavorite,
  }) =>
      DadJoke(
        id: id ?? this.id,
        title: title ?? this.title,
        text: text ?? this.text,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  @override
  List<Object?> get props => [id, title, text, isFavorite];
}
