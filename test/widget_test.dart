import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/scanwise_app.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets('ScanWise launches and shows onboarding first', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ScanWiseApp()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Understand every scan'), findsOneWidget);
  });

  testWidgets('app launch reaches the Scan destination after onboarding', (
    tester,
  ) async {
    await pumpScanWiseApp(tester);
    await completeOnboarding(tester);

    expect(
      find.text(
        'Position a QR code or barcode inside the frame. ScanWise will '
        'explain it before you open or save anything.',
      ),
      findsOneWidget,
    );
  });
}
