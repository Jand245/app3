import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class LocalDataStorage {
  Future<String?> read();
  Future<void> write(String contents);
}

class JsonFileStorage implements LocalDataStorage {
  JsonFileStorage(this.file);

  final File file;

  static Future<JsonFileStorage> inDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return JsonFileStorage(File('${directory.path}/app_data.json'));
  }

  @override
  Future<String?> read() async {
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  @override
  Future<void> write(String contents) async {
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(contents, flush: true);
    await temporary.rename(file.path);
  }
}
