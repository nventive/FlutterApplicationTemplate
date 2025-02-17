import 'package:app/business/dad_jokes/dad_joke.dart';
import 'package:flutter/material.dart';

/// A dad joke list item.
final class DadJokeListItem extends StatelessWidget {
  /// The dad joke.
  final DadJoke dadJoke;
  final Future<void> Function(DadJoke dadJoke) toggleIsFavorite;

  const DadJokeListItem({super.key, required this.dadJoke, required this.toggleIsFavorite});

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
        onTap: () => toggleIsFavorite(dadJoke),
      ),
    );
  }
}
