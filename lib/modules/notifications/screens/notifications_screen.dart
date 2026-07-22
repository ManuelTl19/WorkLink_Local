import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/notifications/components/notification_tile.dart';
import 'package:worklink_local/modules/notifications/services/notification_service.dart';
import 'package:worklink_local/modules/notifications/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<NotificationModel> _notifications = [];
  bool? _onlyRead;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
    });
    _notifications = await NotificationService.fetchNotifications(
      onlyRead: _onlyRead,
    );
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _markAsRead(int id) async {
    await NotificationService.markAsRead(id);
    await _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    await NotificationService.markAllAsRead();
    await _loadNotifications();
  }

  void _changeFilter(bool? value) {
    setState(() {
      _onlyRead = value;
    });
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          'Notificaciones',
          style: Style.getHeaderTwo(color: Style.getTextColor()),
        ),
        elevation: 0,
        backgroundColor: Style.getBackgroundColor(),
        foregroundColor: Style.getTextColor(),
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: Icon(
              Icons.done_all_rounded,
              color: Style.getPrimaryColor(),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView(
          padding: Style.getPadding(),
          children: [
            Row(
              children: [
                _filterChip(
                  label: 'Todas',
                  selected: _onlyRead == null,
                  onTap: () => _changeFilter(null),
                ),
                SizedBox(width: 8.w),
                _filterChip(
                  label: 'No leídas',
                  selected: _onlyRead == false,
                  onTap: () => _changeFilter(false),
                ),
                SizedBox(width: 8.w),
                _filterChip(
                  label: 'Leídas',
                  selected: _onlyRead == true,
                  onTap: () => _changeFilter(true),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (_loading)
              ...List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Shimmer.fromColors(
                    baseColor: Style.getCardColor(),
                    highlightColor: Style.getPrimaryColor().withValues(
                      alpha: .10,
                    ),
                    child: Container(
                      height: 92.h,
                      decoration: BoxDecoration(
                        color: Style.getCardColor(),
                        borderRadius: Style.getBorderRadius(),
                      ),
                    ),
                  ),
                ),
              )
            else if (_notifications.isEmpty)
              Card(
                color: Style.getCardColor(),
                shape: RoundedRectangleBorder(
                  borderRadius: Style.getBorderRadius(),
                ),
                child: Container(
                  padding: Style.getPadding(),
                  height: 140.h,
                  child: Center(
                    child: Text(
                      'No hay notificaciones para este filtro',
                      style: Style.getHeaderThree(
                        color: Style.getObscureTextColor(),
                      ),
                    ),
                  ),
                ),
              )
            else
              ..._notifications.map(
                (notification) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: NotificationTile(
                    notification: notification,
                    onTap: () => _markAsRead(notification.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected
              ? Style.getPrimaryColor().withValues(alpha: .14)
              : Style.getBackgroundColor(),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Style.getPrimaryColor().withValues(alpha: .35)
                : Style.getObscureTextColor().withValues(alpha: .12),
          ),
        ),
        child: Text(
          label,
          style: Style.getTextStyle(
            color: selected ? Style.getPrimaryColor() : Style.getTextColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
