import 'package:worklink_local/utils/extensions/color_extensions.dart';
import 'package:worklink_local/utils/extensions/device_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:worklink_local/helpers/helpers.dart';

class Style {
  /// ---------- Colors ---------- ///

  // Primary Colors
  static const pink = Color(0xFFF04DA1);
  static const yellow = Color(0xFFFFCA3D);
  static const grey = Color(0xFFD2D3D3);
  static const kingBlue = Color(0xFF021E42);
  static const lightBlue = Color(0xFF0057AD);

  // ------- Dynamic Colors
  static Color getPrimaryColor() => AppSettings.isDarkModeOn
      ? AppSettings.primaryLightColor
      : AppSettings.primaryLightColor;
  static Color getSecondaryColor() => AppSettings.isDarkModeOn
      ? AppSettings.secondaryLightColor
      : AppSettings.secondaryLightColor;
  static Color getAccentColor() => AppSettings.isDarkModeOn
      ? AppSettings.accentLightColor
      : AppSettings.accentLightColor;

  static Color getTextColor() => AppSettings.isDarkModeOn ? white : black;
  static Color getObscureTextColor() => AppSettings.isDarkModeOn
      ? white.withValues(alpha: .6)
      : black.withValues(alpha: .6);

  static Color getErrorColor() => AppSettings.isDarkModeOn ? red : red.darken();

  // Background
  static Color getBackgroundColor() =>
      AppSettings.isDarkModeOn ? darkScaffoldColor : lightScaffoldColor;
  static Color getCardColor() =>
      AppSettings.isDarkModeOn ? darkCardColor : lightCardColor;
  static Color getAppBarColor() =>
      AppSettings.isDarkModeOn ? darkAppBarColor : lightAppBarColor;

  // Border
  static Color getBorderColor() => AppSettings.isDarkModeOn
      ? const Color.fromARGB(255, 130, 131, 131)
      : grey;

  // Shadow
  static Color getShadowColor() => AppSettings.isDarkModeOn
      ? white.withValues(alpha: .1)
      : black.withValues(alpha: .1);

  // ------- Other Colors
  static const darkScaffoldColor = Color(0xFF1a1d21);
  static const lightScaffoldColor = Color(0xFFf3f6f9);

  static const darkAppBarColor = Color(0xFF561b39);
  static const lightAppBarColor = Color(0xFFf3f6f9);

  static const lightCardColor = Color(0xFFFFFFFF);
  static const darkCardColor = Color(0xFF212529);

  static const transparent = Colors.transparent;
  static const white = Colors.white;
  static const black = Colors.black;
  static const red = Colors.red;
  static const pulse = Color.fromARGB(255, 255, 17, 0);

  /// -------- Text Styles -------- ///
  ///
  ///
  static TextStyle getHeaderOne({
    Color? color,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    TextDecoration? decoration,
  }) => TextStyle(
    color: color ?? getPrimaryColor(),
    fontFamily: GoogleFonts.poppins().fontFamily,
    fontSize: (isLanscape ? fontSize - 5 : fontSize).sp,
    fontWeight: fontWeight,
    decoration: decoration,
    decorationColor: color ?? getPrimaryColor(),
  );

  static TextStyle getHeaderTwo({
    Color? color,
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w600,
    TextDecoration? decoration,
  }) => TextStyle(
    color: color ?? getPrimaryColor(),
    fontFamily: GoogleFonts.poppins().fontFamily,
    fontSize: (isLanscape ? fontSize - 5 : fontSize).sp,
    fontWeight: fontWeight,
    decoration: decoration,
    decorationColor: color ?? getPrimaryColor(),
  );

  static TextStyle getHeaderThree({
    Color? color,
    double fontSize = 10,
    FontWeight fontWeight = FontWeight.w400,
    TextDecoration? decoration,
  }) => TextStyle(
    color: color ?? getSecondaryColor(),
    fontFamily: GoogleFonts.poppins().fontFamily,
    fontSize: (isLanscape ? fontSize - 5 : fontSize).sp,
    fontWeight: fontWeight,
    decoration: decoration,
    decorationColor: color ?? getSecondaryColor(),
  );

  static TextStyle getTextStyle({
    Color? color,
    double fontSize = 8,
    FontWeight fontWeight = FontWeight.w400,
    TextDecoration? decoration,
  }) => TextStyle(
    color: color ?? getTextColor(),
    fontFamily: GoogleFonts.poppins().fontFamily,
    fontSize: (isLanscape ? fontSize - 5 : fontSize).sp,
    fontWeight: fontWeight,
    decoration: decoration,
    decorationColor: color ?? getTextColor(),
  );

  static TextStyle getHintStyle({
    Color? color,
    double fontSize = 8,
    FontWeight fontWeight = FontWeight.w400,
    TextDecoration? decoration,
  }) => TextStyle(
    color: color ?? getAccentColor(),
    fontFamily: GoogleFonts.poppins().fontFamily,
    fontSize: (isLanscape ? fontSize - 5 : fontSize).sp,
    fontWeight: fontWeight,
    decoration: decoration,
    decorationColor: color ?? getAccentColor(),
  );

  /// -------- Padding -------- ///

  // Values
  static const double horizontalPadding = 10;
  static const double verticalPadding = 10;

  static EdgeInsets getPadding() => EdgeInsets.symmetric(
    horizontal: horizontalPadding.w,
    vertical: verticalPadding.w,
  );

  static EdgeInsets getPaddingAll(double padding) => EdgeInsets.all(padding.w);

  static EdgeInsets getPaddingSymmetric({
    double horizontal = horizontalPadding,
    double vertical = verticalPadding,
  }) => EdgeInsets.symmetric(horizontal: horizontal.w, vertical: vertical.w);

  static EdgeInsets getPaddingHorizontal({
    double padding = horizontalPadding,
  }) => EdgeInsets.symmetric(horizontal: padding.w);

  static EdgeInsets getPaddingVertical({double padding = verticalPadding}) =>
      EdgeInsets.symmetric(vertical: padding.w);

  static EdgeInsets getOnlyPadding({
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) => EdgeInsets.only(
    left: left.w,
    right: right.w,
    top: top.w,
    bottom: bottom.w,
  );

  static EdgeInsets noPadding() => const EdgeInsets.all(0);

  static EdgeInsets getCardPadding({double padding = 10}) =>
      EdgeInsets.all(padding);

  /// -------- Border Radius -------- ///

  // Values
  static double circularBorderRadius = 10;
  static double buttonBorderRadius = 15;

  // BorderRadius
  static BorderRadius getBorderRadius() =>
      BorderRadius.circular(circularBorderRadius.r);

  static BorderRadius getButtonBorderRadius() =>
      BorderRadius.circular(buttonBorderRadius.r);

  static BorderRadius getCircularBorderRadius(double radius) =>
      BorderRadius.circular(radius.r);

  static BorderRadius getVerticalBorderRadius({
    double top = 10,
    double bottom = 10,
  }) => BorderRadius.vertical(
    top: Radius.circular(top.r),
    bottom: Radius.circular(bottom.r),
  );

  static BorderRadius getOnlyBorderRadius({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) => BorderRadius.only(
    topLeft: Radius.circular(topLeft.r),
    topRight: Radius.circular(topRight.r),
    bottomLeft: Radius.circular(bottomLeft.r),
    bottomRight: Radius.circular(bottomRight.r),
  );

  /// -------- Icon Sizes -------- ///

  static double bigIconSize = 18.w;
  static double smallIconSize = 14.w;

  // Dynamic Size
  static double width(BuildContext context, {double size = 14}) {
    return isLanscape ? size.w : size.h;
  }

  static double height(BuildContext context, {double size = 14}) {
    return isLanscape ? size.h : size.w;
  }
}
