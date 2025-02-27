import 'package:app/business/dad_jokes/dad_joke.dart';
import 'package:app/business/dad_jokes/dad_jokes_service.dart';
import 'package:app/presentation/mvvm/view_model.dart';
import 'package:get_it/get_it.dart';

class DadJokesPageViewModel extends ViewModel {
  final _dadJokesService = GetIt.I<DadJokesService>();

  Stream<List<DadJoke>> get dadJokesStream =>
      getLazy("dadJokesStream", () => _dadJokesService.dadJokesStream);

  Future<void> toggleIsFavorite(DadJoke dadJoke) async {
    if (dadJoke.isFavorite) {
      await _dadJokesService.removeFavoriteDadJoke(dadJoke);
    } else {
      await _dadJokesService.addFavoriteDadJoke(dadJoke);
    }
  }
}
