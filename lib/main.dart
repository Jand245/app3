import 'package:flutter/material.dart';

import 'models/app_data_store.dart';
import 'models/local_data_storage.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final storage = SharedPreferencesStorage();
    final store = await AppDataStore.load(storage);
    runApp(NotesApp(store: store));
  } catch (error) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Could not load saved app data. No data was changed.\n$error',
            ),
          ),
        ),
      ),
    );
  }
}

class NotesApp extends StatelessWidget {
  const NotesApp({this.store, super.key});

  final AppDataStore? store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes & Assignments',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: MainShell(store: store),
    );
  }
}
