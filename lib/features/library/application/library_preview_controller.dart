import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/fixtures/catalog/library_fixtures.dart';
import '../../../shared/fixtures/models/library_item_fixture.dart';
import 'library_filter_selection.dart';

/// Seed data for the Library preview. Tests and the empty-state preview
/// override this provider (e.g.
/// `libraryPreviewSeedProvider.overrideWithValue(emptyLibraryItemFixtures)`)
/// instead of touching [LibraryPreviewController].
final libraryPreviewSeedProvider = Provider<List<LibraryItemFixture>>(
  (ref) => populatedLibraryItemFixtures,
);

/// Fixed "now" anchor for date-grouping and relative-date copy across the
/// Library preview. Matches the newest fixture date in library_fixtures.dart
/// so grouping and copy stay deterministic regardless of the real date.
final libraryPreviewNow = DateTime(2026, 7, 28);

/// Synchronous, in-memory Library preview state. Not a persistence layer —
/// every mutation lives only for the life of this provider.
class LibraryPreviewState {
  LibraryPreviewState({
    required this.items,
    this.searchQuery = '',
    this.filters = const LibraryFilterSelection(),
    this.lastDeleted,
  });

  final List<LibraryItemFixture> items;
  final String searchQuery;
  final LibraryFilterSelection filters;

  /// The most recently deleted item and its original index, kept only long
  /// enough to support Undo. Cleared once Undo is used or a new delete
  /// replaces it.
  final ({LibraryItemFixture item, int index})? lastDeleted;

  /// [items] filtered by [searchQuery] (against title, subtitle and note,
  /// case-insensitive) and [filters], then sorted newest-saved-first.
  List<LibraryItemFixture> get visibleItems {
    final query = searchQuery.trim().toLowerCase();

    var results = items.where((item) {
      if (query.isEmpty) return true;
      final haystack = [
        item.result.title,
        if (item.result.subtitle != null) item.result.subtitle!,
        if (item.note != null) item.note!,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    });

    if (filters.favoritesOnly) {
      results = results.where((item) => item.isFavorite);
    }
    if (filters.kinds.isNotEmpty) {
      results = results.where(
        (item) => filters.kinds.contains(item.result.kind),
      );
    }
    if (filters.collectionId != null) {
      results = results.where(
        (item) => item.collectionId == filters.collectionId,
      );
    }

    final sorted = results.toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return sorted;
  }

  LibraryPreviewState copyWith({
    List<LibraryItemFixture>? items,
    String? searchQuery,
    LibraryFilterSelection? filters,
    ({LibraryItemFixture item, int index})? lastDeleted,
    bool clearLastDeleted = false,
  }) {
    return LibraryPreviewState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      lastDeleted: clearLastDeleted ? null : (lastDeleted ?? this.lastDeleted),
    );
  }
}

/// Orchestrates the session-only Library preview: search, filters, and the
/// favorite / note / collection / occurrence / delete mutations the 002B
/// screens demonstrate. Every mutation is synchronous — there is no
/// persistence layer yet.
class LibraryPreviewController extends Notifier<LibraryPreviewState> {
  @override
  LibraryPreviewState build() {
    return LibraryPreviewState(
      items: List.of(ref.watch(libraryPreviewSeedProvider)),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void applyFilters(LibraryFilterSelection filters) {
    state = state.copyWith(filters: filters);
  }

  void toggleFavorite(String id) {
    _updateItem(id, (item) => item.copyWith(isFavorite: !item.isFavorite));
  }

  void updateNote(String id, String? note) {
    _updateItem(
      id,
      (item) => (note == null || note.isEmpty)
          ? item.copyWith(clearNote: true)
          : item.copyWith(note: note),
    );
  }

  void assignCollection(String id, String? collectionId) {
    _updateItem(
      id,
      (item) => collectionId == null
          ? item.copyWith(clearCollection: true)
          : item.copyWith(collectionId: collectionId),
    );
  }

  /// Bumps the occurrence count — used when the user chooses "Record new
  /// occurrence" from the duplicate-scan sheet.
  void recordOccurrence(String id) {
    _updateItem(
      id,
      (item) => item.copyWith(occurrenceCount: item.occurrenceCount + 1),
    );
  }

  void deleteItem(String id) {
    final index = state.items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = state.items[index];
    final updated = List.of(state.items)..removeAt(index);
    state = state.copyWith(
      items: updated,
      lastDeleted: (item: item, index: index),
    );
  }

  void undoDelete() {
    final pending = state.lastDeleted;
    if (pending == null) return;

    final updated = List.of(state.items);
    final insertIndex = pending.index.clamp(0, updated.length);
    updated.insert(insertIndex, pending.item);
    state = state.copyWith(items: updated, clearLastDeleted: true);
  }

  void _updateItem(
    String id,
    LibraryItemFixture Function(LibraryItemFixture item) transform,
  ) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == id) transform(item) else item,
      ],
    );
  }
}

final libraryPreviewControllerProvider =
    NotifierProvider<LibraryPreviewController, LibraryPreviewState>(
      LibraryPreviewController.new,
    );
