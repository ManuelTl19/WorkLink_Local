import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/chatbot/models/chatbot_response_model.dart';

class ChatbotFlowException implements Exception {
  final int? statusCode;
  final String message;

  const ChatbotFlowException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ChatbotService {
  static Future<ChatbotResponseModel> sendMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw const ChatbotFlowException('Escribe una pregunta para continuar.');
    }
    if (trimmed.length > 2000) {
      throw const ChatbotFlowException('El mensaje no puede superar 2000 caracteres.');
    }

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw const ChatbotFlowException(
        'Sesion expirada. Inicia sesion nuevamente para usar el asistente.',
        statusCode: 401,
      );
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http
          .post(
            Apis.chatbotAuthMessage,
            headers: headers,
            body: jsonEncode({'message': trimmed}),
          )
          .timeout(const Duration(seconds: 30));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw ChatbotFlowException(
          _messageForStatus(response.statusCode, body),
          statusCode: response.statusCode,
        );
      }

      return ChatbotResponseModel.fromJson(body is Map<String, dynamic> ? body : {});
    } on TimeoutException {
      throw const ChatbotFlowException('La respuesta del chatbot tardó demasiado.');
    } catch (e) {
      if (e is ChatbotFlowException) rethrow;
      throw ChatbotFlowException(_normalizeError(e));
    }
  }

  static Future<String?> _getToken() async {
    final token = await SecureStorageService.getToken();
    if (token != null && token.trim().isNotEmpty) return token;
    return null;
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

  static String _messageForStatus(int statusCode, dynamic body) {
    if (statusCode == 401) {
      return 'Tu sesión no es válida o OpenRouter rechazó la solicitud.';
    }
    if (statusCode == 402) {
      return 'OpenRouter no tiene créditos suficientes o el modelo requiere pago.';
    }
    if (statusCode == 422) {
      return _extractMessage(body, 'El mensaje es inválido.');
    }
    if (statusCode == 429) {
      return 'Estás enviando demasiadas solicitudes. Intenta de nuevo en un momento.';
    }
    if (statusCode >= 500) {
      return _extractMessage(body, 'No se pudo generar la respuesta del chatbot.');
    }
    return _extractMessage(body, 'No se pudo generar la respuesta del chatbot.');
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

  static String _normalizeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}
