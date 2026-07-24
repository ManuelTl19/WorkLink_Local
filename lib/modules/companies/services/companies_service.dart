import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/services/secure_storage_service.dart';
import 'package:worklink_local/modules/companies/models/company_profile_model.dart';

class CompanyProfilesFlowException implements Exception {
  final int? statusCode;
  final String message;

  const CompanyProfilesFlowException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class CompaniesService {
  Future<List<CompanyProfileModel>> getCompanies({
    String query = '',
    String industry = 'Todas',
    String location = 'Todas',
  }) async {
    final companies = await getPublicCompanyProfiles();
    final normalizedQuery = query.trim().toLowerCase();

    return companies.where((company) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          company.companyName.toLowerCase().contains(normalizedQuery) ||
          company.description.toLowerCase().contains(normalizedQuery) ||
          company.industry.toLowerCase().contains(normalizedQuery) ||
          company.location.toLowerCase().contains(normalizedQuery) ||
          company.ownerName.toLowerCase().contains(normalizedQuery);

      final matchesIndustry = industry == 'Todas' || industry.isEmpty
          ? true
          : company.industry == industry;
      final matchesLocation = location == 'Todas' || location.isEmpty
          ? true
          : company.location == location;

      return matchesQuery && matchesIndustry && matchesLocation;
    }).toList();
  }

  Future<List<String>> getIndustries() async {
    final companies = await getPublicCompanyProfiles();
    final industries =
        companies
            .map((company) => company.industry.trim())
            .where((industry) => industry.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return industries;
  }

  Future<List<String>> getLocations() async {
    final companies = await getPublicCompanyProfiles();
    final locations =
        companies
            .map((company) => company.location.trim())
            .where((location) => location.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return locations;
  }

  Future<List<CompanyProfileModel>> getPublicCompanyProfiles() async {
    try {
      final response = await http
          .get(Apis.publicCompanyProfiles, headers: _publicHeaders())
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw CompanyProfilesFlowException(
          _extractMessage(
            body,
            'No se pudieron cargar los perfiles de empresa.',
          ),
          statusCode: response.statusCode,
        );
      }

      return _extractDataList(
        body,
      ).map((item) => CompanyProfileModel.fromJson(item)).toList();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is CompanyProfilesFlowException) rethrow;
      throw CompanyProfilesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<CompanyProfileModel?> getPublicCompanyById(int companyId) async {
    try {
      final response = await http
          .get(
            Apis.publicCompanyProfileById(companyId),
            headers: _publicHeaders(),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 404) {
        return null;
      }

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw CompanyProfilesFlowException(
          _extractMessage(body, 'No se pudo cargar el perfil de empresa.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) return CompanyProfileModel.fromJson(data);

      final list = _extractDataList(body);
      if (list.isNotEmpty) return CompanyProfileModel.fromJson(list.first);

      return null;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is CompanyProfilesFlowException) rethrow;
      throw CompanyProfilesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<List<CompanyProfileModel>> getCompanyProfiles() async {
    try {
      final token = await _requireToken();
      final response = await http
          .get(Apis.companyProfiles, headers: _headers(token))
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw CompanyProfilesFlowException(
          _extractMessage(
            body,
            'No se pudieron cargar los perfiles de empresa.',
          ),
          statusCode: response.statusCode,
        );
      }

      return _extractDataList(
        body,
      ).map((item) => CompanyProfileModel.fromJson(item)).toList();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is CompanyProfilesFlowException) rethrow;
      throw CompanyProfilesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<CompanyProfileModel?> getCompanyProfileById(int companyId) async {
    try {
      final token = await _requireToken();
      final response = await http
          .get(Apis.companyProfileById(companyId), headers: _headers(token))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 404) {
        return null;
      }

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw CompanyProfilesFlowException(
          _extractMessage(body, 'No se pudo cargar el perfil de empresa.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) return CompanyProfileModel.fromJson(data);

      final list = _extractDataList(body);
      if (list.isNotEmpty) return CompanyProfileModel.fromJson(list.first);

      return null;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is CompanyProfilesFlowException) rethrow;
      throw CompanyProfilesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<CompanyProfileModel?> getMyCompanyProfile() async {
    try {
      final token = await _requireToken();
      final response = await http
          .get(Apis.companyProfilesMe, headers: _headers(token))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 404) {
        return null;
      }

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw CompanyProfilesFlowException(
          _extractMessage(body, 'No se pudo cargar tu perfil de empresa.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) return CompanyProfileModel.fromJson(data);

      final list = _extractDataList(body);
      if (list.isNotEmpty) return CompanyProfileModel.fromJson(list.first);

      return null;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is CompanyProfilesFlowException) rethrow;
      throw CompanyProfilesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<CompanyProfileModel> createCompanyProfile({
    required String companyName,
    String description = '',
    String industry = '',
    String location = '',
    int? userId,
  }) async {
    try {
      final token = await _requireToken();
      final response = await http
          .post(
            Apis.companyProfiles,
            headers: _headers(token),
            body: jsonEncode({
              'company_name': companyName.trim(),
              'description': description.trim(),
              'industry': industry.trim(),
              'location': location.trim(),
              if (userId != null) 'user_id': userId,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw CompanyProfilesFlowException(
          _extractMessage(body, 'No se pudo crear el perfil de empresa.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) return CompanyProfileModel.fromJson(data);

      return CompanyProfileModel.fromJson({
        'id': 0,
        'company_name': companyName.trim(),
        'description': description.trim(),
        'industry': industry.trim(),
        'location': location.trim(),
        'average_rate': 0,
        'user_id': userId,
      });
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is CompanyProfilesFlowException) rethrow;
      throw CompanyProfilesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<CompanyProfileModel> updateCompanyProfile(
    CompanyProfileModel company,
  ) async {
    try {
      final token = await _requireToken();
      final response = await http
          .patch(
            Apis.companyProfileById(company.id),
            headers: _headers(token),
            body: jsonEncode(company.toUpdateJson()),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw CompanyProfilesFlowException(
          _extractMessage(body, 'No se pudo actualizar el perfil de empresa.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) return CompanyProfileModel.fromJson(data);

      return company;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is CompanyProfilesFlowException) rethrow;
      throw CompanyProfilesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<void> deleteCompanyProfile(int companyId) async {
    try {
      final token = await _requireToken();
      final response = await http
          .delete(Apis.companyProfileById(companyId), headers: _headers(token))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 204) return;

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw CompanyProfilesFlowException(
          _extractMessage(body, 'No se pudo eliminar el perfil de empresa.'),
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is CompanyProfilesFlowException) rethrow;
      throw CompanyProfilesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Map<String, String> _publicHeaders() {
    return const {'Accept': 'application/json'};
  }

  Map<String, String> _headers(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<String> _requireToken() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      throw CompanyProfilesFlowException('No se encontró un token de acceso.');
    }
    return token;
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) return const <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  bool _isSuccessful(int statusCode, dynamic body) {
    if (statusCode >= 200 && statusCode < 300) return true;
    if (body is Map<String, dynamic>) {
      final success = body['success'];
      if (success is bool) return success;
    }
    return false;
  }

  List<Map<String, dynamic>> _extractDataList(dynamic body) {
    if (body is List) {
      return body.whereType<Map<String, dynamic>>().toList();
    }

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }

      final results = body['results'];
      if (results is List) {
        return results.whereType<Map<String, dynamic>>().toList();
      }
    }

    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _extractDataMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;

      final result = body['result'];
      if (result is Map<String, dynamic>) return result;

      return body;
    }

    if (body is List && body.isNotEmpty && body.first is Map<String, dynamic>) {
      return body.first as Map<String, dynamic>;
    }

    return const <String, dynamic>{};
  }

  String _extractMessage(dynamic body, String fallback) {
    if (body is Map<String, dynamic>) {
      final message = body['message'] ?? body['error'] ?? body['detail'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    return fallback;
  }

  String _normalizeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}
