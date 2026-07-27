import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/scanwise_app.dart';

/// Pumps the full ScanWise app and settles the initial onboarding route.
Future<void> pumpScanWiseApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: ScanWiseApp()));
  await tester.pumpAndSettle();
}

/// Advances through all three onboarding pages and taps the final
/// "Start scanning" action, leaving the app on the Scan destination.
Future<void> completeOnboarding(WidgetTester tester) async {
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Start scanning'));
  await tester.pumpAndSettle();
}
