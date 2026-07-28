import '../../entities/scan_candidate.dart';
import '../../entities/scan_payload.dart';
import '../../enums/scan_kind.dart';
import '../../failures/scan_parse_failure.dart';
import '../../failures/scan_parse_warning.dart';
import '../../normalization/escaping.dart';
import '../scan_parse_result.dart';
import '../scan_payload_parser.dart';

/// Parses an iCalendar `VEVENT` block (standalone or inside a
/// `VCALENDAR`).
///
/// `DTSTART`/`DTEND` are kept as their literal date/time components (see
/// [CalendarDateTimeValue]) rather than converted to a concrete
/// [DateTime] — a value with no `Z` suffix or `TZID` is a *floating*
/// local time with no defined zone, and silently assuming the device's
/// zone would misrepresent it. A missing or unparsable `DTSTART` is
/// treated as malformed, since an event with no start isn't
/// meaningfully usable; a missing `DTEND` degrades safely (a warning,
/// not a failure).
class CalendarParser implements ScanPayloadParser {
  const CalendarParser();

  @override
  bool canParse(ScanCandidate candidate) {
    return candidate.rawValue.toUpperCase().contains('BEGIN:VEVENT');
  }

  @override
  ScanParseResult parse(ScanCandidate candidate) {
    final lines = unfoldLines(candidate.rawValue.trim());
    final beginIndex = lines.indexWhere(
      (line) => line.trim().toUpperCase() == 'BEGIN:VEVENT',
    );
    final endIndex = lines.indexWhere(
      (line) => line.trim().toUpperCase() == 'END:VEVENT',
    );
    if (beginIndex == -1 || endIndex == -1 || endIndex <= beginIndex) {
      return const ScanParseFailed(
        MalformedCalendarEventFailure('missing BEGIN/END:VEVENT'),
      );
    }

    String? title;
    String? description;
    String? location;
    String? organizer;
    CalendarDateTimeValue? start;
    CalendarDateTimeValue? end;

    for (final rawLine in lines.sublist(beginIndex + 1, endIndex)) {
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty) continue;

      final colonIndex = trimmed.indexOf(':');
      if (colonIndex == -1) continue;
      final propertyPart = trimmed.substring(0, colonIndex);
      final value = unescapeVCardValue(trimmed.substring(colonIndex + 1));
      if (value.isEmpty) continue;

      final propertySegments = propertyPart.split(';');
      final propertyName = propertySegments.first.toUpperCase();
      final params = <String, String>{};
      for (final segment in propertySegments.skip(1)) {
        final equalsIndex = segment.indexOf('=');
        if (equalsIndex == -1) continue;
        params[segment.substring(0, equalsIndex).toUpperCase()] = segment
            .substring(equalsIndex + 1);
      }

      switch (propertyName) {
        case 'SUMMARY':
          title = value;
        case 'DESCRIPTION':
          description = value;
        case 'LOCATION':
          location = value;
        case 'ORGANIZER':
          organizer = value.toLowerCase().startsWith('mailto:')
              ? value.substring('mailto:'.length)
              : value;
        case 'DTSTART':
          start = _parseDateTime(value, params);
        case 'DTEND':
          end = _parseDateTime(value, params);
      }
    }

    if (start == null) {
      return const ScanParseFailed(
        MalformedCalendarEventFailure('missing or unreadable DTSTART'),
      );
    }

    final warnings = <ScanParseWarning>[];
    if (end == null && !start.isDateOnly) {
      warnings.add(
        const ScanParseWarning(
          code: 'calendar-missing-end',
          message: 'This event has no listed end time.',
        ),
      );
    }

    final resolvedTitle = title ?? 'Calendar event';
    return ScanParseSuccess(
      kind: ScanKind.calendarEvent,
      payload: CalendarEventPayload(
        title: title,
        description: description,
        location: location,
        organizer: organizer,
        start: start,
        end: end,
        isAllDay: start.isDateOnly,
      ),
      title: resolvedTitle,
      subtitle: location,
      normalizedValue: '$resolvedTitle|${_dateTimeKey(start)}',
      warnings: warnings,
    );
  }

  CalendarDateTimeValue? _parseDateTime(
    String value,
    Map<String, String> params,
  ) {
    final isUtc = value.endsWith('Z');
    final core = isUtc ? value.substring(0, value.length - 1) : value;
    final isDateOnly = params['VALUE'] == 'DATE' || !core.contains('T');

    if (isDateOnly) {
      if (core.length < 8) return null;
      final year = int.tryParse(core.substring(0, 4));
      final month = int.tryParse(core.substring(4, 6));
      final day = int.tryParse(core.substring(6, 8));
      if (year == null || month == null || day == null) return null;
      return CalendarDateTimeValue(
        year: year,
        month: month,
        day: day,
        isUtc: false,
        timeZoneId: params['TZID'],
      );
    }

    final parts = core.split('T');
    if (parts.length != 2 || parts[0].length < 8 || parts[1].length < 6) {
      return null;
    }
    final datePart = parts[0];
    final timePart = parts[1];
    final year = int.tryParse(datePart.substring(0, 4));
    final month = int.tryParse(datePart.substring(4, 6));
    final day = int.tryParse(datePart.substring(6, 8));
    final hour = int.tryParse(timePart.substring(0, 2));
    final minute = int.tryParse(timePart.substring(2, 4));
    final second = int.tryParse(timePart.substring(4, 6));
    if (year == null ||
        month == null ||
        day == null ||
        hour == null ||
        minute == null ||
        second == null) {
      return null;
    }

    return CalendarDateTimeValue(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      isUtc: isUtc,
      timeZoneId: isUtc ? null : params['TZID'],
    );
  }

  String _dateTimeKey(CalendarDateTimeValue value) {
    final date =
        '${value.year.toString().padLeft(4, '0')}'
        '${value.month.toString().padLeft(2, '0')}'
        '${value.day.toString().padLeft(2, '0')}';
    if (value.isDateOnly) return date;
    final time =
        '${value.hour!.toString().padLeft(2, '0')}'
        '${value.minute!.toString().padLeft(2, '0')}'
        '${value.second!.toString().padLeft(2, '0')}';
    return '$date$time${value.isUtc ? 'Z' : ''}';
  }
}
