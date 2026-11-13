import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/features/scan/screens/scan_result_screen.dart';
import 'package:smart_crops/l10n/app_localizations.dart';

void main() {
  Widget buildResult(DiagnosisInput input) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tl'), Locale('ceb')],
      home: ScanResultScreen(input: input),
    );
  }

  testWidgets('low-confidence diagnosis makes retake the primary action', (tester) async {
    await tester.pumpWidget(buildResult(const DiagnosisInput(
      diseaseDetected: 'Fungal leaf blight',
      confidenceScore: 52,
      commonCrop: 'Tomato',
      recommendedActions: ['Remove affected leaves', 'Improve airflow'],
    )));
    await tester.pumpAndSettle();

    expect(find.text('Retake in better light'), findsOneWidget);
    expect(find.text('Partner offer'), findsNothing);
    expect(find.text('Treatment Steps'), findsOneWidget);
  });

  testWidgets('high-confidence diagnosis shows the treatment plan', (tester) async {
    await tester.pumpWidget(buildResult(const DiagnosisInput(
      diseaseDetected: 'Early blight',
      confidenceScore: 92,
      commonCrop: 'Tomato',
      recommendedActions: ['Remove affected leaves', 'Apply copper fungicide'],
    )));
    await tester.pumpAndSettle();

    expect(find.text('Treatment Steps'), findsOneWidget);
    expect(find.text('Diagnosis'), findsOneWidget);
    expect(find.text('Add to Field Calendar'), findsOneWidget);
  });

  testWidgets('healthy crop shows the healthy severity', (tester) async {
    await tester.pumpWidget(buildResult(const DiagnosisInput(
      diseaseDetected: 'Healthy / no disease detected',
      confidenceScore: 96,
      commonCrop: 'Pechay',
      recommendedActions: ['Keep monitoring'],
    )));
    await tester.pumpAndSettle();

    expect(find.text('Healthy'), findsWidgets);
  });
}
