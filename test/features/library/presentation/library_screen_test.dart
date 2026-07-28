import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/library/application/library_preview_controller.dart';
import 'package:scanwise/features/library/presentation/library_screen.dart';
import 'package:scanwise/shared/fixtures/catalog/library_fixtures.dart';

import '../support/library_router_harness.dart';

void main() {
  group('populated library', () {
    testWidgets('renders date-grouped tiles with section headers', (
      tester,
    ) async {
      final harness = buildLibraryHarness(const LibraryScreen());
      addTearDown(harness.container.dispose);

      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      // The fixed reference date (2026-07-28) puts one item "Today" and the
      // rest across "This week" / "Earlier" — none fall on "Yesterday".
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Earlier'), findsOneWidget);
      expect(find.text('Yesterday'), findsNothing);

      expect(find.text('NEBO Guest'), findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('empty and no-matches states', () {
    testWidgets('shows the true empty state when nothing is saved', (
      tester,
    ) async {
      final harness = buildLibraryHarness(
        const LibraryScreen(),
        overrides: [
          libraryPreviewSeedProvider.overrideWithValue(
            emptyLibraryItemFixtures,
          ),
        ],
      );
      addTearDown(harness.container.dispose);

      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      expect(find.text('Nothing saved yet'), findsOneWidget);
      expect(find.text('Scan a code'), findsOneWidget);

      final galleryButton = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text('Import from gallery'),
          matching: find.byWidgetPredicate(
            (widget) => widget is OutlinedButton,
          ),
        ),
      );
      expect(galleryButton.onPressed, isNull);
    });

    testWidgets(
      'shows a distinct no-matches state when a search yields nothing',
      (tester) async {
        final harness = buildLibraryHarness(const LibraryScreen());
        addTearDown(harness.container.dispose);

        await tester.pumpWidget(harness.widget);
        await tester.pumpAndSettle();

        harness.container
            .read(libraryPreviewControllerProvider.notifier)
            .setSearchQuery('this-will-not-match-anything');
        await tester.pumpAndSettle();

        expect(find.text('No matches'), findsOneWidget);
        expect(find.text('Nothing saved yet'), findsNothing);
      },
    );
  });

  group('favorite toggle', () {
    testWidgets('flips state and exposes an accessible label', (tester) async {
      final handle = tester.ensureSemantics();
      final harness = buildLibraryHarness(const LibraryScreen());
      addTearDown(harness.container.dispose);

      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      final tileKey = ValueKey(wifiLibraryItemFixture.id);
      // The tile's own explicit semantic label (title + type) is a
      // deterministic check independent of how IconButton/Tooltip happen to
      // expose their own semantics.
      expect(
        find.bySemanticsLabel('NEBO Guest. Wi-Fi network'),
        findsOneWidget,
      );

      final starFinder = find.descendant(
        of: find.byKey(tileKey),
        matching: find.byIcon(Icons.star_border),
      );
      expect(starFinder, findsOneWidget);

      await tester.ensureVisible(starFinder);
      await tester.tap(starFinder);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(tileKey),
          matching: find.byIcon(Icons.star),
        ),
        findsOneWidget,
      );

      handle.dispose();
    });
  });

  group('delete and undo', () {
    testWidgets('deleting a scan removes it and Undo restores it', (
      tester,
    ) async {
      final harness = buildLibraryHarness(const LibraryScreen());
      addTearDown(harness.container.dispose);

      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      expect(find.text('Sarah Jenkins'), findsOneWidget);

      final deleteFinder = find.descendant(
        of: find.byKey(ValueKey(contactLibraryItemFixture.id)),
        matching: find.byIcon(Icons.delete_outline),
      );
      await tester.ensureVisible(deleteFinder);
      await tester.tap(deleteFinder);
      await tester.pumpAndSettle();

      // Confirmation sheet.
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Sarah Jenkins'), findsNothing);
      expect(find.text('Scan deleted'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(find.text('Sarah Jenkins'), findsOneWidget);
    });
  });

  group('injectable display states', () {
    testWidgets('loading state shows a progress indicator', (tester) async {
      await tester.pumpWidget(
        buildLibraryHarness(
          const LibraryScreen(previewDisplayState: LibraryDisplayState.loading),
        ).widget,
      );
      // `pump()`, not `pumpAndSettle()`: the indeterminate progress
      // indicator animates forever.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('error state explains the failure with a disabled retry', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLibraryHarness(
          const LibraryScreen(previewDisplayState: LibraryDisplayState.error),
        ).widget,
      );
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load your Library"), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Retry'),
          matching: find.byWidgetPredicate((widget) => widget is FilledButton),
        ),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('accessibility and layout resilience', () {
    testWidgets('renders without overflow at 320dp width', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final harness = buildLibraryHarness(const LibraryScreen());
      addTearDown(harness.container.dispose);
      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at a large text scale', (
      tester,
    ) async {
      final harness = buildLibraryHarness(const LibraryScreen());
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
