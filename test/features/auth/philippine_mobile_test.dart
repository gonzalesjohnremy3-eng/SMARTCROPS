import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/auth/domain/philippine_mobile.dart';

void main() {
  group('normalizePhilippineMobile', () {
    test('accepts the local 09 form', () {
      expect(normalizePhilippineMobile('09171234567'), '+639171234567');
    });

    test('accepts the number without the leading zero', () {
      expect(normalizePhilippineMobile('9171234567'), '+639171234567');
    });

    test('accepts the 63 country-code form', () {
      expect(normalizePhilippineMobile('639171234567'), '+639171234567');
    });

    test('accepts the +63 international form', () {
      expect(normalizePhilippineMobile('+639171234567'), '+639171234567');
    });

    test('ignores spaces and dashes the Farmer types', () {
      expect(normalizePhilippineMobile('0917 123-4567'), '+639171234567');
    });

    test('rejects a number that is too short', () {
      expect(normalizePhilippineMobile('0917123456'), isNull);
    });

    test('rejects a landline that does not start with 9', () {
      expect(normalizePhilippineMobile('0281234567'), isNull);
    });

    test('rejects letters', () {
      expect(normalizePhilippineMobile('0917abc4567'), isNull);
    });
  });

  group('maskPhilippineMobile', () {
    test('shows the prefix and last four digits in local form', () {
      expect(maskPhilippineMobile('+639171234567'), '0917 ••• 4567');
    });
  });

  group('PhilippineMobileInputFormatter', () {
    TextEditingValue format(String text) => PhilippineMobileInputFormatter()
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));

    test('groups a local number as 4-3-4', () {
      expect(format('09171234567').text, '0917 123 4567');
    });

    test('keeps the caret at the end of the grouped number', () {
      expect(format('0917123').selection.baseOffset, '0917 123'.length);
    });

    test('drops anything that is not a digit', () {
      expect(format('09a17').text, '0917');
    });

    test('turns a pasted +63 number into the local form', () {
      expect(format('+639171234567').text, '0917 123 4567');
    });

    test('stops at eleven digits', () {
      expect(format('091712345678').text, '0917 123 4567');
    });
  });
}
