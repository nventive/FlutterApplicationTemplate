import 'package:app/access/dad_jokes/data/dad_joke_content_data.dart';
import 'package:app/access/dad_jokes/favorite_dad_jokes_repository.dart';
import 'package:app/access/dad_jokes/mocks/dad_jokes_list_mock.dart';

final class FavoriteDadJokesMockedRepository
    implements FavoriteDadJokesRepository {
  List<DadJokeContentData> mockedFavoriteDadJokesList =
      getMockedFavoriteDadJokesList();

  FavoriteDadJokesMockedRepository();

  @override
  Future<List<DadJokeContentData>> getFavoriteDadJokes() async {
    var favJokes = [...mockedFavoriteDadJokesList];

    await Future.value();

    return favJokes;
  }

  @override
  Future<void> setFavoriteDadJokes(List<DadJokeContentData> favoriteDadJokes) async {
     mockedFavoriteDadJokesList = favoriteDadJokes;

     return Future.value();
  }
}
