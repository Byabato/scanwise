import '../entities/parsed_scan.dart';
import '../failures/scan_parse_failure.dart';

/// The result of running [ParserRegistry.parse] on a candidate.
///
/// Only the two structural gate failures (empty, oversized content) ever
/// produce [ScanParseOutcomeFailure] — every other malformed-input case
/// degrades to a [ScanParseOutcomeSuccess] carrying a warning, per
/// docs/engineering/parsing-strategy.md's fallback policy. This keeps the
/// product promise that an accepted scan (one that reached the parser at
/// all) always gets a result to look at.
sealed class ScanParseOutcome {
  const ScanParseOutcome();

  const factory ScanParseOutcome.success(ParsedScan scan) =
      ScanParseOutcomeSuccess;

  const factory ScanParseOutcome.failure(ScanParseFailure failure) =
      ScanParseOutcomeFailure;
}

final class ScanParseOutcomeSuccess extends ScanParseOutcome {
  const ScanParseOutcomeSuccess(this.scan);

  final ParsedScan scan;
}

final class ScanParseOutcomeFailure extends ScanParseOutcome {
  const ScanParseOutcomeFailure(this.failure);

  final ScanParseFailure failure;
}
