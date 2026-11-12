import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LanguageStore {
  Future<String?> load();

  Future<void> save(String languageCode);
}

class SharedPreferencesLanguageStore implements LanguageStore {
  static const _key = 'language_code';

  @override
  Future<String?> load() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_key);
  }

  @override
  Future<void> save(String languageCode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, languageCode);
  }
}

class LanguagePreference {
  LanguagePreference({
    required this.store,
    Locale Function()? deviceLocale,
  }) : deviceLocale =
           deviceLocale ?? (() => ui.PlatformDispatcher.instance.locale);

  static const supportedLanguageCodes = {'en', 'tl', 'ceb'};

  final LanguageStore store;
  final Locale Function() deviceLocale;

  Future<String> load() async {
    final stored = await store.load();
    if (_isSupported(stored)) return stored!;

    final device = deviceLocale().languageCode;
    if (_isSupported(device)) return device;

    return 'en';
  }

  Future<void> save(String languageCode) async {
    if (!_isSupported(languageCode)) return;
    await store.save(languageCode);
  }

  bool _isSupported(String? languageCode) {
    return languageCode != null &&
        supportedLanguageCodes.contains(languageCode);
  }
}
