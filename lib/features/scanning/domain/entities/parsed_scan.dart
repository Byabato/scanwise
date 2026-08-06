import '../enums/barcode_symbology.dart';
import '../enums/scan_kind.dart';
import '../enums/scan_source.dart';
import '../failures/scan_parse_warning.dart';
import '../identity/content_identity.dart';
import 'scan_action_descriptor.dart';
import 'scan_payload.dart';
import '../security/structural_assessment.dart';

/// The authoritative, immutable interpretation of one scan.
///
/// This is the domain contract Milestone 002's `ResultFixture` stood in
/// for. It intentionally excludes every field that belongs to
/// user-editable Library metadata (`note`, `favorite`, `collectionId`,
/// saved status, occurrence/scan count) — those are recorded against a
/// scan's [identity] by a later persistence milestone, not carried on the
/// parse result itself. See docs/engineering/data-model.md.
class ParsedScan {
  const ParsedScan({
    required this.identity,
    required this.rawValue,
    required this.normalizedValue,
    required this.kind,
    required this.symbology,
    required this.source,
    required this.capturedAt,
    required this.title,
    this.subtitle,
    required this.payload,
    this.attributes = const {},
    this.actions = const [],
    this.warnings = const [],
    this.structuralAssessment,
  });

  /// Doubles as this scan's stable identity ("id or stable identity" per
  /// docs/plans/003-domain-and-parsing.md) — see
  /// docs/engineering/normalization-and-identity.md for how it's computed
  /// and its documented limitations.
  final ContentIdentity identity;

  /// The exact decoded text. Never mutated, never normalized in place —
  /// treated as potentially sensitive everywhere it flows.
  final String rawValue;

  /// A kind-specific canonical representation used for identity and,
  /// where meaningful, display — see docs/engineering/normalization-and-identity.md
  /// for the rule that applies to each [kind].
  final String normalizedValue;

  final ScanKind kind;
  final BarcodeSymbology symbology;
  final ScanSource source;
  final DateTime capturedAt;

  /// Human-readable headline, e.g. a contact's full name or a URL's host.
  final String title;
  final String? subtitle;

  final ScanPayload payload;

  /// Supplementary technical rows (already human-labeled) for the
  /// collapsed-by-default technical details section — e.g. `{'Symbology':
  /// 'QR Code', 'Format': 'vCard 3.0'}`. Deliberately flat strings: this
  /// is the one place a map is appropriate, since these are always
  /// non-sensitive metadata *about* the scan, not the interpreted content
  /// itself (that lives in [payload]).
  final Map<String, String> attributes;

  final List<ScanActionDescriptor> actions;

  /// Non-fatal issues surfaced during parsing (e.g. a malformed vCard
  /// field, an invalid ISBN check digit) — see
  /// docs/engineering/parsing-strategy.md's fallback policy.
  final List<ScanParseWarning> warnings;

  /// The Milestone 004 structural URL/security assessment. Computed by
  /// `ParserRegistry` for every [ScanKind.url] result via
  /// `UrlStructuralAnalyzer` — always null for every other kind. See
  /// docs/engineering/url-structural-analysis.md.
  final StructuralAssessment? structuralAssessment;
}
