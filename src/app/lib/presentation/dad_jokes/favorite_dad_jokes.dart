import 'package:app/business/dad_jokes/dad_joke.dart';
import 'package:app/business/dad_jokes/dad_jokes_service.dart';
import 'package:app/presentation/dad_jokes/dad_joke_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// The favorite dad jokes page.
final class FavoriteDadJokesPage extends ConsumerWidget {
  /// Provider that provides favorite dad jokes.
  static final _dadJokesProvider = StreamProvider<List<DadJoke>>((ref) async* {
    final dadJokesService = GetIt.I<DadJokesService>();

    await for (final dadJokes in dadJokesService.dadJokesStream) {
      yield dadJokes.where((dadJoke) => dadJoke.isFavorite).toList();
    }
  });

  const FavoriteDadJokesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dadJokesAsyncValue = ref.watch(_dadJokesProvider);
    return dadJokesAsyncValue.when(
      data: (dadJokes) {
        return ListView.builder(
          itemCount: dadJokes.length,
          itemBuilder: (context, index) {
            final dadJoke = dadJokes[index];
            return DadJokeListItem(
              key: Key(dadJoke.id),
              dadJoke: dadJoke,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }
}
