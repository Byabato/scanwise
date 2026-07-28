import '../../entities/scan_candidate.dart';
import '../../entities/scan_payload.dart';
import '../../enums/scan_kind.dart';
import '../../failures/scan_parse_failure.dart';
import '../../normalization/url_normalization.dart';
import '../scan_parse_result.dart';
import '../scan_payload_parser.dart';

/// Recognizes `http`/`https` URLs only — per docs/product/v1-scope.md,
/// "the application must not claim every domain-shaped string is a URL".
/// A bare `example.com` or unsupported scheme (`ftp://…`) is declined here
/// and falls through to plain text.
class UrlParser implements ScanPayloadParser {
  const UrlParser();

  // Dart's Uri.parse does not reject a stray '%' not followed by two hex
  // digits — it silently re-escapes it (`%` becomes `%25`), which would
  // quietly rewrite what the user scanned. Checked explicitly instead so
  // malformed percent-encoding degrades to plain text rather than showing
  // a mangled URL.
  static final _malformedPercentEncoding = RegExp(r'%(?![0-9A-Fa-f]{2})');

  @override
  bool canParse(ScanCandidate candidate) {
    final lower = candidate.rawValue.trim().toLowerCase();
    return RegExp(
          r'^[a-z][a-z0-9+.-]*://',
          caseSensitive: false,
        ).hasMatch(lower) ||
        lower.startsWith('http:') ||
        lower.startsWith('https:');
  }

  @override
  ScanParseResult parse(ScanCandidate candidate) {
    final value = candidate.rawValue.trim();
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return const ScanParseFailed(MalformedUrlFailure());
    }

    final scheme = uri.scheme.toLowerCase();
    final explicitPort = _explicitPort(value);
    final nestedNames = <String>[];
    try {
      for (final entry in uri.queryParametersAll.entries) {
        if (entry.value.any((value) {
          final nested = Uri.tryParse(_decodeRepeatedly(value));
          return nested != null && nested.hasScheme && nested.host.isNotEmpty;
        })) {
          nestedNames.add(entry.key);
        }
      }
    } on FormatException {
      // The assessment reports ambiguous encoding without exposing values.
    }

    return ScanParseSuccess(
      kind: ScanKind.url,
      payload: UrlPayload(
        rawUrl: value,
        uri: uri,
        scheme: scheme,
        host: uri.host,
        port: explicitPort,
        path: uri.path,
        query: uri.query,
        fragment: uri.fragment,
        hasUserInfo: uri.userInfo.isNotEmpty,
        hasExplicitPort: explicitPort != null,
        hasMalformedEncoding:
            _malformedPercentEncoding.hasMatch(value) ||
            RegExp(r'%25[0-9a-f]{2}', caseSensitive: false).hasMatch(value),
        hasControlCharacters: value.runes.any(
          (rune) =>
              rune < 0x20 ||
              rune == 0x7f ||
              rune == 0x200b ||
              (rune >= 0x202a && rune <= 0x202e) ||
              (rune >= 0x2066 && rune <= 0x2069),
        ),
        nestedUrlParameterNames: nestedNames,
      ),
      title: uri.host,
      normalizedValue: normalizeUrl(uri),
    );
  }

  int? _explicitPort(String value) {
    final authorityStart = value.indexOf('//');
    if (authorityStart < 0) return null;
    final authority = value
        .substring(authorityStart + 2)
        .split(RegExp(r'[/\\?#]'))
        .first
        .split('@')
        .last;
    final match = authority.startsWith('[')
        ? RegExp(r'^\[[^]]+\]:(\d+)$').firstMatch(authority)
        : RegExp(r':(\d+)$').firstMatch(authority);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  String _decodeRepeatedly(String value) {
    var current = value;
    for (var i = 0; i < 2; i++) {
      try {
        final decoded = Uri.decodeComponent(current);
        if (decoded == current) break;
        current = decoded;
      } on FormatException {
        break;
      }
    }
    return current;
  }
}
