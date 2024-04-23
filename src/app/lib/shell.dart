import 'package:app/presentation/dad_jokes/dad_jokes_page.dart';
import 'package:app/presentation/dad_jokes/favorite_dad_jokes.dart';
import 'package:flutter/material.dart';

/// The shell of the application.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

/// The state of the [Shell].
class _ShellState extends State<Shell> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const DadJokesPage(),
    const FavoriteDadJokesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dad Jokes'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.theater_comedy),
            label: 'Dad Jokes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }

  /// Handles the tap event.
  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
