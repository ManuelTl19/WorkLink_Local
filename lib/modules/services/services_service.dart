import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/constants.dart';
import 'package:worklink_local/helpers/services/secure_storage_service.dart';
import 'package:worklink_local/modules/freelancers/services/freelancers_service.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/models/service_request_model.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';

class ServicesService {
  static const int currentRequesterId = 901;
  static const String currentRequesterName = 'Empresa Demo';
  static const String currentRequesterAccountType = 'Empresa';
  static const String currentRequesterAvatarUrl =
      'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=600&q=80';
  static const String _fallbackServiceImage =
      'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1200&q=80';

  static final List<ServiceRequestModel> _requests = [];

  Future<int> getCurrentFreelancerId() async {
    final user = await _getStoredUser();
    if (user == null || user.id <= 0) {
      throw Exception('No se encontro el usuario autenticado.');
    }

    final profile = await FreelancersService.getProfileByUserId(user.id);
    final profileId = profile?.id;
    if (profileId == null || profileId <= 0) {
      throw Exception(
        'No se encontro el perfil freelancer. Crea tu perfil profesional primero.',
      );
    }

    return profileId;
  }

  Future<List<ServiceModel>> getServices({
    String query = '',
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    try {
      final token = await SecureStorageService.getToken();

      final response = await http
          .get(
            Apis.services,
            headers: {
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (response.statusCode != 200 ||
          !(body['success'] == null || body['success'] == true)) {
        throw Exception(
          body['message']?.toString() ?? 'No se pudieron cargar servicios.',
        );
      }

      final list = _extractDataList(body)
          .map((item) => _normalizeService(item))
          .map(ServiceModel.fromJson)
          .toList();

      final normalizedQuery = query.trim().toLowerCase();

      final filtered = list.where((service) {
        final matchesQuery =
            normalizedQuery.isEmpty ||
            service.title.toLowerCase().contains(normalizedQuery) ||
            service.shortDescription.toLowerCase().contains(normalizedQuery) ||
            service.description.toLowerCase().contains(normalizedQuery) ||
            service.freelancerName.toLowerCase().contains(normalizedQuery) ||
            service.tags.any(
              (tag) => tag.toLowerCase().contains(normalizedQuery),
            );

        final matchesCategory =
            category == null || category.isEmpty || category == 'Todas'
            ? true
            : service.category.trim().toLowerCase() ==
                  category.trim().toLowerCase();

        final matchesMinPrice = minPrice == null
            ? true
            : service.priceValue >= minPrice;
        final matchesMaxPrice = maxPrice == null
            ? true
            : service.priceValue <= maxPrice;
        final matchesMinRating = minRating == null
            ? true
            : service.averageRating >= minRating;

        return matchesQuery &&
            matchesCategory &&
            matchesMinPrice &&
            matchesMaxPrice &&
            matchesMinRating;
      }).toList();

      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<ServiceModel>> getFreelancerServices({int? freelancerId}) async {
    try {
      final resolvedFreelancerId =
          freelancerId ?? await getCurrentFreelancerId();
      final token = await SecureStorageService.getToken();

      final response = await http
          .get(
            Apis.servicesByFreelancerId(resolvedFreelancerId),
            headers: {
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (response.statusCode != 200 ||
          !(body['success'] == null || body['success'] == true)) {
        throw Exception(
          body['message']?.toString() ?? 'No se pudieron cargar servicios.',
        );
      }

      final list = _extractDataList(body)
          .map((item) => _normalizeService(item))
          .map(ServiceModel.fromJson)
          .where((item) => item.freelancerId == resolvedFreelancerId)
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<ServiceModel?> getServiceById(int id) async {
    try {
      final token = await SecureStorageService.getToken();
      final response = await http
          .get(
            Apis.serviceById(id),
            headers: {
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 404) {
        return null;
      }

      final body = _decodeBody(response.body);
      if (response.statusCode != 200 ||
          !(body['success'] == null || body['success'] == true)) {
        throw Exception(
          body['message']?.toString() ?? 'No se pudo cargar el servicio.',
        );
      }

      final data = _extractDataMap(body);
      return ServiceModel.fromJson(_normalizeService(data));
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<String>> getCategories() async {
    final services = await getServices();
    final categories = services
        .map((service) => service.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  Future<List<String>> getModalities() async {
    return ServiceModality.values.map((modality) => modality.label).toList();
  }

  Future<List<ServiceRequestModel>> getServiceRequestsByServiceId(
    int serviceId,
  ) async {
    final requests = _requests
        .where((request) => request.serviceId == serviceId)
        .toList();
    requests.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return requests;
  }

  Future<ServiceRequestModel> requestService({
    required int serviceId,
    required int requesterId,
    required String requesterName,
    required String accountType,
    required String avatarUrl,
  }) async {
    for (final request in _requests) {
      if (request.serviceId == serviceId &&
          request.requesterId == requesterId) {
        return request;
      }
    }

    final nextId = _requests.isEmpty ? 1 : _requests.last.id + 1;
    final request = ServiceRequestModel(
      id: nextId,
      serviceId: serviceId,
      requesterId: requesterId,
      requesterName: requesterName,
      accountType: accountType,
      avatarUrl: avatarUrl,
      requestedAt: DateTime.now(),
    );

    _requests.add(request);
    return request;
  }

  Future<ServiceModel> createService({
    required int freelancerId,
    required String title,
    required String description,
    required double priceValue,
    required String category,
    required String location,
    required bool isActive,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sesion expirada. Inicia sesion nuevamente.');
      }

      final resolvedFreelancerId = freelancerId > 0
          ? freelancerId
          : await getCurrentFreelancerId();

      final payload = {
        'freelancer_id': resolvedFreelancerId,
        'title': title.trim(),
        'description': description.trim(),
        'price': priceValue,
        'category': category.trim(),
        'location': location.trim().isEmpty ? 'Remoto' : location.trim(),
        'is_active': isActive,
      };

      final response = await http
          .post(
            Apis.services,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      final okStatus = response.statusCode == 200 || response.statusCode == 201;
      if (!okStatus || !(body['success'] == null || body['success'] == true)) {
        throw Exception(
          body['message']?.toString() ?? 'No se pudo crear el servicio.',
        );
      }

      final data = _extractDataMap(body);
      final normalized = _normalizeService(
        data,
        fallback: {
          'freelancer_id': resolvedFreelancerId,
          'short_description': description,
          'price_label': _buildPriceLabel(priceValue),
          'status': isActive ? 'Activo' : 'Inactivo',
          'location': location,
        },
      );
      return ServiceModel.fromJson(normalized);
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<ServiceModel> updateService(ServiceModel service) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sesion expirada. Inicia sesion nuevamente.');
      }

      final payload = {
        'freelancer_id': service.freelancerId,
        'title': service.title.trim(),
        'description': service.description.trim(),
        'price': service.priceValue,
        'category': service.category.trim(),
        'location': service.location.trim().isEmpty
            ? 'Remoto'
            : service.location.trim(),
        'is_active': service.status == ServiceStatus.activo,
      };

      final response = await http
          .put(
            Apis.serviceById(service.id),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      final okStatus = response.statusCode == 200 || response.statusCode == 201;
      if (!okStatus || !(body['success'] == null || body['success'] == true)) {
        throw Exception(
          body['message']?.toString() ?? 'No se pudo actualizar el servicio.',
        );
      }

      final data = _extractDataMap(body);
      return ServiceModel.fromJson(
        _normalizeService(data, fallback: service.toJson()),
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<ServiceModel> changeServiceStatus({
    required int serviceId,
    required ServiceStatus status,
  }) async {
    final current = await getServiceById(serviceId);
    if (current == null) {
      throw Exception('El servicio no existe.');
    }

    return updateService(current.copyWith(status: status));
  }

  Future<void> deleteService(int serviceId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sesion expirada. Inicia sesion nuevamente.');
      }

      final response = await http
          .delete(
            Apis.serviceById(serviceId),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      final okStatus = response.statusCode == 200 || response.statusCode == 204;
      if (!okStatus || !(body['success'] == null || body['success'] == true)) {
        throw Exception(
          body['message']?.toString() ?? 'No se pudo eliminar el servicio.',
        );
      }

      _requests.removeWhere((request) => request.serviceId == serviceId);
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static UserModel? _userFromAnyMap(Map<String, dynamic> source) {
    try {
      return UserModel.fromJson(source);
    } catch (_) {
      return null;
    }
  }

  static Future<UserModel?> _getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(Constants.userEmailKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return _userFromAnyMap(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _decodeBody(String raw) {
    if (raw.trim().isEmpty) return <String, dynamic>{};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{'message': decoded.toString()};
    } catch (_) {
      return <String, dynamic>{'message': raw};
    }
  }

  static List<Map<String, dynamic>> _extractDataList(
    Map<String, dynamic> body,
  ) {
    final data = body['data'];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final nestedList = data['services'] ?? data['items'] ?? data['rows'];
      if (nestedList is List) {
        return nestedList.whereType<Map<String, dynamic>>().toList();
      }
      return [data];
    }
    return [];
  }

  static Map<String, dynamic> _extractDataMap(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final nestedMap =
          data['service'] ?? data['item'] ?? data['result'] ?? data['profile'];
      if (nestedMap is Map<String, dynamic>) {
        return nestedMap;
      }
      return data;
    }

    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map<String, dynamic>) {
        return first;
      }
    }

    return body;
  }

  static Map<String, dynamic> _normalizeService(
    Map<String, dynamic> source, {
    Map<String, dynamic>? fallback,
  }) {
    final merged = <String, dynamic>{
      if (fallback != null) ...fallback,
      ...source,
    };

    final title = merged['title']?.toString() ?? '';
    final description = merged['description']?.toString() ?? '';
    final priceRaw = merged['price'] ?? merged['price_value'] ?? 0;
    final price = _parseDouble(priceRaw);

    final normalizedFreelancerId =
        _parseInt(merged['freelancer_id']) ??
        _parseInt(merged['freelancer']?['id']) ??
        _parseInt(merged['user_id']) ??
        0;

    final gallery = merged['gallery_images'] is List
        ? (merged['gallery_images'] as List)
              .map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList()
        : <String>[];

    final resolvedMainImage =
        merged['main_image_url']?.toString() ??
        merged['image_url']?.toString() ??
        _fallbackServiceImage;

    final tags = merged['tags'] is List
        ? (merged['tags'] as List)
              .map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList()
        : const <String>[];

    final normalized = <String, dynamic>{
      ...merged,
      'title': title,
      'description': description,
      'price': price,
      'price_value': merged['price_value'] ?? price,
      'price_label': merged['price_label'] ?? _buildPriceLabel(price),
      'short_description':
          merged['short_description'] ??
          (description.length > 120
              ? '${description.substring(0, 120)}...'
              : description),
      'main_image_url': resolvedMainImage,
      'gallery_images': gallery.isNotEmpty
          ? gallery
          : <String>[resolvedMainImage],
      'tags': tags,
      'modality': merged['modality'] ?? 'Remoto',
      'estimated_time': merged['estimated_time'] ?? '',
      'status':
          merged['status'] ??
          ((merged['is_active'] == false || merged['is_active'] == 0)
              ? 'Inactivo'
              : 'Activo'),
      'freelancer_name': merged['freelancer_name'] ?? 'Freelancer',
      'freelancer_specialty': merged['freelancer_specialty'] ?? '',
      'freelancer_short_description':
          merged['freelancer_short_description'] ?? '',
      'freelancer_avatar_url': merged['freelancer_avatar_url'] ?? '',
      'average_rating': merged['average_rating'] ?? 0,
      'review_count': merged['review_count'] ?? 0,
      'interested_count': merged['interested_count'] ?? 0,
      'featured': merged['featured'] ?? false,
      'created_at': merged['created_at'] ?? DateTime.now().toIso8601String(),
      'updated_at':
          merged['updated_at'] ??
          merged['created_at'] ??
          DateTime.now().toIso8601String(),
      'location': merged['location'] ?? 'Remoto',
      'freelancer_id': normalizedFreelancerId,
    };

    return normalized;
  }

  static int? _parseInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _parseDouble(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static String _buildPriceLabel(double value) {
    if (value <= 0) return '';
    if (value == value.roundToDouble()) {
      return '\$${value.toInt()}';
    }
    return '\$${value.toStringAsFixed(2)}';
  }
}
