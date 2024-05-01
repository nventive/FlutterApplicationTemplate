import 'package:app/access/forced_update/minimum_version_repository.dart';
import 'package:app/access/forced_update/minimum_version_repository_mock.dart';
import 'package:app/business/dad_jokes/dad_joke.dart';
import 'package:app/business/dad_jokes/dad_jokes_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// A dad joke list item.
final class DadJokeListItem extends StatelessWidget {
  /// The dad jokes service used to add or remove favorite.
  final _dadJokesService = GetIt.I<DadJokesService>();
  final _minimumRequiredService = GetIt.I<MinimumVersionRepository>();

  /// The dad joke.
  final DadJoke dadJoke;

  DadJokeListItem({super.key, required this.dadJoke});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(dadJoke.title),
        subtitle: Text(dadJoke.text),
        trailing: dadJoke.isFavorite
            ? const Icon(
                Icons.favorite,
                color: Colors.red,
              )
            : const Icon(
                Icons.favorite_border,
              ),
        titleAlignment: ListTileTitleAlignment.top,
        contentPadding: const EdgeInsets.all(16),
        onTap: () async {
          if (_minimumRequiredService is MinimumVersionRepositoryMock) {
            _minimumRequiredService.updateMinimumVersion();
          }

          if (dadJoke.isFavorite) {
            await _dadJokesService.removeFavoriteDadJoke(dadJoke);
          } else {
            await _dadJokesService.addFavoriteDadJoke(dadJoke);
          }
        },
      ),
    );
  }
}
