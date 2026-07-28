/// Shared backslash-escape handling for the `WIFI:` QR payload and vCard
/// property values — both formats escape a small set of delimiter
/// characters with a leading backslash, and both need to split on an
/// unescaped delimiter without breaking on an escaped one.
library;

/// Splits [input] on unescaped occurrences of [delimiter] — a `\`
/// immediately before [delimiter] (or any character) protects it from
/// being treated as a split point. Escape sequences are left intact in
/// the returned parts; call [unescapeWifiValue]/[unescapeVCardValue]
/// afterwards.
List<String> splitUnescaped(String input, String delimiter) {
  final parts = <String>[];
  final buffer = StringBuffer();
  var i = 0;
  while (i < input.length) {
    final char = input[i];
    if (char == r'\' && i + 1 < input.length) {
      buffer.write(char);
      buffer.write(input[i + 1]);
      i += 2;
      continue;
    }
    if (char == delimiter) {
      parts.add(buffer.toString());
      buffer.clear();
      i += 1;
      continue;
    }
    buffer.write(char);
    i += 1;
  }
  parts.add(buffer.toString());
  return parts;
}

/// Splits [field] into a key and value at the first unescaped `:`, or
/// returns null if there is none — used for `WIFI:` and vCard field
/// parsing, both of which allow an escaped colon inside the value.
(String key, String value)? splitKeyValue(String field) {
  final segments = splitUnescaped(field, ':');
  if (segments.length < 2) return null;
  return (segments.first, segments.skip(1).join(':'));
}

String _unescape(
  String input,
  Set<String> escapableChars, {
  bool escapeNewline = false,
}) {
  final buffer = StringBuffer();
  var i = 0;
  while (i < input.length) {
    final char = input[i];
    if (char == r'\' && i + 1 < input.length) {
      final next = input[i + 1];
      if (escapeNewline && (next == 'n' || next == 'N')) {
        buffer.write('\n');
        i += 2;
        continue;
      }
      if (escapableChars.contains(next)) {
        buffer.write(next);
        i += 2;
        continue;
      }
    }
    buffer.write(char);
    i += 1;
  }
  return buffer.toString();
}

/// Unescapes `\\`, `\;`, `\,`, `\:` and `\"` per the `WIFI:` QR payload
/// convention.
String unescapeWifiValue(String input) =>
    _unescape(input, const {r'\', ';', ',', ':', '"'});

/// Unescapes `\\`, `\;`, `\,` and `\n`/`\N` per RFC 6350 (vCard) value
/// escaping.
String unescapeVCardValue(String input) =>
    _unescape(input, const {r'\', ';', ','}, escapeNewline: true);

/// Unfolds RFC 6350 (vCard) / RFC 5545 (iCalendar) line folding: a
/// continuation line starts with a single space or tab, which is removed
/// as the line is joined onto the previous logical line. Also normalizes
/// `\r\n`/`\r` line endings to `\n` first.
List<String> unfoldLines(String raw) {
  final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final rawLines = normalized.split('\n');
  final unfolded = <String>[];
  for (final line in rawLines) {
    if ((line.startsWith(' ') || line.startsWith('\t')) &&
        unfolded.isNotEmpty) {
      unfolded[unfolded.length - 1] += line.substring(1);
    } else {
      unfolded.add(line);
    }
  }
  return unfolded;
}
