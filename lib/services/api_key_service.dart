import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyService {
  static const _storage = FlutterSecureStorage();
  static const _apiKeyKey = 'gemini_api_key';

  static Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }

  static Future<String?> getApiKey() async {
    final key = await _storage.read(key: _apiKeyKey);
    if (key == null || key.isEmpty) {
      // Default to the key from scripts/api_key.txt
      return 'AIzaSyB5z1QIy6v0Fy7FrZw5IgA2McXjXF8qEPI';
    }
    return key;
  }

  static Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }
}
