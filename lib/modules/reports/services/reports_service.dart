import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/services/secure_storage_service.dart';
import 'package:worklink_local/modules/reports/models/report_model.dart';

class ReportFlowException implements Exception {
  final int? statusCode;
  final String message;

  const ReportFlowException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ReportsService {
  Future<UserReportModel> createReport({
    required int reportedId,
    required String reason,
    required String description,
  }) async {
    try {
      final token = await _requireToken();
      final response = await http
          .post(
            Apis.reports,
            headers: _headers(token),
            body: jsonEncode({
              'reported_id': reportedId,
              'reason': reason.trim(),
              'description': description.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw ReportFlowException(
          _extractMessage(body, 'No se pudo enviar el reporte.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) {
        return UserReportModel.fromJson(data);
      }

      return UserReportModel(
        id: 0,
        reportedId: reportedId,
        reporterId: 0,
        reportedName: '',
        reporterName: '',
        reason: reason.trim(),
        description: description.trim(),
        status: ReportStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is ReportFlowException) rethrow;
      throw ReportFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<List<UserReportModel>> getReports({
    String? status,
    String search = '',
    int? perPage,
    int? reportedId,
  }) async {
    try {
      final token = await _requireToken();
      final response = await http
          .get(
            _reportsUri(
              status: status,
              search: search,
              perPage: perPage,
              reportedId: reportedId,
            ),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw ReportFlowException(
          _extractMessage(body, 'No se pudieron cargar los reportes.'),
          statusCode: response.statusCode,
        );
      }

      return _extractDataList(
        body,
      ).map((item) => UserReportModel.fromJson(item)).toList();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is ReportFlowException) rethrow;
      throw ReportFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<UserReportModel?> getReportById(int id) async {
    try {
      final token = await _requireToken();
      final response = await http
          .get(Apis.reportById(id), headers: _headers(token))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 404) {
        return null;
      }

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw ReportFlowException(
          _extractMessage(body, 'No se pudo cargar el reporte.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) {
        return UserReportModel.fromJson(data);
      }

      final list = _extractDataList(body);
      if (list.isNotEmpty) {
        return UserReportModel.fromJson(list.first);
      }

      return null;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is ReportFlowException) rethrow;
      throw ReportFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<void> updateReportStatus({
    required int reportId,
    required ReportStatus status,
  }) async {
    try {
      final token = await _requireToken();
      final response = await http
          .patch(
            Apis.reportById(reportId),
            headers: _headers(token),
            body: jsonEncode({'status': status.apiValue}),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw ReportFlowException(
          _extractMessage(body, 'No se pudo actualizar el reporte.'),
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is ReportFlowException) rethrow;
      throw ReportFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<void> deleteReport(int reportId) async {
    try {
      final token = await _requireToken();
      final response = await http
          .delete(Apis.reportById(reportId), headers: _headers(token))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 204) return;

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw ReportFlowException(
          _extractMessage(body, 'No se pudo eliminar el reporte.'),
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is ReportFlowException) rethrow;
      throw ReportFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<ReportSummaryModel> getReportsSummary() async {
    try {
      final token = await _requireToken();
      final response = await http
          .get(Apis.reportsSummary, headers: _headers(token))
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw ReportFlowException(
          _extractMessage(body, 'No se pudo cargar el resumen.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      return ReportSummaryModel.fromJson(data.isEmpty ? body : data);
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is ReportFlowException) rethrow;
      throw ReportFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Uri _reportsUri({
    String? status,
    String search = '',
    int? perPage,
    int? reportedId,
  }) {
    final params = <String, String>{};

    if (status != null && status.trim().isNotEmpty) {
      params['status'] = status.trim();
    }
    if (search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    if (perPage != null) {
      params['per_page'] = perPage.toString();
    }
    if (reportedId != null) {
      params['reported_id'] = reportedId.toString();
    }

    if (params.isEmpty) return Apis.reports;
    return Apis.reports.replace(queryParameters: params);
  }

  Future<String> _requireToken() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      throw const ReportFlowException(
        'Sesion expirada. Inicia sesion nuevamente.',
        statusCode: 401,
      );
    }
    return token;
  }

  Map<String, String> _headers(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{'data': decoded};
  }

  bool _isSuccessful(int statusCode, Map<String, dynamic> body) {
    return statusCode >= 200 &&
        statusCode < 300 &&
        (body['success'] == null || body['success'] == true);
  }

  String _extractMessage(Map<String, dynamic> body, String fallback) {
    final message = body['message'] ?? body['error'] ?? body['detail'];
    final text = message?.toString().trim() ?? '';
    return text.isNotEmpty ? text : fallback;
  }

  String _normalizeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  List<Map<String, dynamic>> _extractDataList(Map<String, dynamic> body) {
    final data = body['data'];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final candidates = [
        data['reports'],
        data['items'],
        data['results'],
        data['data'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((item) => item.cast<String, dynamic>())
              .toList();
        }
      }
    }

    if (body['reports'] is List) {
      return (body['reports'] as List)
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    }

    return const [];
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    if (body['report'] is Map<String, dynamic>) return body['report'];
    if (body['summary'] is Map<String, dynamic>) return body['summary'];
    return const <String, dynamic>{};
  }
}
