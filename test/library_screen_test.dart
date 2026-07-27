import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets('the Library empty-state primary action returns to Scan', (
    tester,
  ) async {
    await pumpScanWiseApp(tester);
    await completeOnboarding(tester);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.text('No scans yet'), findsOneWidget);

    await tester.tap(find.text('Start scanning'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Position a QR code or barcode inside the frame. ScanWise will '
        'explain it before you open or save anything.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the Library search control is visible but disabled', (
    tester,
  ) async {
    await pumpScanWiseApp(tester);
    await completeOnboarding(tester);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();

    expect(find.text('Search your library'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
  });
}
