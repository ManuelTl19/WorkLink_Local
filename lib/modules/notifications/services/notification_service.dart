import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/notifications/models/notification_model.dart';

class NotificationsFlowException implements Exception {
  final int? statusCode;
  final String message;

  const NotificationsFlowException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NotificationService {
  static Future<List<NotificationModel>> fetchNotifications({
    bool? onlyRead,
    String? type,
    int? perPage,
  }) async {
    try {
      final uri = _buildNotificationsUri(
        onlyRead: onlyRead,
        type: type,
        perPage: perPage,
      );

      final response = await _authorizedGet(uri);
      final body = _decodeBody(response.body);

      if (!_isSuccessful(response.statusCode, body)) {
        throw NotificationsFlowException(
          _extractMessage(body, 'No se pudieron cargar las notificaciones.'),
          statusCode: response.statusCode,
        );
      }

      return _extractDataList(body).map(NotificationModel.fromJson).toList();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is NotificationsFlowException) rethrow;
      throw NotificationsFlowException(_normalizeError(e));
    }
  }

  static Future<int> getUnreadCount() async {
    try {
      final response = await _authorizedGet(Apis.notificationsUnreadCount);
      final body = _decodeBody(response.body);

      if (!_isSuccessful(response.statusCode, body)) {
        throw NotificationsFlowException(
          _extractMessage(body, 'No se pudo obtener el contador de notificaciones.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      final countValue = data['unread_count'] ?? data['count'];
      return _intValue(countValue);
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is NotificationsFlowException) rethrow;
      throw NotificationsFlowException(_normalizeError(e));
    }
  }

  static Future<void> markAsRead(int id) async {
    try {
      final response = await _authorizedPatch(Apis.notificationReadById(id));
      _throwIfFailed(response, 'No se pudo marcar la notificación como leída.');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is NotificationsFlowException) rethrow;
      throw NotificationsFlowException(_normalizeError(e));
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      final response = await _authorizedPatch(Apis.notificationsReadAll);
      _throwIfFailed(response, 'No se pudieron marcar todas como leídas.');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is NotificationsFlowException) rethrow;
      throw NotificationsFlowException(_normalizeError(e));
    }
  }

  static Future<void> deleteNotification(int id) async {
    try {
      final response = await _authorizedDelete(Apis.notificationById(id));
      if (response.statusCode == 204) return;
      _throwIfFailed(response, 'No se pudo eliminar la notificación.');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is NotificationsFlowException) rethrow;
      throw NotificationsFlowException(_normalizeError(e));
    }
  }

  static Uri _buildNotificationsUri({
    bool? onlyRead,
    String? type,
    int? perPage,
  }) {
    final params = <String, String>{};

    if (onlyRead != null) {
      params['is_read'] = onlyRead ? '1' : '0';
    }
    if (type != null && type.trim().isNotEmpty) {
      params['type'] = type.trim();
    }
    if (perPage != null) {
      params['per_page'] = perPage.clamp(1, 100).toString();
    }

    if (params.isEmpty) return Apis.notifications;
    return Apis.notifications.replace(queryParameters: params);
  }

  static Future<http.Response> _authorizedGet(Uri uri) async {
    final headers = await _headers();
    return http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
  }

  static Future<http.Response> _authorizedPatch(Uri uri) async {
    final headers = await _headers();
    return http.patch(uri, headers: headers).timeout(const Duration(seconds: 20));
  }

  static Future<http.Response> _authorizedDelete(Uri uri) async {
    final headers = await _headers();
    return http.delete(uri, headers: headers).timeout(const Duration(seconds: 20));
  }

  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.trim().isEmpty) {
      throw const NotificationsFlowException('No se encontró un token de acceso.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) return const <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  static bool _isSuccessful(int statusCode, dynamic body) {
    if (statusCode >= 200 && statusCode < 300) return true;
    if (body is Map<String, dynamic>) {
      final success = body['success'];
      if (success is bool) return success;
    }
    return false;
  }

  static void _throwIfFailed(http.Response response, String fallback) {
    final body = _decodeBody(response.body);
    if (_isSuccessful(response.statusCode, body)) return;
    throw NotificationsFlowException(
      _extractMessage(body, fallback),
      statusCode: response.statusCode,
    );
  }

  static List<Map<String, dynamic>> _extractDataList(dynamic body) {
    if (body is List) {
      return body.whereType<Map<String, dynamic>>().toList();
    }

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();

      final notifications = body['notifications'];
      if (notifications is List) {
        return notifications.whereType<Map<String, dynamic>>().toList();
      }

      final items = body['items'];
      if (items is List) return items.whereType<Map<String, dynamic>>().toList();
    }

    return const <Map<String, dynamic>>[];
  }

  static Map<String, dynamic> _extractDataMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;

      final result = body['result'];
      if (result is Map<String, dynamic>) return result;

      return body;
    }

    return const <String, dynamic>{};
  }

  static String _extractMessage(dynamic body, String fallback) {
    if (body is Map<String, dynamic>) {
      final message = body['message'] ?? body['error'] ?? body['detail'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return fallback;
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _normalizeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}