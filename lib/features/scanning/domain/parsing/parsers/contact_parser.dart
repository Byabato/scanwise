import '../../entities/scan_candidate.dart';
import '../../entities/scan_payload.dart';
import '../../enums/scan_kind.dart';
import '../../failures/scan_parse_failure.dart';
import '../../failures/scan_parse_warning.dart';
import '../../normalization/escaping.dart';
import '../scan_parse_result.dart';
import '../scan_payload_parser.dart';

/// Parses a vCard 3.0/4.0 (`BEGIN:VCARD`…`END:VCARD`) contact.
///
/// Degrades safely at every level: an unrecognized or malformed property
/// line is skipped rather than aborting the whole parse, and a
/// structurally complete-but-empty vCard still succeeds (with a warning)
/// rather than failing. Only a missing `END:VCARD` — meaning the card
/// itself is truncated — is treated as a hard failure.
class ContactParser implements ScanPayloadParser {
  const ContactParser();

  @override
  bool canParse(ScanCandidate candidate) {
    final lines = unfoldLines(candidate.rawValue.trim());
    if (lines.isEmpty) return false;
    return lines.first.trim().toUpperCase() == 'BEGIN:VCARD';
  }

  @override
  ScanParseResult parse(ScanCandidate candidate) {
    final lines = unfoldLines(candidate.rawValue.trim());
    final hasEnd = lines.any(
      (line) => line.trim().toUpperCase() == 'END:VCARD',
    );
    if (!hasEnd) {
      return const ScanParseFailed(IncompleteVCardFailure('missing END:VCARD'));
    }

    String? fullName;
    String? givenName;
    String? familyName;
    String? organization;
    String? jobTitle;
    final phones = <String>[];
    final emails = <String>[];
    final websites = <String>[];
    final addresses = <String>[];
    String? note;
    var version = 'unknown';

    for (final rawLine in lines) {
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty) continue;
      final upper = trimmed.toUpperCase();
      if (upper == 'BEGIN:VCARD' || upper == 'END:VCARD') continue;

      final keyValue = splitKeyValue(trimmed);
      if (keyValue == null) continue;

      final propertyName = keyValue.$1.split(';').first.trim().toUpperCase();
      final rawValue = keyValue.$2;
      final value = unescapeVCardValue(rawValue);
      if (value.isEmpty) continue;

      switch (propertyName) {
        case 'VERSION':
          version = value;
        case 'FN':
          fullName = value;
        case 'N':
          final parts = splitUnescaped(
            rawValue,
            ';',
          ).map(unescapeVCardValue).toList();
          if (parts.isNotEmpty) familyName = _nullIfEmpty(parts[0]);
          if (parts.length > 1) givenName = _nullIfEmpty(parts[1]);
        case 'ORG':
          final parts = splitUnescaped(
            rawValue,
            ';',
          ).map(unescapeVCardValue).where((s) => s.isNotEmpty);
          organization = parts.isEmpty ? null : parts.join(', ');
        case 'TITLE':
          jobTitle = value;
        case 'TEL':
          phones.add(value);
        case 'EMAIL':
          emails.add(value);
        case 'URL':
          websites.add(value);
        case 'ADR':
          final parts = splitUnescaped(
            rawValue,
            ';',
          ).map(unescapeVCardValue).where((s) => s.isNotEmpty);
          if (parts.isNotEmpty) addresses.add(parts.join(', '));
        case 'NOTE':
          note = value;
      }
    }

    fullName ??= _nullIfEmpty('${givenName ?? ''} ${familyName ?? ''}'.trim());

    final warnings = <ScanParseWarning>[];
    if (fullName == null &&
        organization == null &&
        phones.isEmpty &&
        emails.isEmpty) {
      warnings.add(
        const ScanParseWarning(
          code: 'incomplete-vcard',
          message: 'This contact card had no readable fields.',
        ),
      );
    }

    final title = fullName ?? organization ?? 'Contact card';
    final subtitleParts = [
      jobTitle,
      organization,
    ].whereType<String>().where((s) => s.isNotEmpty);
    final subtitle = subtitleParts.isEmpty ? null : subtitleParts.join(', ');

    return ScanParseSuccess(
      kind: ScanKind.contact,
      payload: ContactPayload(
        vCardVersion: version,
        fullName: fullName,
        givenName: givenName,
        familyName: familyName,
        organization: organization,
        jobTitle: jobTitle,
        phones: phones,
        emails: emails,
        websites: websites,
        addresses: addresses,
        note: note,
      ),
      title: title,
      subtitle: subtitle,
      normalizedValue: title,
      warnings: warnings,
    );
  }
}

String? _nullIfEmpty(String value) => value.isEmpty ? null : value;
