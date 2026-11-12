import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/localization/language_preference.dart';

class MemoryLanguageStore implements LanguageStore {
  String? value;

  @override
  Future<String?> load() async => value;

  @override
  Future<void> save(String languageCode) async {
    value = languageCode;
  }
}

void main() {
  test('a supported device language is used when nothing is stored', () async {
    final preference = LanguagePreference(
      store: MemoryLanguageStore(),
      deviceLocale: () => const Locale('tl'),
    );

    expect(await preference.load(), 'tl');
  });

  test('the selected language is persisted', () async {
    final store = MemoryLanguageStore();
    final preference = LanguagePreference(
      store: store,
      deviceLocale: () => const Locale('en'),
    );

    await preference.save('tl');

    expect(store.value, 'tl');
    expect(await preference.load(), 'tl');
  });

  test('an unsupported stored language falls back to English', () async {
    final store = MemoryLanguageStore()..value = 'fr';
    final preference = LanguagePreference(
      store: store,
      deviceLocale: () => const Locale('en'),
    );

    expect(await preference.load(), 'en');
  });

  test('a supported device language is used before the English fallback', () async {
    final preference = LanguagePreference(
      store: MemoryLanguageStore(),
      deviceLocale: () => const Locale('ceb'),
    );

    expect(await preference.load(), 'ceb');
  });

  test('an unsupported device language falls back to English', () async {
    final preference = LanguagePreference(
      store: MemoryLanguageStore(),
      deviceLocale: () => const Locale('ja'),
    );

    expect(await preference.load(), 'en');
  });
}
