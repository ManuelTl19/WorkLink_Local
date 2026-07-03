import 'package:worklink_local/helpers/helpers.dart';

class CustomFormTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const CustomFormTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Style.getPrimaryColor().withValues(alpha: .12),
              border: Border.all(
                color: Style.getPrimaryColor().withValues(alpha: .18),
              ),
            ),
            child: Icon(icon, color: Style.getPrimaryColor(), size: 28.w),
          ),
          SizedBox(height: 18.h),
        ],
        Text(
          title,
          style: Style.getHeaderTwo(
            color: Style.getPrimaryColor(),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 8.h),
          Text(
            subtitle!,
            style: Style.getTextStyle(
              color: Style.getObscureTextColor(),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
