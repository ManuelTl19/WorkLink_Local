class NotificationModel {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String source;
  final String type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.source = 'WorkLink',
    this.type = '',
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _intValue(json['id']),
      title: _stringValue(json['title'] ?? json['subject'] ?? 'Notificación'),
      body: _stringValue(json['body'] ?? json['message'] ?? json['content']),
      createdAt: _dateValue(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      isRead: _boolValue(json['is_read'] ?? json['isRead'] ?? json['read']),
      source: _stringValue(json['source'] ?? json['module'] ?? 'WorkLink'),
      type: _stringValue(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'source': source,
      'type': type,
    };
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _boolValue(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase().trim() ?? '';
    return normalized == 'true' || normalized == '1';
  }

  static String _stringValue(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static DateTime? _dateValue(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
