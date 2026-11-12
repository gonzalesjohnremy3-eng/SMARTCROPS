import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

void main() {
  test('English, Tagalog, and Cebuano resolve their approved strings', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final tl = await AppLocalizations.delegate.load(const Locale('tl'));
    final ceb = await AppLocalizations.delegate.load(const Locale('ceb'));

    expect(en.scanCrop, 'Scan crop');
    expect(tl.scanCrop, 'I-scan ang pananim');
    expect(ceb.scanCrop, 'I-scan ang tanom');

    expect(en.fieldCalendar, 'Field Calendar');
    expect(tl.fieldCalendar, 'Kalendaryo ng Bukid');
    expect(ceb.fieldCalendar, 'Kalendaryo sa Uma');
  });

  test('unsupported locales are rejected by the delegate', () {
    expect(AppLocalizations.delegate.isSupported(const Locale('fr')), isFalse);
  });

  test('plural messages preserve the count in every language', () async {
    for (final locale in const ['en', 'tl', 'ceb']) {
      final l10n = await AppLocalizations.delegate.load(Locale(locale));
      expect(
        l10n.cropsSelectedCount(5),
        contains('5'),
        reason: 'Plural count was lost for $locale',
      );
    }
  });
}
