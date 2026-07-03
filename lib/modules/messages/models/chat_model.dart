class ChatModel {
  final int id;
  final String name;
  final String avatarSeed;
  final bool isOnline;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final String? subtitle;
  final String? avatarUrl;
  final int? relatedEntityId;
  final String? relatedEntityType;

  const ChatModel({
    required this.id,
    required this.name,
    required this.avatarSeed,
    required this.isOnline,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    this.subtitle,
    this.avatarUrl,
    this.relatedEntityId,
    this.relatedEntityType,
  });

  ChatModel copyWith({
    int? id,
    String? name,
    String? avatarSeed,
    bool? isOnline,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    String? subtitle,
    String? avatarUrl,
    int? relatedEntityId,
    String? relatedEntityType,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      isOnline: isOnline ?? this.isOnline,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      subtitle: subtitle ?? this.subtitle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
    );
  }
}
