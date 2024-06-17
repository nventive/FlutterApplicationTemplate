import 'dart:async';

import 'package:app/access/dad_jokes/dad_jokes_repository.dart';
import 'package:app/access/dad_jokes/data/dad_joke_content_data.dart';
import 'package:app/access/dad_jokes/favorite_dad_jokes_repository.dart';
import 'package:app/access/review_source/custom_review_service.dart';
import 'package:app/business/dad_jokes/dad_joke.dart';
import 'package:review_service/src/review_service/review_service.extensions.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

/// Extensions of ReviewService<TReviewSettings>.
extension CustomReviewServiceExtensions on CustomReviewService {
  /// Tracks that the application onboarding has been completed.
  Future<void> trackFavoriteJokesCount() async {
    await updateReviewSettings((reviewSettings) {
      return reviewSettings
          .copyWithFavorite(reviewSettings.favoriteJokesCount + 1);
    });
  }
}

/// Interface for the dad jokes service.
abstract interface class DadJokesService implements Disposable {
  factory DadJokesService(
    CustomReviewService reviewService,
    DadJokesRepository dadJokesRepository,
    FavoriteDadJokesRepository favoriteDadJokesRepository,
    Logger logger,
  ) = _DadJokesService;

  /// Stream of dad jokes.
  Stream<List<DadJoke>> get dadJokesStream;

  /// Get dad jokes.
  Future<List<DadJoke>> getDadJokes();

  /// Get favorite dad jokes.
  Future<List<DadJoke>> getFavoriteDadJokes();

  /// Add a favorite dad joke.
  Future addFavoriteDadJoke(DadJoke joke);

  /// Remove a favorite dad joke.
  Future removeFavoriteDadJoke(DadJoke joke);
}

/// Implementation of [DadJokesService].
final class _DadJokesService implements DadJokesService {
  /// The behavior subject used to notify when dad jokes changed.
  final BehaviorSubject<List<DadJoke>> _dadJokesBehaviorSubject =
      BehaviorSubject();

  /// The repository used to fetch dad jokes.
  final DadJokesRepository _dadJokesRepository;

  /// The repository used to fetch favorite dad jokes.
  final FavoriteDadJokesRepository _favoriteDadJokesRepository;

  final CustomReviewService _reviewService;

  final Logger _logger;

  _DadJokesService(
    CustomReviewService reviewService,
    DadJokesRepository dadJokesRepository,
    FavoriteDadJokesRepository favoriteDadJokesRepository,
    Logger logger,
  )   : _reviewService = reviewService,
        _dadJokesRepository = dadJokesRepository,
        _favoriteDadJokesRepository = favoriteDadJokesRepository,
        _logger = logger {
    getDadJokes().then((dadJokes) => _dadJokesBehaviorSubject.add(dadJokes));
  }

  @override
  Stream<List<DadJoke>> get dadJokesStream => _dadJokesBehaviorSubject.stream;

  @override
  Future<List<DadJoke>> getDadJokes() async {
    final dadJokeResponseData = await _dadJokesRepository.getDadJokes();
    final favoriteDadJokes = await getFavoriteDadJokes();

    return dadJokeResponseData.dadJokeData.dadJokeChildrenData.map(
      (dadJokeChildData) {
        return DadJoke(
          id: dadJokeChildData.dadJokeContentData.id,
          title: dadJokeChildData.dadJokeContentData.title,
          text: dadJokeChildData.dadJokeContentData.selfText,
          isFavorite: favoriteDadJokes.any(
            (favoriteDadJoke) =>
                favoriteDadJoke.id == dadJokeChildData.dadJokeContentData.id,
          ),
        );
      },
    ).toList();
  }

  @override
  Future<List<DadJoke>> getFavoriteDadJokes() async {
    final favoriteDadJokes =
        await _favoriteDadJokesRepository.getFavoriteDadJokes();

    return favoriteDadJokes
        .map(
          (favoriteDadJoke) => DadJoke.fromData(
            favoriteDadJoke,
            isFavorite: true,
          ),
        )
        .toList();
  }

  @override
  Future addFavoriteDadJoke(DadJoke dadJoke) async {
    _logger.d("Start adding ${dadJoke.id} to favorites");

    final favoriteDadJokes =
        await _favoriteDadJokesRepository.getFavoriteDadJokes();

    favoriteDadJokes.add(
      DadJokeContentData(
        id: dadJoke.id,
        title: dadJoke.title,
        selfText: dadJoke.text,
      ),
    );

    _reviewService.trackFavoriteJokesCount();

    await _favoriteDadJokesRepository.setFavoriteDadJokes(favoriteDadJokes);

    _dadJokesBehaviorSubject.add(
      _dadJokesBehaviorSubject.value.map(
        (dJ) {
          if (dJ.id == dadJoke.id) {
            return dJ.copyWith(isFavorite: true);
          }
          return dJ;
        },
      ).toList(),
    );

    _logger.i(" ${dadJoke.id} has been added to favorites");
  }

  @override
  Future removeFavoriteDadJoke(DadJoke dadJoke) async {
    _logger.d("Start removing ${dadJoke.id} from favorites");

    final favoriteDadJokes =
        await _favoriteDadJokesRepository.getFavoriteDadJokes();

    await _favoriteDadJokesRepository.setFavoriteDadJokes(
      favoriteDadJokes.where((dJ) => dJ.id != dadJoke.id).toList(),
    );

    _dadJokesBehaviorSubject.add(
      _dadJokesBehaviorSubject.value.map(
        (dJ) {
          if (dJ.id == dadJoke.id) {
            return dJ.copyWith(isFavorite: false);
          }
          return dJ;
        },
      ).toList(),
    );

    _logger.i(" ${dadJoke.id} has been removed from favorites");
  }

  @override
  FutureOr onDispose() async {
    await _dadJokesBehaviorSubject.close();
  }
}
