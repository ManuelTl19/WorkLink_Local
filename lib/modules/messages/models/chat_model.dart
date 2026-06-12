class ChatModel {
  final int id;
  final String name;
  final String avatarSeed;
  final bool isOnline;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const ChatModel({
    required this.id,
    required this.name,
    required this.avatarSeed,
    required this.isOnline,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });
}
