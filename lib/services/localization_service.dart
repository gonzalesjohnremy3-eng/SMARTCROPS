import 'package:flutter/foundation.dart';

class LocalizationService with ChangeNotifier {
  String _currentLocale = 'en'; // 'en', 'tl', 'ceb'

  String get currentLocale => _currentLocale;

  void setLocale(String locale) {
    if (['en', 'tl', 'ceb'].contains(locale)) {
      _currentLocale = locale;
      notifyListeners();
      debugPrint('LocalizationService: Switched language to $_currentLocale');
    }
  }

  String translate(String key) {
    final translations = {
      'en': {
        'app_title': 'Smart Crops (Agri Lynk)',
        'welcome': 'Welcome back',
        'scan_crop': 'Scan Crop',
        'my_crops': 'My Crops',
        'recommendations': 'Recommendations',
        'history': 'History',
        'calendar': 'Crop Calendar',
        'weather': 'Local Farm Weather',
        'profile': 'Farmer Profile',
        'sign_out': 'Sign Out',
      },
      'tl': {
        'app_title': 'Smart Crops (Agri Lynk)',
        'welcome': 'Maligayang pagbabalik',
        'scan_crop': 'I-scan ang Pananim',
        'my_crops': 'Aking mga Pananim',
        'recommendations': 'Mga Rekomendasyon',
        'history': 'Kasaysayan',
        'calendar': 'Kalendaryo ng Pananim',
        'weather': 'Panahon sa Bukid',
        'profile': 'Propyl ng Magsasaka',
        'sign_out': 'Mag-sign Out',
      },
      'ceb': {
        'app_title': 'Smart Crops (Agri Lynk)',
        'welcome': 'Malipayong pagbalik',
        'scan_crop': 'I-scan ang Tanum',
        'my_crops': 'Akong mga Tanum',
        'recommendations': 'Mga Rekomendasyon',
        'history': 'Kasaysayan',
        'calendar': 'Kalendaryo sa Tanum',
        'weather': 'Panahon sa Uma',
        'profile': 'Profil sa Mag-uuma',
        'sign_out': 'Pag-sign Out',
      },
    };

    return translations[_currentLocale]?[key] ?? translations['en']?[key] ?? key;
  }
}
