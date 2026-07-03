import 'package:worklink_local/modules/messages/models/message_model.dart';
import 'package:worklink_local/modules/messages/models/chat_model.dart';

class MessageService {
  static int _nextChatId = 5;

  static final Map<int, List<MessageModel>> _demoThreads = {
    1: [
      MessageModel(
        id: 1,
        senderName: 'Ana',
        text: 'Hola, ¿ya viste el nuevo mensaje de prueba?',
        sentAt: DateTime.now().subtract(const Duration(minutes: 32)),
        isMine: false,
        unread: true,
      ),
      MessageModel(
        id: 2,
        senderName: 'Tú',
        text: 'Sí, ya funciona la pantalla de mensajes.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 28)),
        isMine: true,
      ),
      MessageModel(
        id: 3,
        senderName: 'Ana',
        text: 'Perfecto. Luego conectamos la API real.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 24)),
        isMine: false,
      ),
      MessageModel(
        id: 4,
        senderName: 'Tú',
        text: 'Por ahora solo es una prueba visual.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 20)),
        isMine: true,
      ),
    ],
    2: [
      MessageModel(
        id: 1,
        senderName: 'Carlos',
        text: '¿Me compartes el avance de hoy?',
        sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 12)),
        isMine: false,
        unread: false,
      ),
      MessageModel(
        id: 2,
        senderName: 'Tú',
        text: 'Claro, te lo mando ahorita.',
        sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 6)),
        isMine: true,
      ),
    ],
    3: [
      MessageModel(
        id: 1,
        senderName: 'Equipo soporte',
        text: 'Tu solicitud fue recibida.',
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
        isMine: false,
        unread: true,
      ),
      MessageModel(
        id: 2,
        senderName: 'Tú',
        text: 'Gracias, quedo pendiente.',
        sentAt: DateTime.now().subtract(
          const Duration(days: 1, hours: 1, minutes: 10),
        ),
        isMine: true,
      ),
    ],
    4: [
      MessageModel(
        id: 1,
        senderName: 'María',
        text: '¿A qué hora puedes revisar el contrato?',
        sentAt: DateTime.now().subtract(const Duration(days: 2, minutes: 40)),
        isMine: false,
        unread: false,
      ),
    ],
  };

  static final List<ChatModel> _demoChats = [
    ChatModel(
      id: 1,
      name: 'Ana',
      avatarSeed: 'Ana',
      isOnline: true,
      lastMessage: 'Perfecto. Luego conectamos la API real.',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 24)),
      unreadCount: 1,
    ),
    ChatModel(
      id: 2,
      name: 'Carlos',
      avatarSeed: 'Carlos',
      isOnline: false,
      lastMessage: 'Claro, te lo mando ahorita.',
      lastMessageAt: DateTime.now().subtract(
        const Duration(hours: 2, minutes: 6),
      ),
      unreadCount: 0,
    ),
    ChatModel(
      id: 3,
      name: 'Equipo soporte',
      avatarSeed: 'Soporte',
      isOnline: false,
      lastMessage: 'Tu solicitud fue recibida.',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      unreadCount: 3,
    ),
    ChatModel(
      id: 4,
      name: 'María',
      avatarSeed: 'María',
      isOnline: true,
      lastMessage: '¿A qué hora puedes revisar el contrato?',
      lastMessageAt: DateTime.now().subtract(
        const Duration(days: 2, minutes: 40),
      ),
      unreadCount: 0,
    ),
  ];

  static Future<ChatModel> getOrCreateChat({
    required String name,
    required String avatarSeed,
    String? subtitle,
    String? avatarUrl,
    bool isOnline = false,
    int? relatedEntityId,
    String? relatedEntityType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 180));

    for (final chat in _demoChats) {
      if (chat.relatedEntityId == relatedEntityId &&
          chat.relatedEntityType == relatedEntityType) {
        return chat;
      }
    }

    final chat = ChatModel(
      id: _nextChatId++,
      name: name,
      avatarSeed: avatarSeed,
      isOnline: isOnline,
      lastMessage: 'Nueva conversación',
      lastMessageAt: DateTime.now(),
      unreadCount: 0,
      subtitle: subtitle,
      avatarUrl: avatarUrl,
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
    );

    _demoChats.insert(0, chat);
    _demoThreads[chat.id] = <MessageModel>[];
    return chat;
  }

  static Future<List<ChatModel>> loadDemoChats() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List<ChatModel>.from(_demoChats);
  }

  static Future<List<MessageModel>> loadDemoConversation(int chatId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return List<MessageModel>.from(_demoThreads[chatId] ?? const []);
  }

  static Future<MessageModel> sendDemoMessage({
    required int chatId,
    required int nextId,
    required String text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final newMessage = MessageModel(
      id: nextId,
      senderName: 'Tú',
      text: text.trim(),
      sentAt: DateTime.now(),
      isMine: true,
    );

    final thread = _demoThreads[chatId] ?? <MessageModel>[];
    _demoThreads[chatId] = [...thread, newMessage];

    final chatIndex = _demoChats.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      final chat = _demoChats[chatIndex];
      _demoChats[chatIndex] = ChatModel(
        id: chat.id,
        name: chat.name,
        avatarSeed: chat.avatarSeed,
        isOnline: chat.isOnline,
        lastMessage: newMessage.text,
        lastMessageAt: newMessage.sentAt,
        unreadCount: chat.unreadCount,
        subtitle: chat.subtitle,
        avatarUrl: chat.avatarUrl,
        relatedEntityId: chat.relatedEntityId,
        relatedEntityType: chat.relatedEntityType,
      );
    }

    return newMessage;
  }
}
