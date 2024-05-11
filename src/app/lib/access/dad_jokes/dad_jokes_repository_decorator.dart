import 'package:app/access/dad_jokes/dad_jokes_repository.dart';
import 'package:app/access/dad_jokes/data/dad_joke_response_data.dart';
import 'package:app/access/dad_jokes/mocks/dad_jokes_data_mock.dart';
import 'package:app/access/mocking/mocking_repository.dart';

class DadJokesRepositoryDecorator implements DadJokesRepository {
  final DadJokesRepository _innerRepository;
  final MockingRepository _mockingRepository;

  DadJokesRepositoryDecorator(this._innerRepository, this._mockingRepository);

  @override
  Future<DadJokeResponseData> getDadJokes() async {
    var isDataMocked = await _mockingRepository.checkMockingEnabled();

    if (isDataMocked) {
      return mockedDadJokeResponse;
    }

    return _innerRepository.getDadJokes();
  }
}
