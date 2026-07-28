import '../enums/scan_kind.dart';

/// A deterministic, opaque identity for semantically-equivalent scan
/// content, scoped to keep future duplicate recognition safe to build on.
///
/// Two [ParsedScan]s produce equal [ContentIdentity] values only when
/// [buildContentIdentity] considers them the same underlying content for
/// their [kind] — see docs/engineering/normalization-and-identity.md for
/// the exact rule per kind and its documented limitations. Never
/// constructed directly outside [buildContentIdentity]; never exposes the
/// raw scanned value ([value] is a hash, not the content itself).
class ContentIdentity {
  const ContentIdentity({required this.kind, required this.value});

  final ScanKind kind;

  /// A stable hex digest. Deliberately computed by this package's own
  /// hashing (see `_stableHash` in content_identity_builder.dart) rather
  /// than `Object.hashCode`, which Dart does not guarantee is stable
  /// across SDK versions or platforms — unsuitable for anything a later
  /// milestone might persist.
  final String value;

  @override
  bool operator ==(Object other) =>
      other is ContentIdentity && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);

  @override
  String toString() => 'ContentIdentity(${kind.name}:$value)';
}
