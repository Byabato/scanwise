import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/scanner/presentation/scan_screen.dart';
import 'package:scanwise/features/scanner/presentation/states/gallery_loading_state.dart';
import 'package:scanwise/features/scanner/presentation/states/no_code_found_state.dart';
import 'package:scanwise/features/scanner/presentation/states/permission_denied_state.dart';
import 'package:scanwise/features/scanner/presentation/states/permission_permanently_denied_state.dart';
import 'package:scanwise/features/scanner/presentation/states/scanner_detected_state.dart';
import 'package:scanwise/features/scanner/presentation/states/scanner_unavailable_state.dart';
import 'package:scanwise/shared/fixtures/catalog/result_fixtures.dart';

/// Each state is constructed directly, matching the plan's requirement that
/// widget tests inject preview states without depending on the debug
/// component gallery.
Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

void main() {
  testWidgets('default scanner state shows the idle instruction', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const ScanScreen()));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Position a QR code or barcode'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('detected state opens the result sheet for the given fixture', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const ScannerDetectedState(fixture: wifiResultFixture)),
    );
    await tester.pumpAndSettle();

    expect(find.text('NEBO Guest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gallery loading state announces progress deterministically', (
    tester,
  ) async {
    // `pump()`, not `pumpAndSettle()`: the indeterminate progress
    // indicator animates forever, so settling would time out.
    await tester.pumpWidget(_wrap(const GalleryLoadingState()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('Analyzing selected image'), findsOneWidget);
  });

  testWidgets('no code found state offers a disabled retry action', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const NoCodeFoundState()));
    await tester.pumpAndSettle();

    expect(find.text('No code found'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Try another image'),
        // `FilledButton.icon` returns a private subclass, so
        // `find.byType(FilledButton)` would miss it.
        matching: find.byWidgetPredicate((widget) => widget is FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('scanner unavailable state explains the failure', (tester) async {
    await tester.pumpWidget(_wrap(const ScannerUnavailableState()));
    await tester.pumpAndSettle();

    expect(find.text('Scanner unavailable'), findsOneWidget);
  });

  testWidgets('permission denied state offers retry and gallery import', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const PermissionDeniedState()));
    await tester.pumpAndSettle();

    expect(find.text('Camera access needed'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Import from gallery instead'), findsOneWidget);
  });

  testWidgets('permission permanently denied state points to app settings', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const PermissionPermanentlyDeniedState()));
    await tester.pumpAndSettle();

    expect(find.text('Camera access is turned off'), findsOneWidget);
    expect(find.text('Open app settings'), findsOneWidget);
  });
}
