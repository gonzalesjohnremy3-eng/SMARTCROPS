import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/widgets/scrimmed_image.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';

void main() {
  testWidgets('ScrimmedImage renders image and scrim with child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScrimmedImage(
            imagePath: 'assets/images/overlays/home.webp',
            child: const Text('Hello'),
          ),
        ),
      ),
    );

    // Image widget should be present (via DecorationImage)
    // The scrim DecoratedBox with color should be present
    final scrimBoxes = tester.widgetList<DecoratedBox>(
      find.byWidgetPredicate((w) => w is DecoratedBox && w.decoration is BoxDecoration && (w.decoration as BoxDecoration).color == AppGlass.imageScrim),
    );
    expect(scrimBoxes, isNotEmpty);

    // Child text should be visible
    expect(find.text('Hello'), findsOneWidget);
  });
}