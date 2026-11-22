import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/widgets/glass_surface.dart';

void main() {
  testWidgets('blur:false renders no BackdropFilter and keeps the child',
      (tester) async {
    await tester.pumpWidget(const MediaQuery(
      data: MediaQueryData(size: Size(390, 844)),
      child: MaterialApp(
        home: GlassSurface(blur: false, child: Text('Care Plan')),
      ),
    ));

    expect(find.byWidgetPredicate((w) => w is BackdropFilter), findsNothing);
    expect(find.text('Care Plan'), findsOneWidget);
  });

  testWidgets('blur:true renders exactly one BackdropFilter', (tester) async {
    await tester.pumpWidget(const MediaQuery(
      data: MediaQueryData(size: Size(390, 844)),
      child: MaterialApp(
        home: GlassSurface(child: Text('Field Briefing')),
      ),
    ));

    expect(find.byWidgetPredicate((w) => w is BackdropFilter), findsOneWidget);
    expect(find.text('Field Briefing'), findsOneWidget);
  });

  testWidgets('glass surface keeps its child visible', (tester) async {
    await tester.pumpWidget(const MediaQuery(
      data: MediaQueryData(size: Size(390, 844)),
      child: MaterialApp(
        home: GlassSurface(blur: false, child: Text('Advisories')),
      ),
    ));

    expect(find.text('Advisories'), findsOneWidget);
  });
}
