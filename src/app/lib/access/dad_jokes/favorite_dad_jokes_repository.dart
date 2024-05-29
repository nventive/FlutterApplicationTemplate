import 'dart:convert';

import 'package:app/access/dad_jokes/data/dad_joke_content_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interface for the favorite dad jokes repository.
abstract interface class FavoriteDadJokesRepository {
  factory FavoriteDadJokesRepository() = _FavoriteDadJokesRepository;

  /// Gets the favorite dad jokes.
  Future<List<DadJokeContentData>> getFavoriteDadJokes();

  /// Sets the favorite dad jokes.
  Future<void> setFavoriteDadJokes(List<DadJokeContentData> favoriteDadJokes);
}

/// Implementation of [FavoriteDadJokesRepository].
final class _FavoriteDadJokesRepository implements FavoriteDadJokesRepository {
  /// The key used to store favorite dad jokes in shared preferences.
  final String _favoriteDadJokesKey = 'favoriteDadJokes';

  _FavoriteDadJokesRepository();

  @override
  Future<List<DadJokeContentData>> getFavoriteDadJokes() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final favoriteDadJokesJson = sharedPreferences.getStringList(_favoriteDadJokesKey) ?? [];

    return favoriteDadJokesJson
        .map(
          (favoriteDadJokeJson) => DadJokeContentData.fromJson(jsonDecode(favoriteDadJokeJson)),
        )
        .toList();
  }

  @override
  Future<void> setFavoriteDadJokes(List<DadJokeContentData> favoriteDadJokes) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setStringList(
      _favoriteDadJokesKey,
      favoriteDadJokes.map((dadJoke) => jsonEncode(dadJoke)).toList(),
    );
  }
}
