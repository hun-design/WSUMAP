import 'package:flutter/material.dart';

class AppLanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ko');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }
}
