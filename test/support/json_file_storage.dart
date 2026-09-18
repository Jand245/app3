import 'dart:io';

import 'package:app3/models/local_data_storage.dart';

class JsonFileStorage implements LocalDataStorage {
  JsonFileStorage(this.file);

  final File file;

  @override
  Future<String?> read() async {
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  @override
  Future<void> write(String contents) async {
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(contents, flush: true);
    await temporary.rename(file.path);
  }
}
