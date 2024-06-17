import 'package:app/access/dad_jokes/dad_jokes_mocked_repository.dart';
import 'package:app/access/dad_jokes/dad_jokes_repository.dart';
import 'package:app/access/dad_jokes/data/dad_joke_content_data.dart';
import 'package:app/access/dad_jokes/favorite_dad_jokes_mocked_repository.dart';
import 'package:app/access/dad_jokes/favorite_dad_jokes_repository.dart';
import 'package:app/access/dad_jokes/mocks/dad_jokes_list_mock.dart';
import 'package:app/access/review_source/custom_review_service.dart';
import 'package:app/access/review_source/custom_review_settings.dart';
import 'package:app/access/review_source/memory_review_settings_source.dart';
import 'package:app/business/dad_jokes/dad_joke.dart';
import 'package:app/business/dad_jokes/dad_jokes_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import 'package:review_service/src/review_service/review_service.dart';
import 'package:review_service/src/review_service/logging_review_prompter.dart';
import 'package:review_service/src/review_service/review_condition_builder.dart';

void main() {
  late CustomReviewService reviewService;
  late DadJokesRepository dadJokesRepository;
  late FavoriteDadJokesRepository favoriteDadJokesRepository;
  late DadJokesService SUT;
  late Logger logger;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    logger = Logger();
    reviewService = CustomReviewService(
      ReviewService<CustomReviewSettings>(
        logger: logger,
        reviewPrompter: LoggingReviewPrompter(),
        reviewSettingsSource: CustomMemoryReviewSettingsSource(),
        reviewConditionsBuilder: ReviewConditionsBuilderImplementation(),
      ),
    );
    dadJokesRepository = DadJokesMockedRepository();
    favoriteDadJokesRepository = FavoriteDadJokesMockedRepository();

    SUT = DadJokesService(
      reviewService,
      dadJokesRepository,
      favoriteDadJokesRepository,
      logger,
    );
  });

  test('Get jokes', () async {
    // Arrange
    var mockedJokesList = getMockedDadJokesList().map(
      (dadJokeChildData) {
        return DadJoke(
          id: dadJokeChildData.id,
          title: dadJokeChildData.title,
          text: dadJokeChildData.selfText,
          isFavorite: getMockedFavoriteDadJokesList().any(
            (favoriteDadJoke) => favoriteDadJoke.id == dadJokeChildData.id,
          ),
        );
      },
    ).toList();

    // Act
    var result = await SUT.getDadJokes();

    // Assert
    expect(result, mockedJokesList);
  });

  group("favorites", () {
    test('Get all favorite jokes', () async {
      // Arrange
      var mockedJokesList = getMockedFavoriteDadJokesList()
          .map(
            (favoriteDadJoke) => DadJoke.fromData(
              favoriteDadJoke,
              isFavorite: true,
            ),
          )
          .toList();

      // Act
      var result = await SUT.getFavoriteDadJokes();

      // Assert
      expect(result, mockedJokesList);
    });

    test('Add a joke to the list of favorites', () async {
      // Arrange
      var dadJoke = const DadJoke(
        id: '1',
        title: 'title',
        text: 'text',
        isFavorite: false,
      );

      var expectedJokes =
          await favoriteDadJokesRepository.getFavoriteDadJokes();
      expectedJokes.add(
        DadJokeContentData(
          id: dadJoke.id,
          title: dadJoke.title,
          selfText: dadJoke.text,
        ),
      );

      // Act
      await SUT.addFavoriteDadJoke(dadJoke);

      // Assert
      var newSavedJokes =
          await favoriteDadJokesRepository.getFavoriteDadJokes();

      expect(newSavedJokes[newSavedJokes.length - 1].id,
          expectedJokes[expectedJokes.length - 1].id);
    });

    test('Remove a favorite joke', () async {
      // Arrange
      var dadJoke = const DadJoke(
        id: '17urj7q',
        title:
            'Tampax have released a new tampon, with tinsel instead of string.',
        text: 'Just in time for the holiday period.',
        isFavorite: true,
      );

      var dadJokesData = DadJokeContentData(
        id: dadJoke.id,
        title: dadJoke.title,
        selfText: dadJoke.text,
      );

      // Act
      await SUT.removeFavoriteDadJoke(dadJoke);

      // Assert
      var actualJokes = await favoriteDadJokesRepository.getFavoriteDadJokes();

      expect(actualJokes.contains(dadJokesData), false);
    });
  });
}
