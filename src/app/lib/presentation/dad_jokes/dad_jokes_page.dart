import 'package:app/business/dad_jokes/dad_joke.dart';
import 'package:app/business/dad_jokes/dad_jokes_service.dart';
import 'package:app/l10n/localization_extensions.dart';
import 'package:app/presentation/dad_jokes/dad_joke_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// The dad jokes page.
final class DadJokesPage extends ConsumerWidget {
  /// Provider that provides dad jokes.
  static final _dadJokesProvider = StreamProvider<List<DadJoke>>((ref) async* {
    final dadJokesService = GetIt.I<DadJokesService>();

    await for (final dadJokes in dadJokesService.dadJokesStream) {
      yield dadJokes;
    }
  });

  const DadJokesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dadJokesAsyncValue = ref.watch(_dadJokesProvider);
    final local = context.local;
    return Scaffold(
      appBar: AppBar(
        title: Text(local.dadJokesPageTitle),
      ),
      body: dadJokesAsyncValue.when(
        data: (dadJokes) {
          return Container(
            key: const Key('DadJokesContainer'),
            child: ListView.builder(
              itemCount: dadJokes.length,
              itemBuilder: (context, index) {
                final dadJoke = dadJokes[index];
                return DadJokeListItem(
                  dadJoke: dadJoke,
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Text(
          local.error(error),
        ),
      ),
    );
  }
}
