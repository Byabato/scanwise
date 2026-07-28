import 'result_fixture.dart';

/// Temporary fixture/presentation model for Milestone 002 static UI. Not an
/// authoritative domain contract — Milestone 003 defines parsing,
/// normalization, duplicate identity and persistence models separately.
///
/// Wraps a [ResultFixture] with the Library-specific metadata a saved scan
/// carries. Consumed by Milestone 002B's Library screens.
class LibraryItemFixture {
  const LibraryItemFixture({
    required this.id,
    required this.result,
    required this.savedAt,
    this.collectionId,
    this.note,
    this.isFavorite = false,
    this.occurrenceCount = 1,
    this.isDuplicateExample = false,
  });

  final String id;
  final ResultFixture result;
  final DateTime savedAt;
  final String? collectionId;
  final String? note;
  final bool isFavorite;
  final int occurrenceCount;

  /// True for the one fixture item used to demonstrate the duplicate-scan
  /// sheet from the Library list.
  final bool isDuplicateExample;

  /// Returns a copy with the given fields replaced. Used only for local,
  /// session-only preview mutations (favorite, note, collection, occurrence
  /// count) — never for persistence. Pass [clearNote] or [clearCollection]
  /// to explicitly null out those fields, since a plain `null` argument
  /// means "leave unchanged".
  LibraryItemFixture copyWith({
    String? collectionId,
    String? note,
    bool clearCollection = false,
    bool clearNote = false,
    bool? isFavorite,
    int? occurrenceCount,
  }) {
    return LibraryItemFixture(
      id: id,
      result: result,
      savedAt: savedAt,
      collectionId: clearCollection
          ? null
          : (collectionId ?? this.collectionId),
      note: clearNote ? null : (note ?? this.note),
      isFavorite: isFavorite ?? this.isFavorite,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      isDuplicateExample: isDuplicateExample,
    );
  }
}
