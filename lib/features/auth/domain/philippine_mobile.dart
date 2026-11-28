import 'package:flutter/services.dart';

final _mobileDigits = RegExp(r'^(?:\+?63|0)?(9\d{9})$');

/// Returns the E.164 form (`+639XXXXXXXXX`) of a Philippine mobile number
/// typed as `09…`, `9…`, `63…` or `+63…`, or null when it is not one.
String? normalizePhilippineMobile(String input) {
  final compact = input.replaceAll(RegExp(r'[\s-]'), '');
  final match = _mobileDigits.firstMatch(compact);
  return match == null ? null : '+63${match.group(1)}';
}

/// `+639171234567` → `0917 ••• 4567`, for "code sent to" lines.
String maskPhilippineMobile(String e164) {
  final local = '0${e164.substring(3)}';
  return '${local.substring(0, 4)} ••• ${local.substring(7)}';
}

/// Groups a local mobile number as `0917 123 4567` while the Farmer types.
class PhilippineMobileInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = raw.startsWith('63') ? '0${raw.substring(2)}' : raw;
    final capped = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i == 4 || i == 7) buffer.write(' ');
      buffer.write(capped[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
