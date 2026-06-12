class MessageModel {
  final int id;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final bool isMine;
  final bool unread;

  const MessageModel({
    required this.id,
    required this.senderName,
    required this.text,
    required this.sentAt,
    required this.isMine,
    this.unread = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      senderName: json['sender_name'] ?? '',
      text: json['text'] ?? '',
      sentAt: DateTime.tryParse(json['sent_at'] ?? '') ?? DateTime.now(),
      isMine: json['is_mine'] ?? false,
      unread: json['unread'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_name': senderName,
      'text': text,
      'sent_at': sentAt.toIso8601String(),
      'is_mine': isMine,
      'unread': unread,
    };
  }
}
