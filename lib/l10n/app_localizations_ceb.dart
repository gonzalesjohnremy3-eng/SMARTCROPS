// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Cebuano (`ceb`).
class AppLocalizationsCeb extends AppLocalizations {
  AppLocalizationsCeb([String locale = 'ceb']) : super(locale);

  @override
  String get appTitle => 'Smart Crops sa Agri Lynk';

  @override
  String get scanCrop => 'I-scan ang tanom';

  @override
  String get fieldCalendar => 'Kalendaryo sa Uma';

  @override
  String get scanQueuedOffline =>
      'Na-save. Susihon namo kini kung naa na kay koneksyon.';

  @override
  String cropsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tanom ang napili',
      one: '$count tanom ang napili',
      zero: 'Wala pay napiling tanom',
    );
    return '$_temp0';
  }
}
