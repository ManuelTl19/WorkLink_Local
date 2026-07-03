import 'package:worklink_local/helpers/helpers.dart';

class CustomFormCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double borderRadius;

  const CustomFormCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color ?? Style.getCardColor().withValues(alpha: .12),
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(
          color: Style.getBorderColor().withValues(alpha: .14),
        ),
      ),
      child: child,
    );
  }
}
