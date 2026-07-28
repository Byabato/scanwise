import '../../entities/scan_candidate.dart';
import '../../entities/scan_payload.dart';
import '../../enums/scan_kind.dart';
import '../scan_parse_result.dart';
import '../scan_payload_parser.dart';

/// The absolute last resort: always matches, and always succeeds. Never
/// invents an interpretation — the resulting title matches
/// docs/product/product-contract.md's "unsupported content" wording
/// exactly, and [UnknownPayload.reason] stays generic and non-sensitive.
class UnknownParser implements ScanPayloadParser {
  const UnknownParser();

  @override
  bool canParse(ScanCandidate candidate) => true;

  @override
  ScanParseResult parse(ScanCandidate candidate) {
    return ScanParseSuccess(
      kind: ScanKind.unknown,
      payload: UnknownPayload(
        rawValue: candidate.rawValue,
        reason: 'unrecognized-content',
      ),
      title: 'Content type not recognized',
      subtitle: "ScanWise couldn't interpret this code's structure.",
      normalizedValue: candidate.rawValue,
    );
  }
}
