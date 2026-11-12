// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Crops by Agri Lynk';

  @override
  String get scanCrop => 'Scan crop';

  @override
  String get fieldCalendar => 'Field Calendar';

  @override
  String get scanQueuedOffline =>
      'Saved. We\'ll analyze this when you\'re back online.';

  @override
  String cropsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crops selected',
      one: '1 crop selected',
      zero: 'No crops selected',
    );
    return '$_temp0';
  }
}
