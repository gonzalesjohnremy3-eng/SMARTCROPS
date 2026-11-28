import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/theme/app_theme.dart';
import 'package:smart_crops/features/auth/widgets/otp_code_field.dart';

Future<List<String>> _pump(WidgetTester tester, {String? errorText}) async {
  final completed = <String>[];
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: OtpCodeField(
          onCompleted: completed.add,
          errorText: errorText,
          semanticLabel: 'Verification code',
        ),
      ),
    ),
  );
  return completed;
}

void main() {
  testWidgets('shows six empty digit boxes', (tester) async {
    await _pump(tester);

    expect(find.byKey(const Key('otp-digit-box')), findsNWidgets(6));
  });

  testWidgets('places each typed digit in its own box', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), '482');
    await tester.pump();

    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('submits once the sixth digit arrives', (tester) async {
    final completed = await _pump(tester);

    await tester.enterText(find.byType(TextField), '482913');
    await tester.pump();

    expect(completed, ['482913']);
  });

  testWidgets('submits a full code only once', (tester) async {
    final completed = await _pump(tester);

    await tester.enterText(find.byType(TextField), '482913');
    await tester.pump();
    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(completed, ['482913']);
  });

  testWidgets('does not submit an incomplete code', (tester) async {
    final completed = await _pump(tester);

    await tester.enterText(find.byType(TextField), '48291');
    await tester.pump();

    expect(completed, isEmpty);
  });

  testWidgets('a pasted code with spaces still fills all six', (tester) async {
    final completed = await _pump(tester);

    await tester.enterText(find.byType(TextField), '482 913');
    await tester.pump();

    expect(completed, ['482913']);
  });

  testWidgets('offers the one-time-code autofill hint', (tester) async {
    await _pump(tester);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.autofillHints, contains(AutofillHints.oneTimeCode));
  });

  testWidgets('shows the error beneath the boxes', (tester) async {
    await _pump(tester, errorText: 'That code is wrong or has expired.');

    expect(find.text('That code is wrong or has expired.'), findsOneWidget);
  });
}
