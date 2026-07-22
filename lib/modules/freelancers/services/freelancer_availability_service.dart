import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_availability_model.dart';

class FreelancerAvailabilityService {
  static Future<List<FreelancerAvailabilityModel>> getByFreelancer(
    int freelancerId,
  ) async {
    try {
      final token = await SecureStorageService.getToken();
      final uri = Apis.availabilities.replace(
        queryParameters: {
          ...Apis.availabilities.queryParameters,
          'freelancer_id': '$freelancerId',
        },
      );

      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);

      if (response.statusCode == 200 &&
          (body['success'] == null || body['success'] == true)) {
        final data = body['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(FreelancerAvailabilityModel.fromJson)
              .where((item) => item.freelancerId == freelancerId)
              .toList();
        }

        if (data is Map<String, dynamic>) {
          final availability = FreelancerAvailabilityModel.fromJson(data);
          if (availability.freelancerId == freelancerId) {
            return [availability];
          }
        }

        return [];
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo cargar disponibilidad',
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<FreelancerAvailabilityModel> create(
    FreelancerAvailabilityModel availability,
  ) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sesion expirada. Inicia sesion nuevamente.');
      }

      final response = await http
          .post(
            Apis.availabilities,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(availability.toJson()),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      final isSuccessStatus =
          response.statusCode == 200 || response.statusCode == 201;

      if (isSuccessStatus &&
          (body['success'] == null || body['success'] == true)) {
        final data = (body['data'] as Map<String, dynamic>?) ??
            (body['availability'] as Map<String, dynamic>?) ??
            body;
        return FreelancerAvailabilityModel.fromJson(data);
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo guardar disponibilidad',
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<FreelancerAvailabilityModel?> getById(int availabilityId) async {
    try {
      final token = await SecureStorageService.getToken();

      final response = await http
          .get(
            Apis.availabilityById(availabilityId),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);

      if (response.statusCode == 404) {
        return null;
      }

      if (response.statusCode == 200 &&
          (body['success'] == null || body['success'] == true)) {
        final data = (body['data'] as Map<String, dynamic>?) ?? body;
        return FreelancerAvailabilityModel.fromJson(data);
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo obtener disponibilidad',
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<FreelancerAvailabilityModel> update(
    int availabilityId,
    FreelancerAvailabilityModel availability,
  ) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sesion expirada. Inicia sesion nuevamente.');
      }

      final response = await http
          .put(
            Apis.availabilityById(availabilityId),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(availability.toJson()),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      final isSuccessStatus =
          response.statusCode == 200 || response.statusCode == 201;

      if (isSuccessStatus &&
          (body['success'] == null || body['success'] == true)) {
        final data = (body['data'] as Map<String, dynamic>?) ??
            (body['availability'] as Map<String, dynamic>?) ??
            body;
        return FreelancerAvailabilityModel.fromJson(data);
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo actualizar disponibilidad',
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<void> delete(int availabilityId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sesion expirada. Inicia sesion nuevamente.');
      }

      final response = await http
          .delete(
            Apis.availabilityById(availabilityId),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      final isSuccessStatus =
          response.statusCode == 200 || response.statusCode == 204;

      if (isSuccessStatus &&
          (body['success'] == null || body['success'] == true)) {
        return;
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo eliminar disponibilidad',
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
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }
}
