import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'language_preference.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider({required this.preference}) {
    _load();
  }

  final LanguagePreference preference;
  String _currentLocale = 'en';

  String get currentLocale => _currentLocale;

  Future<void> _load() async {
    _currentLocale = await preference.load();
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    await preference.save(languageCode);
    _currentLocale = languageCode;
    notifyListeners();
  }
}
