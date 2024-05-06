import 'package:app/access/dad_jokes/dad_jokes_repository.dart';
import 'package:app/access/dad_jokes/data/dad_joke_response_data.dart';

class DadJokesRepositoryDecorator {
  final DadJokesRepository _innerRepository;

  DadJokesRepositoryDecorator(this._innerRepository);

  @override
  Future<DadJokeResponseData> getDadJokes() {
    // TODO: implement getDadJokes
    throw UnimplementedError();
  }
}
