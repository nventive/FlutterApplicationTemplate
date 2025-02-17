import 'package:app/l10n/localization_extensions.dart';
import 'package:app/presentation/dad_jokes/dad_joke_list_item.dart';
import 'package:app/presentation/dad_jokes/favorite_dad_jokes_viewmodel.dart';
import 'package:app/presentation/mvvm/mvvm_widget.dart';
import 'package:flutter/material.dart';

/// The favorite dad jokes page.
final class FavoriteDadJokesPage extends MvvmWidget<FavoriteDadJokesViewModel> {
  const FavoriteDadJokesPage({super.key});

  @override
  FavoriteDadJokesViewModel getViewModel() {
    return FavoriteDadJokesViewModel();
  }

  @override
  Widget build(BuildContext context, FavoriteDadJokesViewModel viewModel) {
    final local = context.local;
    return Scaffold(
      appBar: AppBar(
        title: Text(local.favoriteDadJokesPageTitle),
      ),
      body: StreamBuilder(
          stream: viewModel.favorites,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final dadJokes = snapshot.data;
              return Container(
                key: const Key("FavoriteJokesContainer"),
                child: ListView.builder(
                  itemCount: dadJokes?.length ?? 0,
                  itemBuilder: (context, index) {
                    final dadJoke = dadJokes![index];
                    return DadJokeListItem(
                      dadJoke: dadJoke,
                      toggleIsFavorite: viewModel.toggleIsFavorite,
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Text(
                local.error(snapshot.error!),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
