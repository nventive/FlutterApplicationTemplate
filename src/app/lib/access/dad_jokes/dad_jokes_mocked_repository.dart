import 'package:app/access/dad_jokes/dad_jokes_repository.dart';
import 'package:app/access/dad_jokes/data/dad_joke_response_data.dart';
import 'package:app/access/dad_jokes/mocks/dad_jokes_data_mock.dart';

final class DadJokesMockedRepository implements DadJokesRepository {

  DadJokesMockedRepository();  

  @override
  Future<DadJokeResponseData> getDadJokes() async {
      return mockedDadJokeResponse;
  }
}
