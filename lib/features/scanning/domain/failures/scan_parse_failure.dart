/// Typed reasons a parser could not produce structured content.
///
/// Only [EmptyContentFailure] and [OversizedContentFailure] ever reach a
/// caller as a hard [ScanParseOutcome] failure — every other variant is
/// produced by an individual [ScanPayloadParser] and downgraded by
/// [ParserRegistry] into a plain-text or unknown [ParsedScan] carrying a
/// [ScanParseWarning] instead, per the fallback policy documented in
/// docs/engineering/parsing-strategy.md. Messages never embed the raw
/// scanned value.
sealed class ScanParseFailure {
  const ScanParseFailure();

  /// A short, stable code for tests/telemetry (never logged with raw
  /// content attached).
  String get code;

  /// A human-readable, non-sensitive explanation.
  String get message;
}

final class EmptyContentFailure extends ScanParseFailure {
  const EmptyContentFailure();

  @override
  String get code => 'empty-content';

  @override
  String get message => 'The scanned content was empty.';
}

final class OversizedContentFailure extends ScanParseFailure {
  const OversizedContentFailure({
    required this.length,
    required this.maxLength,
  });

  final int length;
  final int maxLength;

  @override
  String get code => 'oversized-content';

  @override
  String get message =>
      'The scanned content was too large to process safely '
      '($length characters, limit $maxLength).';
}

final class MalformedUrlFailure extends ScanParseFailure {
  const MalformedUrlFailure([this.reason]);

  final String? reason;

  @override
  String get code => 'malformed-url';

  @override
  String get message => 'This looked like a web address but could not be read.';
}

final class MalformedWifiFailure extends ScanParseFailure {
  const MalformedWifiFailure([this.reason]);

  final String? reason;

  @override
  String get code => 'malformed-wifi';

  @override
  String get message => 'This looked like a Wi-Fi code but could not be read.';
}

final class IncompleteVCardFailure extends ScanParseFailure {
  const IncompleteVCardFailure([this.reason]);

  final String? reason;

  @override
  String get code => 'incomplete-vcard';

  @override
  String get message =>
      'This looked like a contact card but appeared incomplete.';
}

final class InvalidCoordinatesFailure extends ScanParseFailure {
  const InvalidCoordinatesFailure([this.reason]);

  final String? reason;

  @override
  String get code => 'invalid-coordinates';

  @override
  String get message =>
      'This looked like a location but its coordinates were invalid.';
}

final class MalformedCalendarEventFailure extends ScanParseFailure {
  const MalformedCalendarEventFailure([this.reason]);

  final String? reason;

  @override
  String get code => 'malformed-calendar-event';

  @override
  String get message =>
      'This looked like a calendar event but could not be read.';
}

final class UnsupportedEncodingFailure extends ScanParseFailure {
  const UnsupportedEncodingFailure([this.reason]);

  final String? reason;

  @override
  String get code => 'unsupported-encoding';

  @override
  String get message => 'This content could not be read as text.';
}

final class UnsupportedStructuredPayloadFailure extends ScanParseFailure {
  const UnsupportedStructuredPayloadFailure([this.reason]);

  final String? reason;

  @override
  String get code => 'unsupported-structured-payload';

  @override
  String get message =>
      'This content matched a known format but could not be interpreted.';
}
