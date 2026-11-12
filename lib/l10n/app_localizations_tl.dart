// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tagalog (`tl`).
class AppLocalizationsTl extends AppLocalizations {
  AppLocalizationsTl([String locale = 'tl']) : super(locale);

  @override
  String get appTitle => 'Smart Crops ng Agri Lynk';

  @override
  String get scanCrop => 'I-scan ang pananim';

  @override
  String get fieldCalendar => 'Kalendaryo ng Bukid';

  @override
  String get scanQueuedOffline =>
      'Nai-save. Susuriin namin ito kapag may koneksyon ka na.';

  @override
  String cropsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pananim ang napili',
      one: '$count pananim ang napili',
      zero: 'Wala pang napiling pananim',
    );
    return '$_temp0';
  }
}
