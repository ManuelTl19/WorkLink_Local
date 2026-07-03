import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String tokenKey = 'auth_token';
  static const String tokenIssuedAtKey = 'auth_token_issued_at';
  static const Duration tokenLifetime = Duration(hours: 7);

  static Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenIssuedAtKey, DateTime.now().toIso8601String());
  }

  static Future<String?> getToken() async {
    return _storage.read(key: tokenKey);
  }

  static Future<DateTime?> getTokenIssuedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final rawValue = prefs.getString(tokenIssuedAtKey);

    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }

  static Future<bool> isTokenExpired() async {
    final token = await getToken();
    final issuedAt = await getTokenIssuedAt();

    if (token == null || token.isEmpty || issuedAt == null) {
      return true;
    }

    final age = DateTime.now().difference(issuedAt);
    return age >= tokenLifetime;
  }

  static Future<bool> hasValidToken() async {
    final expired = await isTokenExpired();
    if (expired) {
      await deleteToken();
      return false;
    }

    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenIssuedAtKey);
  }
}
