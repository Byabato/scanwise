import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` isn't re-exported from the main `flutter_riverpod.dart`
// barrel in Riverpod 3.x — it lives in `misc.dart`.
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/library/application/library_filter_selection.dart';
import 'package:scanwise/features/library/application/library_preview_controller.dart';
import 'package:scanwise/shared/fixtures/catalog/collection_fixtures.dart';
import 'package:scanwise/shared/fixtures/catalog/library_fixtures.dart';
import 'package:scanwise/shared/fixtures/models/result_fixture_kind.dart';

void main() {
  ProviderContainer buildContainer({List<Override> overrides = const []}) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  group('search and filters', () {
    test('search matches title, subtitle and note, case-insensitively', () {
      final container = buildContainer();
      final controller = container.read(
        libraryPreviewControllerProvider.notifier,
      );

      controller.setSearchQuery('sarah');
      final results = container
          .read(libraryPreviewControllerProvider)
          .visibleItems;

      expect(results, hasLength(1));
      expect(results.single.result.title, 'Sarah Jenkins');
    });

    test('favorites-only filter narrows the list', () {
      final container = buildContainer();
      final controller = container.read(
        libraryPreviewControllerProvider.notifier,
      );

      controller.applyFilters(
        const LibraryFilterSelection(favoritesOnly: true),
      );
      final results = container
          .read(libraryPreviewControllerProvider)
          .visibleItems;

      expect(results, isNotEmpty);
      expect(results.every((item) => item.isFavorite), isTrue);
    });

    test('kind filter narrows the list to that result kind', () {
      final container = buildContainer();
      final controller = container.read(
        libraryPreviewControllerProvider.notifier,
      );

      controller.applyFilters(
        const LibraryFilterSelection(kinds: {ResultFixtureKind.wifi}),
      );
      final results = container
          .read(libraryPreviewControllerProvider)
          .visibleItems;

      expect(results, isNotEmpty);
      expect(
        results.every((item) => item.result.kind == ResultFixtureKind.wifi),
        isTrue,
      );
    });

    test('collection filter narrows the list to that collection', () {
      final container = buildContainer();
      final controller = container.read(
        libraryPreviewControllerProvider.notifier,
      );

      controller.applyFilters(
        LibraryFilterSelection(collectionId: wifiNetworksCollectionFixture.id),
      );
      final results = container
          .read(libraryPreviewControllerProvider)
          .visibleItems;

      expect(results, isNotEmpty);
      expect(
        results.every(
          (item) => item.collectionId == wifiNetworksCollectionFixture.id,
        ),
        isTrue,
      );
    });

    test('visibleItems is sorted newest-saved-first', () {
      final container = buildContainer();
      final results = container
          .read(libraryPreviewControllerProvider)
          .visibleItems;

      for (var i = 0; i < results.length - 1; i++) {
        expect(
          results[i].savedAt.isAfter(results[i + 1].savedAt) ||
              results[i].savedAt.isAtSameMomentAs(results[i + 1].savedAt),
          isTrue,
        );
      }
    });
  });

  group('mutations', () {
    test('toggleFavorite flips the flag for just that item', () {
      final container = buildContainer();
      final controller = container.read(
        libraryPreviewControllerProvider.notifier,
      );
      final targetId = wifiLibraryItemFixture.id;
      final before = container
          .read(libraryPreviewControllerProvider)
          .items
          .firstWhere((item) => item.id == targetId)
          .isFavorite;

      controller.toggleFavorite(targetId);

      final after = container
          .read(libraryPreviewControllerProvider)
          .items
          .firstWhere((item) => item.id == targetId)
          .isFavorite;
      expect(after, !before);
    });

    test('updateNote sets and clears a note', () {
      final container = buildContainer();
      final controller = container.read(
        libraryPreviewControllerProvider.notifier,
      );
      final targetId = wifiLibraryItemFixture.id;

      controller.updateNote(targetId, 'Front desk credentials');
      expect(
        container
            .read(libraryPreviewControllerProvider)
            .items
            .firstWhere((item) => item.id == targetId)
            .note,
        'Front desk credentials',
      );

      controller.updateNote(targetId, null);
      expect(
        container
            .read(libraryPreviewControllerProvider)
            .items
            .firstWhere((item) => item.id == targetId)
            .note,
        isNull,
      );
    });

    test('assignCollection sets and clears the collection', () {
      final container = buildContainer();
      final controller = container.read(
        libraryPreviewControllerProvider.notifier,
      );
      final targetId = phoneLibraryItemFixture.id;

      controller.assignCollection(targetId, eventContactsCollectionFixture.id);
      expect(
        container
            .read(libraryPreviewControllerProvider)
            .items
            .firstWhere((item) => item.id == targetId)
            .collectionId,
        eventContactsCollectionFixture.id,
      );

      controller.assignCollection(targetId, null);
      expect(
        container
            .read(libraryPreviewControllerProvider)
            .items
            .firstWhere((item) => item.id == targetId)
            .collectionId,
        isNull,
      );
    });

    test('recordOccurrence increments the occurrence count', () {
      final container = buildContainer();
      final controller = container.read(
        libraryPreviewControllerProvider.notifier,
      );
      final targetId = secondWifiLibraryItemFixture.id;
      final before = secondWifiLibraryItemFixture.occurrenceCount;

      controller.recordOccurrence(targetId);

      expect(
        container
            .read(libraryPreviewControllerProvider)
            .items
            .firstWhere((item) => item.id == targetId)
            .occurrenceCount,
        before + 1,
      );
    });
  });

  group('delete and undo', () {
    test('deleteItem removes the item and undoDelete restores it in place', () {
      final container = buildContainer();
      final controller = container.read(
        libraryPreviewControllerProvider.notifier,
      );
      final originalItems = container
          .read(libraryPreviewControllerProvider)
          .items;
      final targetIndex = 2;
      final targetId = originalItems[targetIndex].id;

      controller.deleteItem(targetId);
      final afterDelete = container.read(libraryPreviewControllerProvider);
      expect(afterDelete.items.any((item) => item.id == targetId), isFalse);
      expect(afterDelete.lastDeleted?.item.id, targetId);

      controller.undoDelete();
      final afterUndo = container.read(libraryPreviewControllerProvider);
      expect(afterUndo.items[targetIndex].id, targetId);
      expect(afterUndo.lastDeleted, isNull);
    });

    test('deleting an unknown id is a no-op', () {
      final container = buildContainer();
      final controller = container.read(
        libraryPreviewControllerProvider.notifier,
      );
      final before = container
          .read(libraryPreviewControllerProvider)
          .items
          .length;

      controller.deleteItem('does-not-exist');

      expect(
        container.read(libraryPreviewControllerProvider).items.length,
        before,
      );
    });
  });

  test('seed override drives an empty starting library', () {
    final container = buildContainer(
      overrides: [libraryPreviewSeedProvider.overrideWithValue(const [])],
    );

    expect(container.read(libraryPreviewControllerProvider).items, isEmpty);
    expect(
      container.read(libraryPreviewControllerProvider).visibleItems,
      isEmpty,
    );
  });
}
