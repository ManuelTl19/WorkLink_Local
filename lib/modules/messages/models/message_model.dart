enum MessageType { text, image }

extension MessageTypeX on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
    }
  }
}

MessageType messageTypeFromValue(Object? value) {
  final text = value?.toString().toLowerCase().trim() ?? '';
  return text == 'image' ? MessageType.image : MessageType.text;
}

enum MessageDeliveryStatus { sending, sent, delivered, read }

extension MessageDeliveryStatusX on MessageDeliveryStatus {
  String get value {
    switch (this) {
      case MessageDeliveryStatus.sending:
        return 'sending';
      case MessageDeliveryStatus.sent:
        return 'sent';
      case MessageDeliveryStatus.delivered:
        return 'delivered';
      case MessageDeliveryStatus.read:
        return 'read';
    }
  }
}

MessageDeliveryStatus messageStatusFromValue(Object? value) {
  final text = value?.toString().toLowerCase().trim() ?? '';
  if (text == 'sending') return MessageDeliveryStatus.sending;
  if (text == 'delivered') return MessageDeliveryStatus.delivered;
  if (text == 'read') return MessageDeliveryStatus.read;
  return MessageDeliveryStatus.sent;
}

class MessageModel {
  final int id;
  final String senderName;
  final String text;
  final String imageUrl;
  final DateTime sentAt;
  final bool isMine;
  final bool unread;
  final MessageType type;
  final MessageDeliveryStatus status;

  const MessageModel({
    required this.id,
    required this.senderName,
    required this.text,
    this.imageUrl = '',
    required this.sentAt,
    required this.isMine,
    this.unread = false,
    this.type = MessageType.text,
    this.status = MessageDeliveryStatus.sent,
  });

  bool get isImage => type == MessageType.image;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      senderName: json['sender_name'] ?? '',
      text: json['text'] ?? '',
      imageUrl: json['image_url'] ?? '',
      sentAt: DateTime.tryParse(json['sent_at'] ?? '') ?? DateTime.now(),
      isMine: json['is_mine'] ?? false,
      unread: json['unread'] ?? false,
      type: messageTypeFromValue(json['type']),
      status: messageStatusFromValue(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_name': senderName,
      'text': text,
      'image_url': imageUrl,
      'sent_at': sentAt.toIso8601String(),
      'is_mine': isMine,
      'unread': unread,
      'type': type.value,
      'status': status.value,
    };
  }
}
