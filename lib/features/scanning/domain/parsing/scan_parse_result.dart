import '../entities/scan_payload.dart';
import '../enums/scan_kind.dart';
import '../failures/scan_parse_failure.dart';
import '../failures/scan_parse_warning.dart';

/// The result of a single [ScanPayloadParser.parse] call.
sealed class ScanParseResult {
  const ScanParseResult();
}

/// The parser produced structured content, possibly with non-fatal
/// [warnings] (e.g. a partially-populated vCard).
final class ScanParseSuccess extends ScanParseResult {
  const ScanParseSuccess({
    required this.kind,
    required this.payload,
    required this.title,
    this.subtitle,
    required this.normalizedValue,
    this.warnings = const [],
  });

  final ScanKind kind;
  final ScanPayload payload;
  final String title;
  final String? subtitle;
  final String normalizedValue;
  final List<ScanParseWarning> warnings;
}

/// The parser committed to handling this candidate (`canParse` returned
/// true) but could not produce structured content. [ParserRegistry] turns
/// this into a plain-text or unknown fallback carrying [failure] as a
/// warning — it is never surfaced to a caller as-is.
final class ScanParseFailed extends ScanParseResult {
  const ScanParseFailed(this.failure);

  final ScanParseFailure failure;
}
