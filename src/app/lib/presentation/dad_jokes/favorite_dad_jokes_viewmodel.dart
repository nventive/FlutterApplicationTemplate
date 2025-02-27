import 'package:app/business/dad_jokes/dad_joke.dart';
import 'package:app/business/dad_jokes/dad_jokes_service.dart';
import 'package:app/presentation/mvvm/view_model.dart';
import 'package:get_it/get_it.dart';

class FavoriteDadJokesViewModel extends ViewModel {
  final _dadJokesService = GetIt.I<DadJokesService>();

  Stream<List<DadJoke>> get favorites => getLazy(
      "favorites",
      () => _dadJokesService.dadJokesStream.map((List<DadJoke> jokes) =>
          jokes.where((DadJoke joke) => joke.isFavorite).toList()));

  Future<void> toggleIsFavorite(DadJoke dadJoke) async {
    if (dadJoke.isFavorite) {
      await _dadJokesService.removeFavoriteDadJoke(dadJoke);
    } else {
      await _dadJokesService.addFavoriteDadJoke(dadJoke);
    }
  }
}
