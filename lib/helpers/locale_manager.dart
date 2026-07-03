import 'package:flutter/material.dart';

typedef LocaleCallback = void Function(Locale locale);

class LocaleManager {
  static LocaleCallback? _onLocaleChanged;

  static void setLocaleCallback(LocaleCallback callback) {
    _onLocaleChanged = callback;
  }

  static void clearLocaleCallback() {
    _onLocaleChanged = null;
  }

  static void notifyLocaleChanged(Locale locale) {
    _onLocaleChanged?.call(locale);
  }
}
