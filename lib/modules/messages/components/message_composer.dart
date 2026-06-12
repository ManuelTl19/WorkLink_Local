import 'package:worklink_local/helpers/helpers.dart';

class MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  const MessageComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        boxShadow: [
          BoxShadow(
            color: Style.getShadowColor(),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje de prueba...',
                  filled: true,
                  fillColor: Style.getBackgroundColor(),
                  border: OutlineInputBorder(
                    borderRadius: Style.getBorderRadius(),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            InkWell(
              onTap: enabled ? onSend : null,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: enabled ? Style.getPrimaryColor() : Style.grey,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send_rounded, color: Style.white, size: 18.w),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
