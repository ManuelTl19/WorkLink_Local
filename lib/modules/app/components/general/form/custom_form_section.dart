import 'package:worklink_local/modules/app/components/general/form/custom_form_card.dart';
import 'package:worklink_local/helpers/helpers.dart';

class CustomFormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const CustomFormSection({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Style.getHeaderThree(
              color: Style.getTextColor(),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: Style.getTextStyle(
                color: Style.getObscureTextColor(),
                fontSize: 9,
              ),
            ),
          ],
          if (children.isNotEmpty) ...[
            SizedBox(height: 12.h),
            ...children,
          ],
        ],
      ),
    );
  }
}
