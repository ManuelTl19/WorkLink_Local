import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';

class MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final bool enabled;

  const MessageComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPickImage,
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
            InkWell(
              onTap: enabled ? onPickImage : null,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: Style.getBackgroundColor(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.image_rounded,
                  color: enabled
                      ? Style.getPrimaryColor()
                      : Style.getObscureTextColor(),
                  size: 18.w,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: CustomInputField(
                controller: controller,
                label: 'Mensaje',
                hintText: 'Escribe un mensaje de prueba...',
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (_) => onSend(),
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
