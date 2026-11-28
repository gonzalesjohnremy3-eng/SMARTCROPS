import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/localization/ceb_fallback_localizations.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/features/scan/screens/scan_result_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

const _lowConfidence = DiagnosisInput(
  diseaseDetected: 'Fungal leaf blight',
  confidenceScore: 52,
  commonCrop: 'Tomato',
  recommendedActions: ['Remove affected leaves', 'Improve airflow'],
);

const _confident = DiagnosisInput(
  diseaseDetected: 'Early blight',
  confidenceScore: 92,
  commonCrop: 'Tomato',
  recommendedActions: ['Remove affected leaves', 'Apply copper fungicide'],
);

Widget _buildResult(
  DiagnosisInput input, {
  String locale = 'en',
  double textScale = 1,
}) {
  return MaterialApp(
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
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: ScanResultScreen(input: input),
  );
}

Future<void> _pump(WidgetTester tester, DiagnosisInput input) async {
  await tester.binding.setSurfaceSize(const Size(390, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_buildResult(input));
  await tester.pumpAndSettle();
}

void main() {
  group('low confidence', () {
    testWidgets('makes retake the primary action', (tester) async {
      await _pump(tester, _lowConfidence);

      expect(find.text('Retake in better light'), findsOneWidget);
    });

    testWidgets('explains why the answer is uncertain', (tester) async {
      await _pump(tester, _lowConfidence);

      expect(find.text('Not sure about this one'), findsOneWidget);
    });

    testWidgets('does not offer to schedule an uncertain treatment', (
      tester,
    ) async {
      await _pump(tester, _lowConfidence);

      expect(find.text('Add to Field Calendar'), findsNothing);
    });
  });

  testWidgets('demo input renders the labelled demo banner and details', (
    tester,
  ) async {
    await _pump(
      tester,
      const DiagnosisInput(
        diseaseDetected: 'Early blight',
        confidenceScore: 81,
        commonCrop: 'Tomato',
        recommendedActions: ['Remove affected leaves', 'Improve airflow'],
        isDemo: true,
      ),
    );

    expect(find.text('Demo diagnosis'), findsOneWidget);
    expect(find.text('Why it happens'), findsOneWidget);
    expect(find.text('What you will see'), findsOneWidget);
    expect(find.text('How to prevent it'), findsOneWidget);
    expect(find.text('When to call an expert'), findsOneWidget);
  });

  testWidgets('real input does not render the demo banner', (tester) async {
    await _pump(tester, _confident);

    expect(find.text('Demo diagnosis'), findsNothing);
  });

  group('confident diagnosis', () {
    testWidgets('leads with what to do now', (tester) async {
      await _pump(tester, _confident);

      expect(find.text('What to do now'), findsOneWidget);
    });

    testWidgets('lists the treatment steps', (tester) async {
      await _pump(tester, _confident);

      expect(find.text('Apply copper fungicide'), findsOneWidget);
    });

    testWidgets('offers to add the work to the Field Calendar', (tester) async {
      await _pump(tester, _confident);

      expect(find.text('Add to Field Calendar'), findsOneWidget);
    });

    testWidgets('states confidence once', (tester) async {
      await _pump(tester, _confident);

      expect(find.textContaining('92%'), findsOneWidget);
    });

    testWidgets('offers to scan another crop', (tester) async {
      await _pump(tester, _confident);

      expect(find.text('Scan another crop'), findsOneWidget);
    });

    testWidgets('has no reminder button that does nothing', (tester) async {
      await _pump(tester, _confident);

      expect(find.text('Set Reminder'), findsNothing);
    });

    testWidgets('does not show the offline queue message', (tester) async {
      await _pump(tester, _confident);

      expect(
        find.text("Saved. We'll analyze this when you're back online."),
        findsNothing,
      );
    });
  });

  testWidgets('healthy crop shows the healthy severity', (tester) async {
    await _pump(
      tester,
      const DiagnosisInput(
        diseaseDetected: 'Healthy / no disease detected',
        confidenceScore: 96,
        commonCrop: 'Pechay',
        recommendedActions: ['Keep monitoring'],
      ),
    );

    expect(find.text('Healthy'), findsOneWidget);
  });

  for (final locale in ['en', 'tl', 'ceb']) {
    testWidgets('fits a phone at 200% text in $locale', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await tester.pumpWidget(
          _buildResult(_confident, locale: locale, textScale: 2),
        );
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = original;
      }

      expect(errors, isEmpty);
    });
  }
}
