import '../../entities/scan_candidate.dart';
import '../../entities/scan_payload.dart';
import '../../enums/scan_kind.dart';
import '../../failures/scan_parse_failure.dart';
import '../../normalization/phone_normalization.dart';
import '../scan_parse_result.dart';
import '../scan_payload_parser.dart';

/// Parses a `tel:` URI (RFC 3966), including an `;ext=` extension where
/// present. Performs no country-specific validation — see
/// `phone_normalization.dart`.
class PhoneParser implements ScanPayloadParser {
  const PhoneParser();

  static final _extensionPattern = RegExp(
    r';ext=([0-9]+)',
    caseSensitive: false,
  );

  @override
  bool canParse(ScanCandidate candidate) {
    return candidate.rawValue.trim().toLowerCase().startsWith('tel:');
  }

  @override
  ScanParseResult parse(ScanCandidate candidate) {
    final value = candidate.rawValue.trim();
    final withoutScheme = value.substring('tel:'.length);

    final extensionMatch = _extensionPattern.firstMatch(withoutScheme);
    final numberPart = extensionMatch == null
        ? withoutScheme
        : withoutScheme.substring(0, extensionMatch.start);
    final extension = extensionMatch?.group(1);

    final normalized = normalizePhoneNumber(numberPart);
    if (normalized.isEmpty) {
      return const ScanParseFailed(
        UnsupportedStructuredPayloadFailure('tel with no digits'),
      );
    }

    return ScanParseSuccess(
      kind: ScanKind.phone,
      payload: PhonePayload(
        rawNumber: numberPart.trim(),
        normalizedNumber: normalized,
        extension: extension,
      ),
      title: normalized,
      normalizedValue: normalized,
    );
  }
}
