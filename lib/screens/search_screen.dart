import 'package:flutter/material.dart';

import 'placeholder_page.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Search Notes',
      icon: Icons.manage_search_outlined,
      message: 'Note search will appear here.',
    );
  }
}
