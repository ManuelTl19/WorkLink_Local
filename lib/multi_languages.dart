import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/logger.dart';

class MultiLanguages {
  final Locale locale;
  MultiLanguages({this.locale = const Locale.fromSubtags(languageCode: 'es')});

  /// Helper method to keep the code in the widgets concise
  /// Localizations are accessed using an InheritedWidget "of" syntax

  static MultiLanguages? of(BuildContext context) {
    return Localizations.of<MultiLanguages>(context, MultiLanguages);
  }

  /// Store the locale in the SharedPreferences (safe)
  void keepLocaleKey(String key) {
    try {
      prefs.setString('locale', key);
    } catch (e) {
      logImportant('Could not save locale key: $e');
    }
  }

  /// Get the locale from the SharedPreferences (safe)
  Future<String> getLocaleKey() async {
    try {
      final current = prefs.getString('locale');
      logImportant('Locale Key: $current');
      return current ?? 'es';
    } catch (e) {
      logImportant('Could not read locale key: $e');
      return 'es';
    }
  }

  /// Set the locale in the MaterialApp (decoupled)
  void setLocaleKey(BuildContext context, Locale locale) {
    keepLocaleKey(locale.languageCode);
    logSuccess('Setting Locale Key: ${locale.languageCode}');
    // Notify registered listener to update the app locale (avoids tight coupling)
    try {
      LocaleManager.notifyLocaleChanged(locale);
    } catch (e) {
      logImportant('LocaleManager notify failed: $e');
    }
  }

  static const LocalizationsDelegate<MultiLanguages> delegate =
      _MultiLanguagesDelegate();

  /// Map to store localized strings
  Map<String, String> localizedStrings = {};

  /// Load the language JSON file from the "language" folder
  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/language/${locale.languageCode}.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      localizedStrings = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      return true;
    } catch (e) {
      logImportant('Localization load failed for ${locale.languageCode}: $e');
      localizedStrings = {};
      return false;
    }
  }

  /// This method will be called from every widget which needs a localized text
  String translate(String key) {
    return localizedStrings[key] ?? key;
  }

  selectLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet<dynamic>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Style.circularBorderRadius),
        ),
      ),
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Style.getBackgroundColor(),
      builder: (context) {
        return Wrap(
          children: [
            SizedBox(
              height: 200.h,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      MultiLanguages.of(
                            context,
                          )?.translate('select_language') ??
                          'Seleccionar idioma',
                      style: Style.getHeaderTwo(
                        color: Style.getPrimaryColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  ListTile(
                    title: Text('Español', style: Style.getTextStyle()),
                    trailing: FaIcon(
                      FontAwesomeIcons.chevronRight,
                      color: Style.getTextColor(),
                      size: Style.bigIconSize,
                    ),
                    onTap: () {
                      setLocaleKey(
                        context,
                        const Locale.fromSubtags(languageCode: 'es'),
                      );
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('English', style: Style.getTextStyle()),
                    trailing: FaIcon(
                      FontAwesomeIcons.chevronRight,
                      color: Style.getTextColor(),
                      size: Style.bigIconSize,
                    ),
                    onTap: () {
                      setLocaleKey(
                        context,
                        const Locale.fromSubtags(languageCode: 'en'),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MultiLanguagesDelegate extends LocalizationsDelegate<MultiLanguages> {
  // This delegate instance will never change
  // It can provide a constant constructor.
  const _MultiLanguagesDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en'].contains(locale.languageCode);
  }

  @override
  Future<MultiLanguages> load(Locale locale) async {
    MultiLanguages localizations = MultiLanguages(locale: locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_MultiLanguagesDelegate old) => false;
}
