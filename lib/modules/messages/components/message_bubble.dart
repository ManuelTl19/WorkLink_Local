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
            SizedBox(height: 6.h),
            Text(
              _timeLabel(message.sentAt),
              style: Style.getHeaderThree(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 10.w,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
