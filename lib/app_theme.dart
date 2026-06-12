import 'package:worklink_local/helpers/helpers.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Style.lightScaffoldColor,
    primaryColor: Style.pink,
    appBarTheme: const AppBarTheme(
      backgroundColor: Style.transparent,
      foregroundColor: Style.transparent,
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    fontFamily: GoogleFonts.poppins().fontFamily,
    tabBarTheme: TabBarThemeData(dividerColor: Style.transparent),
    colorScheme: const ColorScheme(
      primary: Style.pink,
      secondary: Style.yellow,
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.redAccent,
      brightness: Brightness.light,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Style.circularBorderRadius),
        side: const BorderSide(width: 1),
      ),
      checkColor: WidgetStateProperty.all(Colors.white),
      fillColor: WidgetStateProperty.all(Style.pink),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        // TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Style.darkScaffoldColor,
    iconTheme: const IconThemeData(color: Colors.white),
    fontFamily: GoogleFonts.poppins().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: Style.transparent,
      foregroundColor: Style.transparent,
    ),
    tabBarTheme: TabBarThemeData(dividerColor: Style.transparent),
    colorScheme: const ColorScheme(
      primary: Style.pink,
      secondary: Style.yellow,
      surface: Colors.black,
      error: Colors.red,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.redAccent,
      brightness: Brightness.dark,
    ),
    dividerColor: Colors.white24,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
