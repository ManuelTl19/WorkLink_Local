import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/constants.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';

class LoginResult {
  final UserModel user;
  final String message;
  final String token;

  const LoginResult({
    required this.user,
    required this.message,
    required this.token,
  });
}

class UserService {
  static Future<LoginResult> login(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    final result = await AuthService.login(email: email, password: password);

    return LoginResult(
      user: result.user,
      message: result.message,
      token: result.token,
    );
  }

  static Future<UserModel> register(
    BuildContext context, {
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
    return await AuthService.register(
      name: name,
      lastName: lastName,
      maternalLastName: maternalLastName,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
      profilePhoto: profilePhoto,
    );
  }

  static Future<UserModel> updateUser({
    required int userId,
    required String name,
    required String lastName,
    required String maternalLastName,
    required String email,
    required String phone,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sesión expirada. Inicia sesión nuevamente.');
      }

      final currentUser = await _getStoredUser();
      if (currentUser == null) {
        throw Exception('No se encontro el usuario actual.');
      }

      final payload = _buildBaseUserPayload(currentUser)
        ..addAll({
          'name': name.trim(),
          'last_name': lastName.trim(),
          'maternal_last_name': maternalLastName.trim(),
          'email': email.trim(),
          'phone': _normalizePhone(phone),
        });

      final response = await http
          .patch(
            Apis.userMe,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);

      final isSuccessStatus =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      final successFlag = body['success'];

      if (isSuccessStatus && (successFlag == null || successFlag == true)) {
        final fallback = UserModel(
          id: currentUser.id,
          nombre: name.trim(),
          apellidoP: lastName.trim(),
          apellidoM: maternalLastName.trim(),
          correo: email.trim(),
          tipoCuenta: currentUser.tipoCuenta,
          cargo: currentUser.cargo,
          departamento: currentUser.departamento,
          roles: currentUser.roles,
          fotoPerfil: currentUser.fotoPerfil,
          telefono: _normalizePhone(phone),
        );
        final updatedUser = _resolveUpdatedUser(body, fallback: fallback);
        await _persistUser(updatedUser);

        return updatedUser;
      }

      if (response.statusCode == 400 || response.statusCode == 422) {
        final firstError = _extractFirstValidationError(body);
        if (firstError != null && firstError.trim().isNotEmpty) {
          throw Exception(firstError);
        }
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo actualizar el usuario',
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sesion expirada. Inicia sesion nuevamente.');
      }

      final storedUser = await _getStoredUser();
      if (storedUser == null || storedUser.id <= 0) {
        throw Exception('No se encontro el usuario actual.');
      }

      final payload = _buildBaseUserPayload(storedUser)
        ..addAll({
        'current_password': currentPassword.trim(),
        'password': newPassword.trim(),
        'password_confirmation': confirmPassword.trim(),
      });

      final response = await http
          .patch(
            Apis.userMe,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      final isSuccessStatus =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      final successFlag = body['success'];

      if (isSuccessStatus && (successFlag == null || successFlag == true)) {
        final updated = _resolveUpdatedUser(body, fallback: storedUser);
        await _persistUser(updated);
        return;
      }

      if (response.statusCode == 400 || response.statusCode == 422) {
        final firstError = _extractFirstValidationError(body);
        if (firstError != null && firstError.trim().isNotEmpty) {
          throw Exception(firstError);
        }
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo actualizar la contrasena',
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<UserModel> updateProfilePhoto({
    required XFile profilePhoto,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sesion expirada. Inicia sesion nuevamente.');
      }

      final currentUser = await _getStoredUser();
      if (currentUser == null) {
        throw Exception('No se encontro el usuario actual.');
      }

      final bytes = await profilePhoto.readAsBytes();
      final request = http.MultipartRequest('POST', Apis.userMeProfilePhoto);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'profile_photo',
          bytes,
          filename: profilePhoto.name,
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);
      final body = _decodeBody(response.body);

      final isSuccessStatus =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      final successFlag = body['success'];

      if (isSuccessStatus && (successFlag == null || successFlag == true)) {
        final fallback = UserModel(
          id: currentUser.id,
          nombre: currentUser.nombre,
          apellidoP: currentUser.apellidoP,
          apellidoM: currentUser.apellidoM,
          correo: currentUser.correo,
          tipoCuenta: currentUser.tipoCuenta,
          cargo: currentUser.cargo,
          departamento: currentUser.departamento,
          roles: currentUser.roles,
          fotoPerfil: body['data']?['profile_photo_url']?.toString() ??
              body['profile_photo_url']?.toString() ??
              currentUser.fotoPerfil,
          telefono: currentUser.telefono,
        );
        final updated = _resolveUpdatedUser(body, fallback: fallback);
        await _persistUser(updated);
        return updated;
      }

      if (response.statusCode == 400 || response.statusCode == 422) {
        final firstError = _extractFirstValidationError(body);
        if (firstError != null && firstError.trim().isNotEmpty) {
          throw Exception(firstError);
        }
      }

      throw Exception(body['message']?.toString() ?? 'No se pudo actualizar la foto');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<UserModel> removeProfilePhoto() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sesion expirada. Inicia sesion nuevamente.');
      }

      final currentUser = await _getStoredUser();
      if (currentUser == null) {
        throw Exception('No se encontro el usuario actual.');
      }

      final response = await http
          .delete(
            Apis.userMeProfilePhoto,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      final isSuccessStatus =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      final successFlag = body['success'];

      if (isSuccessStatus && (successFlag == null || successFlag == true)) {
        final fallback = UserModel(
          id: currentUser.id,
          nombre: currentUser.nombre,
          apellidoP: currentUser.apellidoP,
          apellidoM: currentUser.apellidoM,
          correo: currentUser.correo,
          tipoCuenta: currentUser.tipoCuenta,
          cargo: currentUser.cargo,
          departamento: currentUser.departamento,
          roles: currentUser.roles,
          fotoPerfil: '',
          telefono: currentUser.telefono,
        );
        final updated = _resolveUpdatedUser(body, fallback: fallback);
        await _persistUser(updated);
        return updated;
      }

      if (response.statusCode == 400 || response.statusCode == 422) {
        final firstError = _extractFirstValidationError(body);
        if (firstError != null && firstError.trim().isNotEmpty) {
          throw Exception(firstError);
        }
      }

      throw Exception(body['message']?.toString() ?? 'No se pudo eliminar la foto');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<void> deleteUser({
    required int userId,
    required String password,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sesión expirada. Inicia sesión nuevamente.');
      }

      final response = await http
          .delete(
            Apis.userMe,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'password': password.trim()}),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);

      final isSuccessStatus =
          response.statusCode == 200 || response.statusCode == 204;
      final successFlag = body['success'];

      if (isSuccessStatus && (successFlag == null || successFlag == true)) {
        return;
      }

      if (response.statusCode == 400 || response.statusCode == 422) {
        final firstError = _extractFirstValidationError(body);
        if (firstError != null && firstError.trim().isNotEmpty) {
          throw Exception(firstError);
        }
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo eliminar la cuenta',
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Map<String, dynamic> _decodeBody(String raw) {
    if (raw.trim().isEmpty) return <String, dynamic>{};
    final body = jsonDecode(raw);
    if (body is Map<String, dynamic>) return body;
    return <String, dynamic>{};
  }

  static UserModel _resolveUpdatedUser(
    Map<String, dynamic> body, {
    UserModel? fallback,
  }) {
    final data = (body['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final userJson =
        (data['user'] as Map<String, dynamic>?) ??
        (body['user'] as Map<String, dynamic>?) ??
        data;

    if (userJson.isNotEmpty) {
      return UserModel.fromJson(userJson);
    }

    if (fallback != null) {
      return fallback;
    }

    throw Exception('No se pudo resolver el usuario actualizado');
  }

  static Future<UserModel?> _getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(Constants.userEmailKey);
    if (rawUser == null || rawUser.trim().isEmpty) {
      return null;
    }

    try {
      return UserModel.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _persistUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.userEmailKey, jsonEncode(user.toJson()));
  }

  static Map<String, dynamic> _buildBaseUserPayload(UserModel user) {
    final role = user.roles.isNotEmpty ? user.roles.first : user.tipoCuenta;

    return {
      'name': user.nombre,
      'last_name': user.apellidoP,
      'maternal_last_name': user.apellidoM,
      'email': user.correo,
      'phone': _normalizePhone(user.telefono),
      'role': role,
      'is_active': true,
    };
  }

  static String _normalizePhone(String phone) {
    return phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
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
}
