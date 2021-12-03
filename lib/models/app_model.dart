import '/common/global.dart';
import 'package:flutter/material.dart';

class AppModel extends ChangeNotifier {
  final Global _global = Global();

  Locale get locale => _global.locale;

  void changeLocale(String languageCode) {
    _global.changeLanguage(languageCode).then((value) => notifyListeners());
  }

  bool isCurrentLocale(String languageCode) {
    return (_global.locale.languageCode == languageCode);
  }
}
