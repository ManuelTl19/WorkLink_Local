import 'package:worklink_local/helpers/helpers.dart';

class CustomFormError extends StatelessWidget {
  final String message;
  final IconData icon;

  const CustomFormError({
    super.key,
    required this.message,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Style.getErrorColor().withValues(alpha: .10),
        borderRadius: Style.getBorderRadius(),
        border: Border.all(color: Style.getErrorColor().withValues(alpha: .22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Style.getErrorColor(), size: 18.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: Style.getTextStyle(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
