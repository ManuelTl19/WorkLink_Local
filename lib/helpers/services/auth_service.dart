import 'dart:async' show Future, TimeoutException;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
        final userJson = (data['user'] as Map<String, dynamic>?) ?? data;
        final user = UserModel.fromJson(userJson);
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

  static Future<UserModel> register({
    required String name,
    required String lastName,
    required String maternalLastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role,
    XFile? profilePhoto,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Apis.register);
      request.headers.addAll({'Accept': 'application/json'});

      final normalizedPhone = _normalizePhone(phone);

      request.fields.addAll({
        'name': name.trim(),
        'last_name': lastName.trim(),
        'maternal_last_name': maternalLastName.trim(),
        'email': email.trim(),
        'phone': normalizedPhone,
        'password': password.trim(),
        'password_confirmation': passwordConfirmation.trim(),
        'role': role.trim(),
      });

      if (profilePhoto != null) {
        final bytes = await profilePhoto.readAsBytes();
        final photoFile = http.MultipartFile.fromBytes(
          'profile_photo',
          bytes,
          filename: profilePhoto.name,
        );
        request.files.add(photoFile);
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);
      final body = _decodeBody(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['success'] == true) {
        final data =
            (body['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
        final userJson = (data['user'] as Map<String, dynamic>?) ?? data;
        return UserModel.fromJson(userJson);
      }

      if (response.statusCode == 400 || response.statusCode == 422) {
        final firstError = _extractFirstValidationError(body);
        if (firstError != null && firstError.trim().isNotEmpty) {
          throw Exception(firstError);
        }
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo registrar el usuario',
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
    await SecureStorageService.deleteToken();
    AppSettings.isSignedIn = false;
  }

  static Future<String?> refreshToken() async {
    return SecureStorageService.getToken();
  }

  static Future<String?> profile() async {
    return SecureStorageService.getToken();
  }

  static Map<String, dynamic> _decodeBody(String rawBody) {
    if (rawBody.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{'message': decoded.toString()};
    } catch (_) {
      return <String, dynamic>{'message': rawBody};
    }
  }

  static String? _extractFirstValidationError(Map<String, dynamic> body) {
    final errors = body['errors'] as Map<String, dynamic>?;
    if (errors == null || errors.isEmpty) {
      return null;
    }

    final firstValue = errors.values.first;
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first?.toString();
    }

    return firstValue?.toString();
  }

  static String _normalizePhone(String phone) {
    return phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }
}
