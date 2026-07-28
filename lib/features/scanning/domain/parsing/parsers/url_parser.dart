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

  static const _supportedSchemes = {'http', 'https'};

  // Dart's Uri.parse does not reject a stray '%' not followed by two hex
  // digits — it silently re-escapes it (`%` becomes `%25`), which would
  // quietly rewrite what the user scanned. Checked explicitly instead so
  // malformed percent-encoding degrades to plain text rather than showing
  // a mangled URL.
  static final _malformedPercentEncoding = RegExp(r'%(?![0-9A-Fa-f]{2})');

  @override
  bool canParse(ScanCandidate candidate) {
    final lower = candidate.rawValue.trim().toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  @override
  ScanParseResult parse(ScanCandidate candidate) {
    final value = candidate.rawValue.trim();
    if (_malformedPercentEncoding.hasMatch(value)) {
      return const ScanParseFailed(
        MalformedUrlFailure('malformed percent-encoding'),
      );
    }

    final uri = Uri.tryParse(value);
    if (uri == null ||
        !_supportedSchemes.contains(uri.scheme.toLowerCase()) ||
        uri.host.isEmpty) {
      return const ScanParseFailed(MalformedUrlFailure());
    }

    final scheme = uri.scheme.toLowerCase();
    final isDefaultPort =
        (scheme == 'http' && uri.port == 80) ||
        (scheme == 'https' && uri.port == 443);

    return ScanParseSuccess(
      kind: ScanKind.url,
      payload: UrlPayload(
        rawUrl: value,
        uri: uri,
        scheme: scheme,
        host: uri.host,
        port: (uri.hasPort && !isDefaultPort) ? uri.port : null,
        path: uri.path,
        query: uri.query,
        fragment: uri.fragment,
        hasUserInfo: uri.userInfo.isNotEmpty,
      ),
      title: uri.host,
      normalizedValue: normalizeUrl(uri),
    );
  }
}
