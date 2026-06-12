import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';

class LoginResult {
  final UserModel user;
  final String message;

  const LoginResult({required this.user, required this.message});
}

class UserService {
  static Future<LoginResult> login(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Apis.login,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email.trim(),
              'password': password.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];

        final user = UserModel.fromJson(data);

        final prefs = await SharedPreferences.getInstance();

        // Guardar token
        await prefs.setString(Constants.tokenKey, data['token'] ?? '');

        // Guardar usuario
        await prefs.setString(
          Constants.userEmailKey,
          jsonEncode(user.toJson()),
        );

        return LoginResult(
          user: user,
          message: body['message']?.toString() ?? 'Login exitoso',
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
}
