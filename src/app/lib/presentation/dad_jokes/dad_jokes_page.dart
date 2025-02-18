import 'package:app/l10n/localization_extensions.dart';
import 'package:app/presentation/dad_jokes/dad_joke_list_item.dart';
import 'package:app/presentation/dad_jokes/dad_jokes_page_viewmodel.dart';
import 'package:app/presentation/mvvm/mvvm_widget.dart';
import 'package:flutter/material.dart';

/// The dad jokes page.
final class DadJokesPage extends MvvmWidget<DadJokesPageViewModel> {
  const DadJokesPage({super.key});

  @override
  DadJokesPageViewModel getViewModel() {
    return DadJokesPageViewModel();
  }

  @override
  Widget build(BuildContext context, DadJokesPageViewModel viewModel) {
    final local = context.local;
    return Scaffold(
      appBar: AppBar(
        title: Text(local.dadJokesPageTitle),
      ),
      body: 
        StreamBuilder(stream: viewModel.dadJokesStream, builder: (context, snapshot) {
          if (snapshot.hasData) {
            final dadJokes = snapshot.data;
            return Container(
              key: const Key('DadJokesContainer'),
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
