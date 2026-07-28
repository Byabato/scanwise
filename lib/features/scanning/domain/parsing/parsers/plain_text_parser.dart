import '../../entities/scan_candidate.dart';
import '../../entities/scan_payload.dart';
import '../../enums/scan_kind.dart';
import '../../normalization/text_normalization.dart';
import '../scan_parse_result.dart';
import '../scan_payload_parser.dart';

/// The universal structured-content fallback: any content every other
/// parser declined, provided it is displayable text.
///
/// Declines only for content that isn't safely displayable as text (the
/// Unicode replacement character, indicating a lossy decode upstream, or
/// control characters other than tab/newline/carriage return) — that
/// residue falls through to [UnknownParser], the true last resort.
class PlainTextParser implements ScanPayloadParser {
  const PlainTextParser();

  @override
  bool canParse(ScanCandidate candidate) =>
      _looksLikeDisplayableText(candidate.rawValue);

  @override
  ScanParseResult parse(ScanCandidate candidate) {
    return ScanParseSuccess(
      kind: ScanKind.plainText,
      payload: PlainTextPayload(text: candidate.rawValue),
      title: 'Scanned text',
      normalizedValue: normalizePlainText(candidate.rawValue),
    );
  }

  bool _looksLikeDisplayableText(String value) {
    if (value.contains('�')) return false;
    for (final unit in value.codeUnits) {
      final isCommonWhitespace = unit == 0x09 || unit == 0x0A || unit == 0x0D;
      if (!isCommonWhitespace && unit < 0x20) return false;
      if (unit == 0x7F) return false;
    }
    return true;
  }
}
