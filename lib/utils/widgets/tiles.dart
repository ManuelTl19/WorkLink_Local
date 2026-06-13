import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/extensions/color_extensions.dart';

class Tiles {
  static Widget settingTile({
    required String title,
    String? subtitle,
    required Widget icon,
    required VoidCallback onTap,
    bool dense = false,
    Color? titleColor,
    Color? subtitleColor,
    Color? iconColor,
    Color? iconBackgroundColor,
    Color? trailingColor,
  }) {
    return InkWell(
      onTap: () => onTap(),
      borderRadius: Style.getBorderRadius(),
      splashColor: Style.getPrimaryColor().withValues(alpha: 0.2),
      child: Padding(
        padding: dense
            ? EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h)
            : Style.getPadding(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(dense ? 6.w : 8.w),
              decoration: BoxDecoration(
                color:
                    iconBackgroundColor ??
                    (AppSettings.isDarkModeOn
                        ? Style.getBackgroundColor().lighten()
                        : Style.getBackgroundColor().darken()),
                borderRadius: Style.getCircularBorderRadius(100),
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: iconColor ?? Style.getSecondaryColor(),
                  size: dense ? 18.w : 20.w,
                ),
                child: icon,
              ),
            ),
            SizedBox(width: dense ? 10.w : 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Style.getTextStyle(
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: Style.getTextStyle(color: subtitleColor),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: trailingColor ?? Style.getObscureTextColor(),
              size: dense ? 14.w : 16.w,
            ),
          ],
        ),
      ),
    );
  }

  static Widget expansionTile({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      iconColor: Style.getTextColor(),
      collapsedIconColor: Style.getObscureTextColor(),
      title: Text(title, style: Style.getHeaderTwo()),
      subtitle: Text(subtitle, style: Style.getHeaderThree()),

      children: children,
    );
  }

  static Widget colorExpansionTile({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    Function? onTap,
  }) {
    return ExpansionTile(
      iconColor: Style.getTextColor(),
      collapsedIconColor: Style.getObscureTextColor(),
      title: Text(
        title,
        style: TextStyle(
          color: Style.getPrimaryColor(),
          fontSize: 16.w,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: GestureDetector(
        onTap: () => onTap!(),
        child: Text(
          MultiLanguages.of(context)!.translate('reset_colors'),
          style: Style.getHeaderThree(decoration: TextDecoration.underline),
        ),
      ),

      children: children,
    );
  }

  static Widget switchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool dense = false,
    Color? titleColor,
    Color? subtitleColor,
    Color? iconColor,
  }) {
    return ListTile(
      dense: dense,
      contentPadding: dense
          ? EdgeInsets.symmetric(horizontal: 14.w)
          : EdgeInsets.zero,
      leading: Container(
        width: dense ? 26.w : 30.w,
        height: dense ? 26.w : 30.w,
        decoration: BoxDecoration(
          color: AppSettings.isDarkModeOn
              ? Style.getBackgroundColor().darken(.3)
              : Style.getBackgroundColor().lighten(.3),
          borderRadius: Style.getCircularBorderRadius(100),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Style.getSecondaryColor(),
          size: dense ? 16.w : 20.w,
        ),
      ),
      title: Text(
        title,
        style: Style.getTextStyle(
          fontWeight: FontWeight.bold,
          color: titleColor,
        ),
      ),
      subtitle: Text(subtitle, style: Style.getTextStyle(color: subtitleColor)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Style.getPrimaryColor(),
        activeTrackColor: Style.getPrimaryColor().withValues(alpha: 0.3),
        inactiveTrackColor: Style.getObscureTextColor(),
        inactiveThumbColor: Style.getSecondaryColor(),
      ),
    );
  }
}
