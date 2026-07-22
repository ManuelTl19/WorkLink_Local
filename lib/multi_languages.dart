import 'dart:convert';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/logger.dart';

class MultiLanguages {
  final Locale locale;
  MultiLanguages({this.locale = const Locale.fromSubtags(languageCode: 'es')});

  static MultiLanguages? of(BuildContext context) {
    return Localizations.of<MultiLanguages>(context, MultiLanguages);
  }

  void keepLocaleKey(String key) {
    try {
      prefs.setString('locale', key);
    } catch (e) {
      logImportant('Could not save locale key: $e');
    }
  }

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

  void setLocaleKey(BuildContext context, Locale locale) {
    keepLocaleKey(locale.languageCode);
    logSuccess('Setting Locale Key: ${locale.languageCode}');
    try {
      LocaleManager.notifyLocaleChanged(locale);
    } catch (e) {
      logImportant('LocaleManager notify failed: $e');
    }
  }

  static const LocalizationsDelegate<MultiLanguages> delegate =
      _MultiLanguagesDelegate();

  Map<String, String> localizedStrings = {};

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

  String translate(String key) {
    return localizedStrings[key] ?? key;
  }

  selectLanguageBottomSheet(BuildContext context) {
    final currentLocale = Localizations.localeOf(context).languageCode;

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
        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MultiLanguages.of(context)?.translate('select_language') ??
                    'Seleccionar idioma',
                style: Style.getHeaderTwo(
                  color: Style.getPrimaryColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20.h),
              _languageOption(
                context: context,
                flag: '🇪🇸',
                name: 'Español',
                code: 'es',
                isSelected: currentLocale == 'es',
                onTap: () {
                  setLocaleKey(
                    context,
                    const Locale.fromSubtags(languageCode: 'es'),
                  );
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 12.h),
              _languageOption(
                context: context,
                flag: '🇬🇧',
                name: 'English',
                code: 'en',
                isSelected: currentLocale == 'en',
                onTap: () {
                  setLocaleKey(
                    context,
                    const Locale.fromSubtags(languageCode: 'en'),
                  );
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption({
    required BuildContext context,
    required String flag,
    required String name,
    required String code,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(
          color: isSelected ? Style.getPrimaryColor() : Style.getBorderColor(),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? Style.getPrimaryColor().withValues(alpha: 0.08)
            : Style.getCardColor(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Style.getHeaderThree(
                          color: Style.getTextColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        code.toUpperCase(),
                        style: Style.getTextStyle(
                          color: Style.getObscureTextColor(),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: Style.getPrimaryColor(),
                    size: 24.w,
                  )
                else
                  Icon(
                    Icons.circle_outlined,
                    color: Style.getObscureTextColor(),
                    size: 24.w,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MultiLanguagesDelegate extends LocalizationsDelegate<MultiLanguages> {
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
