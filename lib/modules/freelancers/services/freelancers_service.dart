import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:async' show Future, TimeoutException;

import 'package:http/http.dart' as http;
import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/helpers/services/secure_storage_service.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';

class FreelancersService {
  /// Get all freelancers (list view)
  static Future<List<FreelancerModel>> getFreelancers() async {
    try {
      final token = await SecureStorageService.getToken();

      final response = await http
          .get(
            Apis.profiles,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final rawData = body['data'];
        List<dynamic> dataList = const [];

        if (rawData is List<dynamic>) {
          dataList = rawData;
        } else if (rawData is Map<String, dynamic>) {
          final nestedProfiles = rawData['profiles'];
          if (nestedProfiles is List<dynamic>) {
            dataList = nestedProfiles;
          }
        }

        final profiles = dataList.whereType<Map<String, dynamic>>().toList();
        final hydrated = await Future.wait(
          profiles.map((profile) => _hydrateProfileWithUser(profile, token)),
        );

        return hydrated.map(FreelancerModel.fromJson).toList();
      }

      return [];
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get freelancer profile by profile ID
  static Future<FreelancerModel?> getProfileById(int profileId) async {
    try {
      final token = await SecureStorageService.getToken();

      final response = await http
          .get(
            Apis.profileById(profileId),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final profileData = _extractProfileData(body);
        if (profileData == null) {
          return null;
        }

        final hydrated = await _hydrateProfileWithUser(profileData, token);
        return FreelancerModel.fromJson(hydrated);
      }

      if (response.statusCode == 404) {
        return null;
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo obtener el perfil',
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get freelancer profile by user ID (current user's profile)
  static Future<FreelancerModel?> getProfileByUserId(int userId) async {
    try {
      final token = await SecureStorageService.getToken();

      final response = await http
          .get(
            Apis.profileByUserId(userId),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final profileData = _extractProfileData(body);
        if (profileData == null) {
          return null;
        }

        final hydrated = await _hydrateProfileWithUser(profileData, token);
        return FreelancerModel.fromJson(hydrated);
      }

      if (response.statusCode == 404) {
        // Profile doesn't exist yet
        return null;
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo obtener el perfil',
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Create new freelancer profile
  static Future<FreelancerModel> createProfile(FreelancerModel profile) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token no disponible. Por favor inicia sesión nuevamente.',
        );
      }

      final response = await http
          .post(
            Apis.profiles,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(profile.toJson()),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && body['success'] == true) {
        final profileData = _extractProfileData(body);
        if (profileData == null) {
          throw Exception('Respuesta invalida: no se recibio el perfil creado.');
        }

        final hydrated = await _hydrateProfileWithUser(profileData, token);
        return FreelancerModel.fromJson(hydrated);
      }

      // Handle validation errors
      if (response.statusCode == 400 || response.statusCode == 422) {
        final firstError = _extractFirstValidationError(body);

        // Backend allows only one profile per user. If profile already exists,
        // fallback to update instead of failing creation flow.
        if (_isUserIdAlreadyTakenError(firstError) && profile.userId != null) {
          final userId = profile.userId!;

          FreelancerModel? existingProfile = await getProfileByUserId(userId);

          if (existingProfile?.id == null) {
            final profiles = await getFreelancers();
            for (final item in profiles) {
              if (item.userId == userId && item.id != null) {
                existingProfile = item;
                break;
              }
            }
          }

          if (existingProfile?.id != null) {
            return updateProfile(
              existingProfile!.id!,
              profile.copyWith(userId: userId),
            );
          }
        }

        if (firstError != null && firstError.trim().isNotEmpty) {
          throw Exception(firstError);
        }
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo crear el perfil',
      );
    } on TimeoutException {
      throw TimeoutException(
        'La solicitud tardó demasiado. Intenta nuevamente.',
      );
    } catch (e) {
      if (e is TimeoutException) {
        rethrow;
      }
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Update freelancer profile
  static Future<FreelancerModel> updateProfile(
    int profileId,
    FreelancerModel profile,
  ) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token no disponible. Por favor inicia sesión nuevamente.',
        );
      }

      final response = await http
          .put(
            Apis.profileById(profileId),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(() {
              final payload = Map<String, dynamic>.from(profile.toJson());
              payload.remove('id');
              payload.remove('user_id');
              return payload;
            }()),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        final profileData = _extractProfileData(body);
        if (profileData == null) {
          throw Exception('Respuesta invalida: no se recibio el perfil actualizado.');
        }

        final hydrated = await _hydrateProfileWithUser(profileData, token);
        return FreelancerModel.fromJson(hydrated);
      }

      // Handle validation errors
      if (response.statusCode == 400 || response.statusCode == 422) {
        final errors = body['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          }
        }
      }

      if (response.statusCode == 404) {
        throw Exception('El perfil no fue encontrado');
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo actualizar el perfil',
      );
    } on TimeoutException {
      throw TimeoutException(
        'La solicitud tardó demasiado. Intenta nuevamente.',
      );
    } catch (e) {
      if (e is TimeoutException) {
        rethrow;
      }
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Delete freelancer profile
  static Future<void> deleteProfile(int profileId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token no disponible. Por favor inicia sesión nuevamente.',
        );
      }

      final response = await http
          .delete(
            Apis.profileById(profileId),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return;
      }

      if (response.statusCode == 404) {
        throw Exception('El perfil no fue encontrado');
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo eliminar el perfil',
      );
    } on TimeoutException {
      throw TimeoutException(
        'La solicitud tardó demasiado. Intenta nuevamente.',
      );
    } catch (e) {
      if (e is TimeoutException) {
        rethrow;
      }
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Get freelancer by ID (legacy method for backwards compatibility)
  static Future<FreelancerModel?> getFreelancerById(int freelancerId) async {
    return getProfileById(freelancerId);
  }

  static Future<Map<String, dynamic>> _hydrateProfileWithUser(
    Map<String, dynamic> profile,
    String? token,
  ) async {
    final userId = _parseInt(profile['user_id'] ?? profile['userId']);

    Map<String, dynamic> userMap = const <String, dynamic>{};
    final embeddedUser = profile['user'];
    if (embeddedUser is Map<String, dynamic>) {
      userMap = Map<String, dynamic>.from(embeddedUser);
    }

    if (userId != null && userId > 0) {
      final fetchedUser = await _fetchUserById(userId, token);
      if (fetchedUser != null && fetchedUser.isNotEmpty) {
        userMap = fetchedUser;
      }
    }

    if (userMap.isEmpty) {
      return profile;
    }

    final fullNameFromUser = [
      (userMap['name'] ?? '').toString().trim(),
      (userMap['last_name'] ?? '').toString().trim(),
      (userMap['maternal_last_name'] ?? '').toString().trim(),
    ].where((part) => part.isNotEmpty).join(' ');

    final profilePhoto = (userMap['profile_photo_url'] ?? userMap['profile_photo'])
        .toString();

    return {
      ...profile,
      'user': userMap,
      if (((profile['full_name'] ?? '').toString().trim().isEmpty) &&
          fullNameFromUser.isNotEmpty)
        'full_name': fullNameFromUser,
      if (((profile['avatar_url'] ?? '').toString().trim().isEmpty) &&
          profilePhoto.trim().isNotEmpty)
        'avatar_url': profilePhoto,
    };
  }

  static Future<Map<String, dynamic>?> _fetchUserById(
    int userId,
    String? token,
  ) async {
    try {
      final response = await http
          .get(
            Apis.userById(userId),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return null;
      }

      final data = body['data'];
      if (data is Map<String, dynamic>) {
        final nested = data['user'];
        if (nested is Map<String, dynamic>) {
          return nested;
        }
        return data;
      }

      final topLevelUser = body['user'];
      if (topLevelUser is Map<String, dynamic>) {
        return topLevelUser;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static Map<String, dynamic>? _extractProfileData(
    Map<String, dynamic> body,
  ) {
    final data = body['data'];

    if (data is Map<String, dynamic>) {
      final nestedProfile = data['profile'];
      if (nestedProfile is Map<String, dynamic>) {
        return nestedProfile;
      }
      return data;
    }

    final topLevelProfile = body['profile'];
    if (topLevelProfile is Map<String, dynamic>) {
      return topLevelProfile;
    }

    return null;
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

  static bool _isUserIdAlreadyTakenError(String? message) {
    if (message == null) {
      return false;
    }

    final normalized = message.toLowerCase();
    return (normalized.contains('user id') ||
            normalized.contains('user_id')) &&
        normalized.contains('already') &&
        normalized.contains('taken');
  }
}
