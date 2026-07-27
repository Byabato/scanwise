import 'result_fixture_kind.dart';

/// Temporary fixture/presentation model for Milestone 002 static UI. Not an
/// authoritative domain contract — Milestone 003 defines parsing,
/// normalization, duplicate identity and persistence models separately.
///
/// Consumed by Milestone 002B's collection screens.
class CollectionFixture {
  const CollectionFixture({
    required this.id,
    required this.name,
    this.description,
    this.itemCount = 0,
    this.suggestedForKinds = const [],
  });

  final String id;
  final String name;
  final String? description;
  final int itemCount;

  /// Result kinds this collection is suggested for during Save — a static
  /// lookup table, not an inference algorithm.
  final List<ResultFixtureKind> suggestedForKinds;
}
