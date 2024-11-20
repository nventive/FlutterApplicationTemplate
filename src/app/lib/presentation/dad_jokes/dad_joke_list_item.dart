import 'package:app/business/bugsee/bugsee_manager.dart';
import 'package:app/business/dad_jokes/dad_joke.dart';
import 'package:app/business/dad_jokes/dad_jokes_service.dart';
import 'package:bugsee_flutter/bugsee_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// A dad joke list item.
final class DadJokeListItem extends StatelessWidget {
  /// The dad jokes service used to add or remove favorite.
  final _dadJokesService = GetIt.I<DadJokesService>();
  final _bugseeManager = GetIt.I<BugseeManager>();

  /// The dad joke.
  final DadJoke dadJoke;

  DadJokeListItem({super.key, required this.dadJoke});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: BugseeSecureView(
          enabled: _bugseeManager.bugseeConfigState.isDataObscured,
          child: Text(dadJoke.title),
        ),
        subtitle: BugseeSecureView(
          enabled: _bugseeManager.bugseeConfigState.isDataObscured,
          child: Text(dadJoke.text),
        ),
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
          if (_bugseeManager.onPressExceptionActivated) {
            _bugseeManager.logException(
              exception: Exception(),
              attributes: {
                'id': dadJoke.id,
                'title': dadJoke.title,
              },
            );
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
