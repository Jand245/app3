import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataStorage {
  Future<String?> read();
  Future<void> write(String contents);
}

class SharedPreferencesStorage implements LocalDataStorage {
  SharedPreferencesStorage({this.key = 'app_data'});

  final String key;
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<String?> read() => _preferences.getString(key);

  @override
  Future<void> write(String contents) => _preferences.setString(key, contents);
}
