import 'scan_parse_failure.dart';

/// A non-fatal issue attached to a successfully parsed [ParsedScan] —
/// either raised directly by a parser (e.g. an invalid ISBN check digit)
/// or produced by [ParserRegistry] when it downgrades a [ScanParseFailure]
/// into a fallback result. Never carries the raw scanned value.
class ScanParseWarning {
  const ScanParseWarning({required this.code, required this.message});

  factory ScanParseWarning.fromFailure(ScanParseFailure failure) {
    return ScanParseWarning(code: failure.code, message: failure.message);
  }

  final String code;
  final String message;
}
