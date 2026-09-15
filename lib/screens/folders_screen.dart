import 'package:flutter/material.dart';

import 'placeholder_page.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Folders',
      icon: Icons.folder_open_outlined,
      message: 'Your note folders will appear here.',
    );
  }
}
