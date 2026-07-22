import 'package:flutter/material.dart';
import 'package:worklink_local/modules/notifications/models/notification_model.dart';
import 'package:worklink_local/helpers/helpers.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: notification.isRead
          ? Style.getCardColor()
          : Style.getPrimaryColor().withValues(alpha: .08),
      shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        title: Text(
          notification.title,
          style: Style.getTextStyle(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              notification.body,
              style: Style.getTextStyle(color: Style.getObscureTextColor()),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  notification.source,
                  style: Style.getTextStyle(
                    color: Style.getPrimaryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${notification.createdAt.hour.toString().padLeft(2, '0')}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
                  style: Style.getTextStyle(color: Style.getObscureTextColor()),
                ),
              ],
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: Style.getPrimaryColor(),
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}
