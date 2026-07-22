class NotificationModel {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String source;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.source = 'WorkLink',
  });
}
