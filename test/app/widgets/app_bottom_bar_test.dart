import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/app/theme/app_theme.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/app_bottom_bar.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

Future<List<int>> _pump(
  WidgetTester tester, {
  int current = 0,
  String locale = 'en',
  double textScale = 1,
  Size size = const Size(390, 800),
  double bottomInset = 0,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final taps = <int>[];

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: Locale(locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        CebMaterialLocalizationsDelegate(),
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        CebCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          viewPadding: EdgeInsets.only(bottom: bottomInset),
          padding: EdgeInsets.only(bottom: bottomInset),
        ),
        child: child!,
      ),
      home: Scaffold(
        bottomNavigationBar: AppBottomBar(
          currentIndex: current,
          onSelected: taps.add,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return taps;
}

Color? _indicatorColor(WidgetTester tester, int index) {
  final box = tester.widget<AnimatedContainer>(
    find.byKey(Key('nav_indicator_$index')),
  );
  return (box.decoration as BoxDecoration?)?.color;
}

void main() {
  testWidgets('shows all five destinations with their names', (tester) async {
    await _pump(tester);

    for (final label in ['Home', 'Crops', 'Scan', 'Calendar', 'Profile']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('tapping a destination reports its position', (tester) async {
    final taps = await _pump(tester);
    await tester.tap(find.text('Calendar'));

    expect(taps, [3]);
  });

  testWidgets('the current destination is announced as selected', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, current: 1);

    expect(
      tester.getSemantics(find.byKey(const Key('nav_item_1'))),
      containsSemantics(isSelected: true, isButton: true, label: 'Crops'),
    );
    handle.dispose();
  });

  testWidgets('another destination is not announced as selected', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, current: 1);

    expect(
      tester.getSemantics(find.byKey(const Key('nav_item_0'))),
      containsSemantics(isSelected: false, isButton: true),
    );
    handle.dispose();
  });

  testWidgets('an unselected destination has no highlight', (tester) async {
    await _pump(tester, current: 1);

    expect(_indicatorColor(tester, 0), Colors.transparent);
  });

  testWidgets('the selected destination is highlighted', (tester) async {
    await _pump(tester, current: 1);

    expect(_indicatorColor(tester, 1), AppColors.mist);
  });

  testWidgets('Scan stays the primary action even when not selected', (
    tester,
  ) async {
    await _pump(tester, current: 0);

    final button = tester.widget<Container>(
      find.byKey(const Key('nav_indicator_2')),
    );

    expect((button.decoration as BoxDecoration).color, AppColors.actionPrimary);
  });

  testWidgets('Scan rises above the top edge of the bar', (tester) async {
    await _pump(tester);

    final scanTop = tester.getTopLeft(find.byKey(const Key('nav_indicator_2')));
    final barTop = tester.getTopLeft(find.byKey(const Key('bottom_nav_bar')));

    expect(scanTop.dy, lessThan(barTop.dy));
  });

  testWidgets('the bar stays short instead of filling the screen', (
    tester,
  ) async {
    await _pump(tester);

    expect(tester.getSize(find.byType(AppBottomBar)).height, lessThan(140));
  });

  testWidgets('Scan sits in the middle of the bar', (tester) async {
    await _pump(tester);

    expect(tester.getCenter(find.byKey(const Key('nav_indicator_2'))).dx, 195);
  });

  testWidgets('Scan is a large round button', (tester) async {
    await _pump(tester);

    expect(tester.getSize(find.byKey(const Key('nav_indicator_2'))).width, 64);
  });

  testWidgets('tapping the part of Scan above the bar still opens it', (
    tester,
  ) async {
    final taps = await _pump(tester);
    final barTop = tester.getTopLeft(find.byKey(const Key('bottom_nav_bar')));
    await tester.tapAt(Offset(195, barTop.dy - 12));

    expect(taps, [2]);
  });

  testWidgets('tapping the Scan label opens it too', (tester) async {
    final taps = await _pump(tester);
    await tester.tap(find.text('Scan'));

    expect(taps, [2]);
  });

  testWidgets('labels follow the app language', (tester) async {
    await _pump(tester, locale: 'tl');

    expect(find.text('Kalendaryo'), findsOneWidget);
  });

  testWidgets('floats above the phone\'s bottom gesture area', (tester) async {
    await _pump(tester, bottomInset: 34);

    final bottom = tester
        .getBottomLeft(find.byKey(const Key('bottom_nav_bar')))
        .dy;

    expect(bottom, lessThanOrEqualTo(800 - 34));
  });

  testWidgets('keeps the Scan key the app already uses', (tester) async {
    await _pump(tester);

    expect(find.byKey(const Key('nav_scan')), findsOneWidget);
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    testWidgets('fits a narrow phone at 200% text in $locale', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await _pump(
          tester,
          locale: locale,
          textScale: 2,
          size: const Size(320, 640),
        );
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }

  testWidgets('meets tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
