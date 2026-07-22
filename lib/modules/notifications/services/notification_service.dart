import 'package:worklink_local/modules/notifications/models/notification_model.dart';

class NotificationService {
  static final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 1,
      title: 'Nuevo mensaje recibido',
      body: 'Tienes un mensaje nuevo de Carla sobre el proyecto.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      isRead: false,
      source: 'Mensajería',
    ),
    NotificationModel(
      id: 2,
      title: 'Solicitud aprobada',
      body: 'Tu solicitud de trabajo ha sido aprobada por el cliente.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      isRead: false,
      source: 'Solicitudes',
    ),
    NotificationModel(
      id: 3,
      title: 'Pago listo',
      body: 'El pago de tu última orden se ha procesado correctamente.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 5)),
      isRead: true,
      source: 'Finanzas',
    ),
    NotificationModel(
      id: 4,
      title: 'Recordatorio de perfil',
      body: 'Actualiza tu portafolio para aparecer en más búsquedas.',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
      source: 'Usuario',
    ),
  ];

  static Future<List<NotificationModel>> fetchNotifications({bool? onlyRead}) async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (onlyRead == null) {
      return List<NotificationModel>.from(_notifications);
    }

    return _notifications
        .where((notification) => notification.isRead == onlyRead)
        .toList();
  }

  static Future<void> markAsRead(int id) async {
    await Future.delayed(const Duration(milliseconds: 160));
    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );
    if (index >= 0) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        createdAt: _notifications[index].createdAt,
        isRead: true,
        source: _notifications[index].source,
      );
    }
  }

  static Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 200));

    for (var i = 0; i < _notifications.length; i++) {
      final current = _notifications[i];
      _notifications[i] = NotificationModel(
        id: current.id,
        title: current.title,
        body: current.body,
        createdAt: current.createdAt,
        isRead: true,
        source: current.source,
      );
    }
  }

  static Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _notifications.where((notification) => !notification.isRead).length;
  }
}
