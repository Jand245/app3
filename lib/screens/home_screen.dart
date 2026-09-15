import 'package:flutter/material.dart';

import 'placeholder_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Home',
      icon: Icons.note_add_outlined,
      message:
          'Upcoming assignments and quick access to notes will appear here.',
    );
  }
}
