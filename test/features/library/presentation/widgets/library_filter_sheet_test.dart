import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/library/application/library_filter_selection.dart';
import 'package:scanwise/features/library/presentation/widgets/library_filter_sheet.dart';
import 'package:scanwise/shared/fixtures/catalog/collection_fixtures.dart';
import 'package:scanwise/shared/fixtures/models/result_fixture_kind.dart';

Widget _wrap(ValueChanged<LibraryFilterSelection?> onResult) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            final result = await LibraryFilterSheet.show(
              context,
              initialSelection: const LibraryFilterSelection(),
            );
            onResult(result);
          },
          child: const Text('Open filters'),
        ),
      ),
    ),
  );
}

/// Scrolls [finder] into view before tapping it — the filter sheet's
/// content (favorites toggle, 12 kind chips, collections, actions) is
/// taller than the default test viewport, so an un-scrolled tap can
/// silently miss.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
}

void main() {
  testWidgets('favorites-only toggle is reflected in the applied selection', (
    tester,
  ) async {
    LibraryFilterSelection? applied;
    await tester.pumpWidget(_wrap((value) => applied = value));

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    await _tap(tester, find.text('Favorites only'));
    await _tap(tester, find.text('Apply'));
    await tester.pumpAndSettle();

    expect(applied?.favoritesOnly, isTrue);
  });

  testWidgets('a kind chip selection is reflected in the applied selection', (
    tester,
  ) async {
    LibraryFilterSelection? applied;
    await tester.pumpWidget(_wrap((value) => applied = value));

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    await _tap(tester, find.text('Wi-Fi'));
    await _tap(tester, find.text('Apply'));
    await tester.pumpAndSettle();

    expect(applied?.kinds, contains(ResultFixtureKind.wifi));
  });

  testWidgets('a collection selection is reflected in the applied selection', (
    tester,
  ) async {
    LibraryFilterSelection? applied;
    await tester.pumpWidget(_wrap((value) => applied = value));

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    await _tap(tester, find.text(wifiNetworksCollectionFixture.name));
    await _tap(tester, find.text('Apply'));
    await tester.pumpAndSettle();

    expect(applied?.collectionId, wifiNetworksCollectionFixture.id);
  });

  testWidgets('Reset clears every selection', (tester) async {
    LibraryFilterSelection? applied;
    await tester.pumpWidget(_wrap((value) => applied = value));

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    await _tap(tester, find.text('Favorites only'));
    await _tap(tester, find.text('Wi-Fi'));
    await _tap(tester, find.text('Reset'));
    await _tap(tester, find.text('Apply'));
    await tester.pumpAndSettle();

    expect(applied?.isActive, isFalse);
  });
}
