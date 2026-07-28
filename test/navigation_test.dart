import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets('bottom navigation moves between Scan, Library and Settings', (
    tester,
  ) async {
    await pumpScanWiseApp(tester);
    await completeOnboarding(tester);

    // Scan is the initial destination.
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    // The Library screen now opens populated with fixture data (Milestone
    // 002B) rather than an empty placeholder — the AppBar title is the
    // stable marker that navigation landed on the right destination.
    expect(find.widgetWithText(AppBar, 'Library'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    // Settings now has more sections than fit in the test viewport, so
    // scroll the "Theme" row (under Appearance) into view before asserting.
    await tester.scrollUntilVisible(
      find.text('Theme'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Theme'), findsOneWidget);

    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Position a QR code or barcode inside the frame. ScanWise will '
        'explain it before you open or save anything.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the selected destination shows its filled navigation icon', (
    tester,
  ) async {
    await pumpScanWiseApp(tester);
    await completeOnboarding(tester);

    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner_outlined), findsNothing);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.folder), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner_outlined), findsOneWidget);
  });
}
