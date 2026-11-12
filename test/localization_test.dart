import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/services/localization_service.dart';

void main() {
  group('Localization Service TDD - Seam: Multi-language Dictionary', () {
    test('defaults to English and translates correctly', () {
      final l10n = LocalizationService();
      expect(l10n.currentLocale, 'en');
      expect(l10n.translate('scan_crop'), 'Scan Crop');
    });

    test('switches to Tagalog and translates correctly', () {
      final l10n = LocalizationService();
      l10n.setLocale('tl');
      expect(l10n.currentLocale, 'tl');
      expect(l10n.translate('scan_crop'), 'I-scan ang Pananim');
      expect(l10n.translate('welcome'), 'Maligayang pagbabalik');
    });

    test('switches to Cebuano and translates correctly', () {
      final l10n = LocalizationService();
      l10n.setLocale('ceb');
      expect(l10n.currentLocale, 'ceb');
      expect(l10n.translate('scan_crop'), 'I-scan ang Tanum');
      expect(l10n.translate('calendar'), 'Kalendaryo sa Tanum');
    });

    test('falls back to English when key is missing', () {
      final l10n = LocalizationService();
      l10n.setLocale('tl');
      expect(l10n.translate('unknown_key'), 'unknown_key');
    });
  });
}
