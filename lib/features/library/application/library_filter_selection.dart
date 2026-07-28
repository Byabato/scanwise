import '../../../shared/fixtures/models/result_fixture_kind.dart';

/// Immutable snapshot of the Library filter sheet's selections. Applied by
/// [LibraryPreviewState.visibleItems] on top of the current search query.
///
/// Temporary preview-only state for Milestone 002B — not a persisted user
/// preference.
class LibraryFilterSelection {
  const LibraryFilterSelection({
    this.favoritesOnly = false,
    this.kinds = const {},
    this.collectionId,
  });

  final bool favoritesOnly;

  /// Empty means "all kinds" — no type filter applied.
  final Set<ResultFixtureKind> kinds;

  /// Null means "all collections" — no collection filter applied.
  final String? collectionId;

  bool get isActive =>
      favoritesOnly || kinds.isNotEmpty || collectionId != null;

  /// Returns a copy with the given fields replaced. Pass [clearCollectionId]
  /// to explicitly null out the collection filter, since a plain `null`
  /// argument means "leave unchanged".
  LibraryFilterSelection copyWith({
    bool? favoritesOnly,
    Set<ResultFixtureKind>? kinds,
    String? collectionId,
    bool clearCollectionId = false,
  }) {
    return LibraryFilterSelection(
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      kinds: kinds ?? this.kinds,
      collectionId: clearCollectionId
          ? null
          : (collectionId ?? this.collectionId),
    );
  }
}
