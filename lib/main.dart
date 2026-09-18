import 'package:flutter/material.dart';

import 'models/app_data_store.dart';
import 'models/local_data_storage.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final storage = await JsonFileStorage.inDocumentsDirectory();
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: MainShell(store: store),
    );
  }
}
