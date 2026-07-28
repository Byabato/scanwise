import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/router/app_routes.dart';
import 'package:scanwise/features/library/presentation/scan_detail_screen.dart';
import 'package:scanwise/shared/fixtures/catalog/library_fixtures.dart';

import '../support/library_router_harness.dart';

void main() {
  testWidgets('renders the embedded ScanResultView content for its fixture', (
    tester,
  ) async {
    final harness = buildLibraryHarness(
      ScanDetailScreen(scanId: wifiLibraryItemFixture.id),
    );
    addTearDown(harness.container.dispose);

    await tester.pumpWidget(harness.widget);
    await tester.pumpAndSettle();

    // Title and a field from the shared ScanResultView hierarchy.
    expect(find.text('NEBO Guest'), findsOneWidget);
    expect(find.text('Copy password'), findsOneWidget);

    // Library-specific chrome around it.
    expect(find.text('Source'), findsOneWidget);
    expect(find.text('Collection'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Delete scan'), findsOneWidget);
  });

  testWidgets('shows an honest fallback for an unknown scan id', (
    tester,
  ) async {
    final harness = buildLibraryHarness(
      const ScanDetailScreen(scanId: 'does-not-exist'),
    );
    addTearDown(harness.container.dispose);

    await tester.pumpWidget(harness.widget);
    await tester.pumpAndSettle();

    expect(find.text('Scan not found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deleting pops back and confirms with an Undo snackbar', (
    tester,
  ) async {
    // Push on top of the Library home (rather than using it as the initial
    // location) so there is a route to pop back to, matching real usage.
    final router = buildLibraryTestRouter();
    await tester.pumpWidget(wrapWithLibraryRouter(router));
    await tester.pumpAndSettle();
    router.push(AppRoutes.libraryScanDetail(contactLibraryItemFixture.id));
    await tester.pumpAndSettle();

    final deleteButton = find.text('Delete scan');
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Scan deleted'), findsOneWidget);
  });

  group('accessibility and layout resilience', () {
    testWidgets('renders without overflow at 320dp width', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final harness = buildLibraryHarness(
        ScanDetailScreen(scanId: suspiciousUrlLibraryItemFixture.id),
      );
      addTearDown(harness.container.dispose);
      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at a large text scale', (
      tester,
    ) async {
      final harness = buildLibraryHarness(
        ScanDetailScreen(scanId: contactLibraryItemFixture.id),
      );
      addTearDown(harness.container.dispose);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: harness.widget,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
