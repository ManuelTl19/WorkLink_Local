import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class CustomFormButtons extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback onPrimary;
  final bool loading;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const CustomFormButtons({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.loading = false,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final primaryButton = SizedBox(
      width: double.infinity,
      child: CustomWidgets.button(
        onTap: loading ? () {} : onPrimary,
        color: Style.getPrimaryColor(),
        child: loading
            ? SizedBox(
                height: 18.w,
                width: 18.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Style.white,
                ),
              )
            : Text(
                primaryLabel,
                style: Style.getHeaderThree(
                  color: Style.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );

    if (secondaryLabel == null || onSecondary == null) {
      return primaryButton;
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onSecondary,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Style.getPrimaryColor().withValues(alpha: .40)),
              shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              secondaryLabel!,
              style: Style.getHeaderThree(
                color: Style.getPrimaryColor(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(child: primaryButton),
      ],
    );
  }
}
