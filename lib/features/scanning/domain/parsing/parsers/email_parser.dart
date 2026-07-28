import '../../entities/scan_candidate.dart';
import '../../entities/scan_payload.dart';
import '../../enums/scan_kind.dart';
import '../../failures/scan_parse_failure.dart';
import '../scan_parse_result.dart';
import '../scan_payload_parser.dart';

/// Parses a `mailto:` URI, including comma-separated recipients and the
/// `subject`/`body` query parameters.
class EmailParser implements ScanPayloadParser {
  const EmailParser();

  @override
  bool canParse(ScanCandidate candidate) {
    return candidate.rawValue.trim().toLowerCase().startsWith('mailto:');
  }

  @override
  ScanParseResult parse(ScanCandidate candidate) {
    final value = candidate.rawValue.trim();
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.toLowerCase() != 'mailto') {
      return const ScanParseFailed(
        UnsupportedStructuredPayloadFailure('malformed mailto uri'),
      );
    }

    final recipients = uri.path
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (recipients.isEmpty) {
      return const ScanParseFailed(
        UnsupportedStructuredPayloadFailure('mailto with no recipient'),
      );
    }

    final subject = uri.queryParameters['subject'];
    final body = uri.queryParameters['body'];

    return ScanParseSuccess(
      kind: ScanKind.email,
      payload: EmailPayload(
        recipients: recipients,
        subject: (subject == null || subject.isEmpty) ? null : subject,
        body: (body == null || body.isEmpty) ? null : body,
      ),
      title: recipients.first,
      subtitle: recipients.length > 1
          ? '+${recipients.length - 1} more recipient(s)'
          : null,
      normalizedValue: recipients.join(','),
    );
  }
}
