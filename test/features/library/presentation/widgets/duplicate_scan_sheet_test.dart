import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/library/application/library_preview_controller.dart';
import 'package:scanwise/features/library/presentation/scan_detail_screen.dart';
import 'package:scanwise/features/library/presentation/widgets/duplicate_scan_sheet.dart';
import 'package:scanwise/shared/fixtures/catalog/collection_fixtures.dart';
import 'package:scanwise/shared/fixtures/catalog/library_fixtures.dart';

({ProviderContainer container, Widget widget}) _harness() {
  final container = ProviderContainer();
  final router = GoRouter(
    initialLocation: '/host',
    routes: [
      GoRoute(
        path: '/host',
        builder: (context, state) => Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => DuplicateScanSheet.show(
                context,
                item: secondWifiLibraryItemFixture,
              ),
              child: const Text('Open sheet'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/library/scan/:scanId',
        builder: (context, state) =>
            ScanDetailScreen(scanId: state.pathParameters['scanId']!),
      ),
    ],
  );
  final widget = UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
  return (container: container, widget: widget);
}

void main() {
  testWidgets('shows previous metadata: date, collection, note, occurrences', (
    tester,
  ) async {
    final harness = _harness();
    addTearDown(harness.container.dispose);

    await tester.pumpWidget(harness.widget);
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    expect(find.text('You scanned this before'), findsOneWidget);
    expect(find.text('Guest_Network_742'), findsOneWidget);
    expect(
      find.textContaining(wifiNetworksCollectionFixture.name),
      findsOneWidget,
    );
    expect(find.textContaining('Front desk network'), findsOneWidget);
    expect(find.textContaining('Scanned 3 times'), findsOneWidget);
  });

  testWidgets('"Open existing record" navigates to the scan detail screen', (
    tester,
  ) async {
    final harness = _harness();
    addTearDown(harness.container.dispose);

    await tester.pumpWidget(harness.widget);
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open existing record'));
    await tester.pumpAndSettle();

    expect(find.text('Scan detail'), findsOneWidget);
  });

  testWidgets('"Record new occurrence" bumps the count and confirms', (
    tester,
  ) async {
    final harness = _harness();
    addTearDown(harness.container.dispose);

    await tester.pumpWidget(harness.widget);
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Record new occurrence'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Recorded a new occurrence'), findsOneWidget);
    final updated = harness.container
        .read(libraryPreviewControllerProvider)
        .items
        .firstWhere((item) => item.id == secondWifiLibraryItemFixture.id);
    expect(
      updated.occurrenceCount,
      secondWifiLibraryItemFixture.occurrenceCount + 1,
    );
  });

  testWidgets('"Save separately" is an honest preview with no state change', (
    tester,
  ) async {
    final harness = _harness();
    addTearDown(harness.container.dispose);

    await tester.pumpWidget(harness.widget);
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save separately'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('will be available once Library persistence'),
      findsOneWidget,
    );
    final unchanged = harness.container
        .read(libraryPreviewControllerProvider)
        .items
        .firstWhere((item) => item.id == secondWifiLibraryItemFixture.id);
    expect(
      unchanged.occurrenceCount,
      secondWifiLibraryItemFixture.occurrenceCount,
    );
  });

  testWidgets('"Dismiss" closes the sheet without side effects', (
    tester,
  ) async {
    final harness = _harness();
    addTearDown(harness.container.dispose);

    await tester.pumpWidget(harness.widget);
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(find.text('You scanned this before'), findsNothing);
  });
}
