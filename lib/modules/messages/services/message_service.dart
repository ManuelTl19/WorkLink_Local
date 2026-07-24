import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/companies/services/companies_service.dart';
import 'package:worklink_local/modules/freelancers/services/freelancers_service.dart';
import 'package:worklink_local/modules/messages/models/chat_model.dart';
import 'package:worklink_local/modules/messages/models/message_model.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';

class MessagesFlowException implements Exception {
  final int? statusCode;
  final String message;

  const MessagesFlowException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class MessageService {
  static final CompaniesService _companiesService = CompaniesService();

  static Future<ChatModel> getOrCreateChat({
    required String name,
    required String avatarSeed,
    String? subtitle,
    String? avatarUrl,
    bool isOnline = false,
    int? relatedEntityId,
    String? relatedEntityType,
  }) async {
    final resolvedUserId = await _resolveConversationUserId(
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
    );

    if (resolvedUserId != null) {
      final conversations = await loadDemoChats();
      for (final chat in conversations) {
        if (chat.id == resolvedUserId ||
            chat.relatedEntityId == resolvedUserId) {
          return chat.copyWith(
            name: chat.name.isNotEmpty ? chat.name : name,
            avatarSeed: chat.avatarSeed.isNotEmpty
                ? chat.avatarSeed
                : avatarSeed,
            subtitle: chat.subtitle ?? subtitle,
            avatarUrl: chat.avatarUrl ?? avatarUrl,
            relatedEntityId: resolvedUserId,
            relatedEntityType:
                relatedEntityType ?? chat.relatedEntityType ?? 'user',
          );
        }
      }
    }

    return ChatModel(
      id: resolvedUserId ?? relatedEntityId ?? 0,
      name: name,
      avatarSeed: avatarSeed,
      isOnline: isOnline,
      lastMessage: 'Nueva conversación',
      lastMessageAt: DateTime.now(),
      unreadCount: 0,
      subtitle: subtitle,
      avatarUrl: avatarUrl,
      relatedEntityId: resolvedUserId ?? relatedEntityId,
      relatedEntityType: relatedEntityType,
    );
  }

  static Future<List<ChatModel>> loadDemoChats() async {
    return getConversations();
  }

  static Future<List<MessageModel>> loadDemoConversation(int chatId) async {
    final messages = await getConversationByUserId(chatId);
    await markConversationAsRead(chatId);
    return messages;
  }

  static Future<MessageModel> sendDemoMessage({
    required int chatId,
    required int nextId,
    required String text,
  }) async {
    final message = await sendMessage(receiverId: chatId, content: text);
    return message.id == 0
        ? MessageModel(
            id: nextId,
            senderName: message.senderName,
            text: message.text,
            imageUrl: message.imageUrl,
            sentAt: message.sentAt,
            isMine: message.isMine,
            unread: message.unread,
            type: message.type,
            status: message.status,
          )
        : message;
  }

  static Future<MessageModel> sendDemoImageMessage({
    required int chatId,
    required int nextId,
    required String imageUrl,
  }) async {
    final message = await sendMessage(
      receiverId: chatId,
      content: 'Imagen adjunta',
    );

    return MessageModel(
      id: message.id == 0 ? nextId : message.id,
      senderName: message.senderName.isNotEmpty ? message.senderName : 'Tú',
      text: message.text.isNotEmpty ? message.text : 'Imagen adjunta',
      imageUrl: imageUrl,
      sentAt: message.sentAt,
      isMine: true,
      unread: false,
      type: MessageType.image,
      status: message.status,
    );
  }

  static Future<List<ChatModel>> getConversations() async {
    try {
      final response = await _authorizedGet(Apis.messageConversations);
      final body = _decodeBody(response.body);

      if (!_isSuccessful(response.statusCode, body)) {
        throw MessagesFlowException(
          _extractMessage(body, 'No se pudieron cargar las conversaciones.'),
          statusCode: response.statusCode,
        );
      }

      final items = _extractDataList(body);
      final chats = items.map(_chatFromConversationJson).toList();
      chats.sort(
        (left, right) => right.lastMessageAt.compareTo(left.lastMessageAt),
      );
      return chats;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is MessagesFlowException) rethrow;
      throw MessagesFlowException(_normalizeError(e));
    }
  }

  static Future<List<MessageModel>> getConversationByUserId(
    int userId, {
    int perPage = 30,
  }) async {
    try {
      final uri = Apis.messageConversationByUserId(userId).replace(
        queryParameters: {'per_page': perPage.clamp(1, 100).toString()},
      );
      final response = await _authorizedGet(uri);
      final body = _decodeBody(response.body);

      if (!_isSuccessful(response.statusCode, body)) {
        throw MessagesFlowException(
          _extractMessage(body, 'No se pudo cargar la conversación.'),
          statusCode: response.statusCode,
        );
      }

      final currentUserId = await _currentUserId();
      final messages = _extractDataList(
        body,
      ).map((item) => _messageFromJson(item, currentUserId)).toList();
      messages.sort((left, right) => left.sentAt.compareTo(right.sentAt));
      return messages;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is MessagesFlowException) rethrow;
      throw MessagesFlowException(_normalizeError(e));
    }
  }

  static Future<MessageModel> sendMessage({
    required int receiverId,
    required String content,
  }) async {
    try {
      final trimmed = content.trim();
      if (trimmed.isEmpty) {
        throw MessagesFlowException(
          'El contenido del mensaje no puede ir vacío.',
        );
      }
      if (trimmed.length > 5000) {
        throw MessagesFlowException(
          'El contenido no puede superar 5000 caracteres.',
        );
      }

      final currentUserId = await _currentUserId();
      if (currentUserId != null && receiverId == currentUserId) {
        throw MessagesFlowException(
          'No te puedes enviar un mensaje a ti mismo.',
        );
      }

      final response = await _authorizedPost(
        Apis.messages,
        body: jsonEncode({'receiver_id': receiverId, 'content': trimmed}),
      );

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw MessagesFlowException(
          _extractMessage(body, 'No se pudo enviar el mensaje.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) {
        return _messageFromJson(data, currentUserId, fallbackMine: true);
      }

      return MessageModel(
        id: 0,
        senderName: 'Tú',
        text: trimmed,
        sentAt: DateTime.now(),
        isMine: true,
        unread: false,
        type: MessageType.text,
        status: MessageDeliveryStatus.sent,
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is MessagesFlowException) rethrow;
      throw MessagesFlowException(_normalizeError(e));
    }
  }

  static Future<void> markConversationAsRead(int userId) async {
    try {
      final response = await _authorizedPatch(
        Apis.messageReadAllByUserId(userId),
      );
      _throwIfFailed(response, 'No se pudo marcar la conversación como leída.');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is MessagesFlowException) rethrow;
      throw MessagesFlowException(_normalizeError(e));
    }
  }

  static Future<void> markMessageAsRead(int messageId) async {
    try {
      final response = await _authorizedPatch(Apis.messageReadById(messageId));
      _throwIfFailed(response, 'No se pudo marcar el mensaje como leído.');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is MessagesFlowException) rethrow;
      throw MessagesFlowException(_normalizeError(e));
    }
  }

  static Future<void> deleteMessage(int messageId) async {
    try {
      final response = await _authorizedDelete(Apis.messageById(messageId));
      if (response.statusCode == 204) return;
      _throwIfFailed(response, 'No se pudo eliminar el mensaje.');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is MessagesFlowException) rethrow;
      throw MessagesFlowException(_normalizeError(e));
    }
  }

  static Future<bool> canDeleteMessage(MessageModel message) async {
    final currentUser = await _currentUser();
    if (_isAdminUser(currentUser)) return true;
    return message.isMine && message.status != MessageDeliveryStatus.read;
  }

  static Future<int?> _currentUserId() async {
    final user = await _currentUser();
    return user?.id;
  }

  static Future<UserModel?> _currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(Constants.userEmailKey);
    if (rawUser == null || rawUser.trim().isEmpty) return null;

    try {
      return UserModel.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static bool _isAdminUser(UserModel? user) {
    if (user == null) return false;

    final roles = user.roles.map((role) => role.toLowerCase().trim()).toList();
    final type = user.tipoCuenta.toLowerCase().trim();

    return roles.contains('admin') ||
        roles.contains('administrador') ||
        type == 'admin' ||
        type == 'administrador';
  }

  static Future<int?> _resolveConversationUserId({
    required int? relatedEntityId,
    required String? relatedEntityType,
  }) async {
    if (relatedEntityId == null || relatedEntityId <= 0) return null;

    final normalizedType = relatedEntityType?.toLowerCase().trim() ?? '';
    if (normalizedType == 'company') {
      final company = await _companiesService.getPublicCompanyById(
        relatedEntityId,
      );
      return company?.userId ?? relatedEntityId;
    }

    if (normalizedType == 'freelancer') {
      final freelancer = await FreelancersService.getProfileById(
        relatedEntityId,
      );
      return freelancer?.userId ?? relatedEntityId;
    }

    return relatedEntityId;
  }

  static ChatModel _chatFromConversationJson(Map<String, dynamic> json) {
    final otherUser = _extractUserMap(
      json['user'] ?? json['other_user'] ?? json['participant'],
    );
    final otherUserId = _intValue(
      json['user_id'] ??
          json['other_user_id'] ??
          json['conversation_user_id'] ??
          json['participant_id'] ??
          otherUser['id'],
    );
    final displayName = _stringValue(
      json['user_name'] ??
          json['other_user_name'] ??
          json['conversation_user_name'] ??
          json['participant_name'] ??
          otherUser['name'] ??
          otherUser['full_name'] ??
          otherUser['nombre'] ??
          otherUser['fullName'],
    );

    final avatarUrl = _stringValue(
      json['avatar_url'] ??
          json['photo_url'] ??
          json['profile_photo_url'] ??
          otherUser['avatar_url'] ??
          otherUser['photo_url'] ??
          otherUser['profile_photo_url'],
    );

    final lastMessage = _extractLastMessageText(json);
    final lastMessageAt = _extractDateTime(
      json['last_message_at'] ??
          json['lastMessageAt'] ??
          json['updated_at'] ??
          json['updatedAt'] ??
          json['last_message_created_at'],
    );

    return ChatModel(
      id: otherUserId,
      name: displayName.isNotEmpty ? displayName : 'Conversación',
      avatarSeed: displayName.isNotEmpty ? displayName : 'Chat',
      isOnline: _boolValue(
        json['is_online'] ?? json['online'] ?? otherUser['is_online'],
      ),
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt ?? DateTime.now(),
      unreadCount: _intValue(json['unread_count'] ?? json['unreadCount']),
      subtitle: _stringOrNull(
        json['subtitle'] ??
            json['description'] ??
            otherUser['role'] ??
            otherUser['tipo_cuenta'],
      ),
      avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
      relatedEntityId: otherUserId > 0 ? otherUserId : null,
      relatedEntityType: 'user',
    );
  }

  static MessageModel _messageFromJson(
    Map<String, dynamic> json,
    int? currentUserId, {
    bool fallbackMine = false,
  }) {
    final senderMap = _extractUserMap(json['sender']);
    final senderId = _intNullable(
      json['sender_id'] ?? json['senderId'] ?? senderMap['id'],
    );
    final mine = json['is_mine'] is bool
        ? json['is_mine'] as bool
        : json['isMine'] is bool
        ? json['isMine'] as bool
        : currentUserId != null && senderId != null
        ? senderId == currentUserId
        : fallbackMine;

    final readFlag = _boolValue(
      json['is_read'] ?? json['read'] ?? json['read_at'] ?? json['readAt'],
    );
    final status = mine
        ? (readFlag ? MessageDeliveryStatus.read : MessageDeliveryStatus.sent)
        : (readFlag
              ? MessageDeliveryStatus.read
              : MessageDeliveryStatus.delivered);

    return MessageModel(
      id: _intValue(json['id']),
      senderName: _stringValue(
        json['sender_name'] ??
            json['senderName'] ??
            senderMap['name'] ??
            senderMap['full_name'] ??
            senderMap['nombre'] ??
            (mine ? 'Tú' : 'Usuario'),
      ),
      text: _stringValue(
        json['content'] ?? json['text'] ?? json['message'] ?? '',
      ),
      imageUrl: _stringValue(json['image_url'] ?? json['imageUrl']),
      sentAt:
          _extractDateTime(
            json['sent_at'] ?? json['created_at'] ?? json['createdAt'],
          ) ??
          DateTime.now(),
      isMine: mine,
      unread: !readFlag && !mine,
      type: messageTypeFromValue(
        json['type'] ?? (json['image_url'] != null ? 'image' : 'text'),
      ),
      status: status,
    );
  }

  static Future<http.Response> _authorizedGet(Uri uri) async {
    final headers = await _headers();
    return http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
  }

  static Future<http.Response> _authorizedPost(
    Uri uri, {
    required String body,
  }) async {
    final headers = await _headers();
    return http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));
  }

  static Future<http.Response> _authorizedPatch(Uri uri) async {
    final headers = await _headers();
    return http
        .patch(uri, headers: headers)
        .timeout(const Duration(seconds: 20));
  }

  static Future<http.Response> _authorizedDelete(Uri uri) async {
    final headers = await _headers();
    return http
        .delete(uri, headers: headers)
        .timeout(const Duration(seconds: 20));
  }

  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
    throw MessagesFlowException(
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

      if (data is Map<String, dynamic>) {
        final nestedMessages = data['messages'];
        if (nestedMessages is List) {
          return nestedMessages.whereType<Map<String, dynamic>>().toList();
        }

        final nestedConversations = data['conversations'];
        if (nestedConversations is List) {
          return nestedConversations.whereType<Map<String, dynamic>>().toList();
        }

        final nestedItems = data['items'];
        if (nestedItems is List) {
          return nestedItems.whereType<Map<String, dynamic>>().toList();
        }
      }

      final messages = body['messages'];
      if (messages is List)
        return messages.whereType<Map<String, dynamic>>().toList();

      final conversations = body['conversations'];
      if (conversations is List)
        return conversations.whereType<Map<String, dynamic>>().toList();

      final items = body['items'];
      if (items is List)
        return items.whereType<Map<String, dynamic>>().toList();
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

    if (body is List && body.isNotEmpty && body.first is Map<String, dynamic>) {
      return body.first as Map<String, dynamic>;
    }

    return const <String, dynamic>{};
  }

  static Map<String, dynamic> _extractUserMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return const <String, dynamic>{};
  }

  static String _extractLastMessageText(Map<String, dynamic> json) {
    final message =
        json['last_message'] ?? json['lastMessage'] ?? json['message'];
    if (message is Map<String, dynamic>) {
      return _stringValue(
        message['content'] ?? message['text'] ?? message['message'],
      );
    }

    return _stringValue(message);
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

  static DateTime? _extractDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String _stringValue(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static String? _stringOrNull(dynamic value) {
    final normalized = _stringValue(value);
    return normalized.isEmpty ? null : normalized;
  }

  static bool _boolValue(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase().trim() ?? '';
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _intNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String _normalizeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}
