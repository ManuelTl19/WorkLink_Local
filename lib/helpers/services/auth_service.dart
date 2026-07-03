import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/constants.dart';
import 'package:worklink_local/helpers/providers/app_settings.dart';
import 'package:worklink_local/helpers/services/secure_storage_service.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';

class AuthResult {
  final UserModel user;
  final String message;
  final String token;

  const AuthResult({
    required this.user,
    required this.message,
    required this.token,
  });
}

class AuthService {
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Apis.login,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim(),
              'password': password.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final data =
            (body['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        final user = UserModel.fromJson(data);
        final token = data['token']?.toString() ?? '';

        if (token.isNotEmpty) {
          await SecureStorageService.saveToken(token);
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          Constants.userEmailKey,
          jsonEncode(user.toJson()),
        );

        AppSettings.isSignedIn = true;
        AppSettings.loginDate = DateTime.now().toString();

        return AuthResult(
          user: user,
          message: body['message']?.toString() ?? 'Login exitoso',
          token: token,
        );
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo iniciar sesión',
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) {
        rethrow;
      }

      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.userEmailKey);
    AppSettings.isSignedIn = false;
  }

  static Future<String?> refreshToken() async {
    return SecureStorageService.getToken();
  }

  static Future<String?> profile() async {
    return SecureStorageService.getToken();
  }
}
