import 'dart:io';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/messages/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  String _timeLabel(DateTime sentAt) {
    final hour = sentAt.hour.toString().padLeft(2, '0');
    final minute = sentAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  IconData _statusIcon() {
    switch (message.status) {
      case MessageDeliveryStatus.sending:
        return Icons.schedule_rounded;
      case MessageDeliveryStatus.sent:
        return Icons.check_rounded;
      case MessageDeliveryStatus.delivered:
        return Icons.done_all_rounded;
      case MessageDeliveryStatus.read:
        return Icons.done_all_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.isMine
        ? Style.getPrimaryColor()
        : Style.getCardColor();
    final textColor = message.isMine ? Style.white : Style.getTextColor();

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 6.h,
          bottom: 6.h,
          left: message.isMine ? 40.w : 0,
          right: message.isMine ? 0 : 40.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(message.isMine ? 18 : 4),
            bottomRight: Radius.circular(message.isMine ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Style.getShadowColor(),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!message.isMine)
              Text(
                message.senderName,
                style: Style.getHeaderThree(
                  color: Style.getSecondaryColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (!message.isMine) SizedBox(height: 4.h),
            Text(
              message.text,
              style: Style.getTextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (message.isImage) ...[
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: message.imageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: message.imageUrl,
                        width: 180.w,
                        height: 160.h,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 180.w,
                          height: 160.h,
                          color: Style.getBackgroundColor(),
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: Style.getObscureTextColor(),
                          ),
                        ),
                      )
                    : message.imageUrl.startsWith('assets/')
                    ? Image.asset(
                        message.imageUrl,
                        width: 180.w,
                        height: 160.h,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(message.imageUrl),
                        width: 180.w,
                        height: 160.h,
                        fit: BoxFit.cover,
                      ),
              ),
            ],
            SizedBox(height: 6.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _timeLabel(message.sentAt),
                  style: Style.getHeaderThree(
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: 10.w,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                if (message.isMine) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    _statusIcon(),
                    size: 14.w,
                    color: message.status == MessageDeliveryStatus.read
                        ? Style.getSecondaryColor()
                        : textColor.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
            if (message.isMine && message.status == MessageDeliveryStatus.sending)
              Text(
                'Enviando...',
                style: Style.getHeaderThree(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 9.w,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
