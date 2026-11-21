import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smart_crops/features/scan/screens/scan_review_screen.dart';

void main() {
  group('scan image object naming', () {
    test('uses the real image extension', () {
      expect(scanImageExtension(XFile('leaf.PNG')), 'png');
    });

    test('falls back to jpg for blob URLs with no extension', () {
      expect(scanImageExtension(XFile('blob:http://localhost:1234/abc')), 'jpg');
    });
  });
}
