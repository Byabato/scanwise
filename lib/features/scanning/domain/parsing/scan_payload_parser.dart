import '../entities/scan_candidate.dart';
import 'scan_parse_result.dart';

/// A single scan-kind's parsing rule.
///
/// Implementations must never throw for malformed or adversarial input —
/// [canParse] does a cheap, decisive check (a scheme prefix, a symbology
/// check, a shape check), and once it returns true, [parse] must always
/// return a [ScanParseResult] (success or [ScanParseFailed]), degrading
/// safely rather than crashing. See docs/engineering/parsing-strategy.md.
abstract interface class ScanPayloadParser {
  bool canParse(ScanCandidate candidate);

  ScanParseResult parse(ScanCandidate candidate);
}
