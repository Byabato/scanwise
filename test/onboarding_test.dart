import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets('onboarding advances through all three pages in order', (
    tester,
  ) async {
    await pumpScanWiseApp(tester);

    expect(find.text('Understand every scan'), findsOneWidget);
    expect(find.text('Start scanning'), findsNothing);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Review before opening'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Keep useful scans organized'), findsOneWidget);
    expect(
      find.text(
        'Scan contents are processed on your device and are not uploaded '
        'by ScanWise.',
      ),
      findsOneWidget,
    );
    expect(find.text('Start scanning'), findsOneWidget);
  });

  testWidgets(
    'completing onboarding lands on Scan as the initial destination',
    (tester) async {
      await pumpScanWiseApp(tester);
      await completeOnboarding(tester);

      expect(find.text('Understand every scan'), findsNothing);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    },
  );
}
