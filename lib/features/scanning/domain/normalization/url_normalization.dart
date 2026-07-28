/// Builds [ParsedScan.normalizedValue] for a [UrlPayload].
///
/// Documented rule (see docs/engineering/normalization-and-identity.md):
/// lowercase the scheme and host (both case-insensitive per RFC 3986),
/// drop an explicit port that matches the scheme's default, and preserve
/// path/query/fragment exactly as parsed — no reordering, decoding, or
/// case changes, since those can carry meaning. Embedded user-info
/// (credentials) is deliberately dropped: it is not part of a URL's
/// "site identity" and Milestone 004's structural findings read
/// credential presence from [UrlPayload.hasUserInfo] directly, not from
/// this string.
String normalizeUrl(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  final host = uri.host.toLowerCase();
  final isDefaultPort =
      (scheme == 'http' && uri.port == 80) ||
      (scheme == 'https' && uri.port == 443);
  final portSuffix = (uri.hasPort && !isDefaultPort) ? ':${uri.port}' : '';

  final buffer = StringBuffer('$scheme://$host$portSuffix${uri.path}');
  if (uri.query.isNotEmpty) buffer.write('?${uri.query}');
  if (uri.fragment.isNotEmpty) buffer.write('#${uri.fragment}');
  return buffer.toString();
}
