import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/app_theme.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:worklink_local/modules/app/screens/starter/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<PageRoute<dynamic>> routeObserver =
  RouteObserver<PageRoute<dynamic>>();

// Referencia al estado actual del DashboardScreen para acceder al drawer
dynamic currentDashboardState;

void showDrawer() {
  // Llama openDrawer() dinámicamente para evitar importación circular
  currentDashboardState?.openDrawer();
}

// Primera version de worklink
// 1.0.0 - 2024-06-01

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // Metodo para cambiar el idioma desde cualquier parte de la app
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale.fromSubtags(languageCode: 'es');

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void getLocale() async {
    final multiLanguages = MultiLanguages();
    var localeKey = await multiLanguages.getLocaleKey();
    Locale newLocale;
    if (localeKey == 'es') {
      newLocale = const Locale.fromSubtags(languageCode: 'es');
    } else {
      newLocale = const Locale.fromSubtags(languageCode: 'en');
    }
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  void initState() {
    super.initState();
    getLocale();
    LocaleManager.setLocaleCallback((locale) {
      changeLocale(locale);
    });
    setDeviceOrientation(1);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Resize(
      builder: () {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AppSettings>(create: (_) => AppSettings()),
          ],
          child: MaterialApp(
            supportedLocales: const [
              Locale.fromSubtags(languageCode: 'es'),
              Locale.fromSubtags(languageCode: 'en'),
            ],
            localizationsDelegates: const [
              MultiLanguages.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocaleLanguage in supportedLocales) {
                if (supportedLocaleLanguage.languageCode ==
                        locale?.languageCode &&
                    supportedLocaleLanguage.countryCode ==
                        locale?.countryCode) {
                  return supportedLocaleLanguage;
                }
              }
              return supportedLocales.first;
            },
            locale: _locale,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: AppSettings.isDarkModeOn
                ? ThemeMode.dark
                : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            title: 'WorkLink Local',
            navigatorKey: navigatorKey,
            navigatorObservers: [routeObserver],
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.1)),
              child: child!,
            ),
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
