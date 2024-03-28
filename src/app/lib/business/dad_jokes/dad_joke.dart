import 'package:app/access/dad_jokes/data/dad_joke_content_data.dart';
import 'package:equatable/equatable.dart';

/// Represents a dad joke.
final class DadJoke extends Equatable {
  final String id;
  final String title;
  final String selfText;
  final bool isFavorite;

  const DadJoke({
    required this.id,
    required this.title,
    required this.selfText,
    required this.isFavorite,
  });

  DadJoke.fromData(DadJokeContentData dadJokeContentData, {required bool isFavorite}) : this(
    id: dadJokeContentData.id,
    title: dadJokeContentData.title,
    selfText: dadJokeContentData.selfText,
    isFavorite: isFavorite,
  );

  DadJoke copyWith({
    String? id,
    String? title,
    String? selfText,
    bool? isFavorite,
  }) =>
      DadJoke(
        id: id ?? this.id,
        title: title ?? this.title,
        selfText: selfText ?? this.selfText,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  @override
  List<Object?> get props => [id, title, selfText, isFavorite];
}
