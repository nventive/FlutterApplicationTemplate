import 'package:flutter/material.dart';

final class SubPageWithMenuPage extends StatelessWidget {
  const SubPageWithMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sub Page'),
      ),
      body: const Center(
        child: Text(
          'This is a sub page with a menu',
        ),
      ),
    );
  }
}
