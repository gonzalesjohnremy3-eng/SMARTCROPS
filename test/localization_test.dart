import 'package:flutter_test/flutter_test.dart';

class LocalizationManager {
  String _currentLocale = 'en';

  String get currentLocale => _currentLocale;

  void setLocale(String locale) {
    if (['en', 'tl', 'ceb'].contains(locale)) {
      _currentLocale = locale;
    }
  }

  String translate(String key) {
    final translations = {
      'en': {
        'app_title': 'Smart Crops',
        'welcome': 'Welcome back',
        'scan_crop': 'Scan Crop',
        'my_crops': 'My Crops',
        'recommendations': 'Recommendations',
        'history': 'History',
        'calendar': 'Crop Calendar',
      },
      'tl': {
        'app_title': 'Smart Crops',
        'welcome': 'Maligayang pagbabalik',
        'scan_crop': 'I-scan ang Pananim',
        'my_crops': 'Aking mga Pananim',
        'recommendations': 'Mga Rekomendasyon',
        'history': 'Kasaysayan',
        'calendar': 'Kalendaryo ng Pananim',
      },
      'ceb': {
        'app_title': 'Smart Crops',
        'welcome': 'Malipayong pagbalik',
        'scan_crop': 'I-scan ang Tanum',
        'my_crops': 'Akong mga Tanum',
        'recommendations': 'Mga Rekomendasyon',
        'history': 'Kasaysayan',
        'calendar': 'Kalendaryo sa Tanum',
      },
    };

    return translations[_currentLocale]?[key] ?? translations['en']?[key] ?? key;
  }
}

void main() {
  group('Localization Manager TDD - Seam: Multi-language Dictionary', () {
    test('defaults to English and translates correctly', () {
      final l10n = LocalizationManager();
      expect(l10n.currentLocale, 'en');
      expect(l10n.translate('scan_crop'), 'Scan Crop');
    });

    test('switches to Tagalog and translates correctly', () {
      final l10n = LocalizationManager();
      l10n.setLocale('tl');
      expect(l10n.currentLocale, 'tl');
      expect(l10n.translate('scan_crop'), 'I-scan ang Pananim');
      expect(l10n.translate('welcome'), 'Maligayang pagbabalik');
    });

    test('switches to Cebuano and translates correctly', () {
      final l10n = LocalizationManager();
      l10n.setLocale('ceb');
      expect(l10n.currentLocale, 'ceb');
      expect(l10n.translate('scan_crop'), 'I-scan ang Tanum');
      expect(l10n.translate('calendar'), 'Kalendaryo sa Tanum');
    });

    test('falls back to English when key is missing', () {
      final l10n = LocalizationManager();
      l10n.setLocale('tl');
      expect(l10n.translate('unknown_key'), 'unknown_key');
    });
  });
}
