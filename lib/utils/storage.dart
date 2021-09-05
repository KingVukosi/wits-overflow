import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' show window;

final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

class SecureStorage {
  static Future<String?> read(String key) async {
    if (kIsWeb) {
      return window.localStorage.containsKey(key)
          ? window.localStorage[key].toString()
          : "";
    } else {
      return secureStorage.read(key: key);
    }
  }

  static Future<void> write(String key, String value) async {
    if (kIsWeb) {
      window.localStorage[key] = value;
    } else {
      await secureStorage.write(key: key, value: value);
    }
  }

  static Future<void> delete(String key) async {
    if (kIsWeb) {
      window.localStorage.remove(key);
    } else {
      await secureStorage.delete(key: key);
    }
  }
}
