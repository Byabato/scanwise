import '../actions/scan_action_resolver.dart';
import '../entities/parsed_scan.dart';
import '../entities/scan_candidate.dart';
import '../entities/scan_payload.dart';
import '../enums/barcode_symbology.dart';
import '../enums/isbn_format.dart';
import '../enums/scan_kind.dart';
import '../enums/scan_source.dart';
import '../failures/scan_parse_failure.dart';
import '../failures/scan_parse_warning.dart';
import '../identity/content_identity_builder.dart';
import 'parsers/calendar_parser.dart';
import 'parsers/contact_parser.dart';
import 'parsers/email_parser.dart';
import 'parsers/isbn_parser.dart';
import 'parsers/location_parser.dart';
import 'parsers/phone_parser.dart';
import 'parsers/plain_text_parser.dart';
import 'parsers/product_parser.dart';
import 'parsers/sms_parser.dart';
import 'parsers/unknown_parser.dart';
import 'parsers/url_parser.dart';
import 'parsers/wifi_parser.dart';
import 'parsing_limits.dart';
import 'scan_parse_outcome.dart';
import 'scan_parse_result.dart';
import 'scan_payload_parser.dart';

/// The ordered parsing pipeline, most-specific parser first.
///
/// Order matters where two parsers could otherwise both claim a bare
/// numeric value: [IsbnParser] must run before [ProductParser] so a
/// Bookland-prefixed EAN-13 is read as a book, not a generic product (see
/// `IsbnParser`'s doc comment). Every other parser matches on a distinct
/// scheme prefix or structural marker, so their relative order doesn't
/// change behavior — they're still listed by specificity for
/// readability. [PlainTextParser] and [UnknownParser] are the universal
/// fallbacks and must stay last.
final List<ScanPayloadParser> defaultScanPayloadParsers = [
  const IsbnParser(),
  const ProductParser(),
  const UrlParser(),
  const WifiParser(),
  const ContactParser(),
  const CalendarParser(),
  const EmailParser(),
  const SmsParser(),
  const PhoneParser(),
  const LocationParser(),
  const PlainTextParser(),
  const UnknownParser(),
];

/// Runs a [ScanCandidate] through the ordered parser list and assembles a
/// full [ParsedScan] — identity, actions and technical attributes
/// included — from whichever parser succeeds.
///
/// See docs/engineering/parsing-strategy.md for the full fallback policy
/// this implements: empty/oversized content are the only two failures a
/// caller ever sees ([ScanParseOutcomeFailure]); every other malformed
/// case degrades to a plain-text or unknown [ParsedScan] carrying a
/// warning, so an accepted scan always gets a result.
class ParserRegistry {
  ParserRegistry({List<ScanPayloadParser>? parsers})
    : _parsers = parsers ?? defaultScanPayloadParsers;

  final List<ScanPayloadParser> _parsers;

  ScanParseOutcome parse(ScanCandidate candidate) {
    final raw = candidate.rawValue;
    if (raw.isEmpty) {
      return const ScanParseOutcome.failure(EmptyContentFailure());
    }
    if (raw.length > kMaxScanContentLength) {
      return ScanParseOutcome.failure(
        OversizedContentFailure(
          length: raw.length,
          maxLength: kMaxScanContentLength,
        ),
      );
    }

    final priorWarnings = <ScanParseWarning>[];
    for (final parser in _parsers) {
      if (!parser.canParse(candidate)) continue;
      final result = parser.parse(candidate);
      switch (result) {
        case ScanParseSuccess success:
          return ScanParseOutcome.success(
            _toParsedScan(candidate, success, priorWarnings),
          );
        case ScanParseFailed failed:
          priorWarnings.add(ScanParseWarning.fromFailure(failed.failure));
      }
    }

    // Unreachable in practice — UnknownParser always matches and always
    // succeeds — but never throw for input-driven control flow.
    return ScanParseOutcome.success(
      _toParsedScan(
        candidate,
        ScanParseSuccess(
          kind: ScanKind.unknown,
          payload: UnknownPayload(
            rawValue: raw,
            reason: 'unrecognized-content',
          ),
          title: 'Content type not recognized',
          normalizedValue: raw,
        ),
        priorWarnings,
      ),
    );
  }

  ParsedScan _toParsedScan(
    ScanCandidate candidate,
    ScanParseSuccess success,
    List<ScanParseWarning> priorWarnings,
  ) {
    final identity = buildContentIdentity(
      kind: success.kind,
      payload: success.payload,
      normalizedValue: success.normalizedValue,
    );
    final actions = resolveScanActions(
      kind: success.kind,
      payload: success.payload,
    );
    final attributes = _buildAttributes(candidate, success.payload);

    return ParsedScan(
      identity: identity,
      rawValue: candidate.rawValue,
      normalizedValue: success.normalizedValue,
      kind: success.kind,
      symbology: candidate.symbology,
      source: candidate.source,
      capturedAt: candidate.capturedAt,
      title: success.title,
      subtitle: success.subtitle,
      payload: success.payload,
      attributes: attributes,
      actions: actions,
      warnings: [...priorWarnings, ...success.warnings],
    );
  }

  Map<String, String> _buildAttributes(
    ScanCandidate candidate,
    ScanPayload payload,
  ) {
    final attributes = <String, String>{
      'Symbology': candidate.symbology.label,
      'Scan source': candidate.source.label,
    };

    switch (payload) {
      case UrlPayload p:
        attributes['Parameters detected'] = p.query.isEmpty
            ? '0'
            : Uri.splitQueryString(p.query).length.toString();
      case ContactPayload p:
        attributes['Format'] = 'vCard ${p.vCardVersion}';
      case IsbnPayload p:
        attributes['Format'] = p.format == IsbnFormat.isbn10
            ? 'ISBN-10'
            : 'ISBN-13';
      case CalendarEventPayload():
        attributes['Format'] = 'iCalendar (VEVENT)';
      case PhonePayload():
        attributes['Scheme'] = 'tel:';
      case EmailPayload():
        attributes['Scheme'] = 'mailto:';
      case SmsPayload():
        attributes['Scheme'] = 'sms:';
      case LocationPayload():
        attributes['Scheme'] = 'geo:';
      case PlainTextPayload p:
        attributes['Character count'] = p.characterCount.toString();
      case WifiPayload():
      case ProductPayload():
      case UnknownPayload():
        break;
    }

    return attributes;
  }
}
