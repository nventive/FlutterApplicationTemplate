import 'package:app/access/dad_jokes/data/dad_joke_response_data.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'dad_jokes_repository.g.dart';

@RestApi(baseUrl: 'https://www.reddit.com/r/dadjokes')
abstract interface class DadJokesRepository {
  factory DadJokesRepository(Dio dio, {String baseUrl}) = _DadJokesRepository;

  @GET('/top.json')
  Future<DadJokeResponseData> getDadJokes();
}
