import 'package:flutter/material.dart';

import '../../../../shared/fixtures/models/result_action_fixture.dart';
import '../../../../shared/fixtures/models/result_field_fixture.dart';
import '../../../../shared/fixtures/models/result_fixture.dart';
import '../../../../shared/fixtures/models/result_fixture_kind.dart';
import '../../domain/entities/parsed_scan.dart';
import '../../domain/entities/scan_action_descriptor.dart';
import '../../domain/entities/scan_payload.dart';
import '../../domain/enums/isbn_format.dart';
import '../../domain/enums/scan_action_type.dart';
import '../../domain/enums/scan_kind.dart';
import '../../domain/enums/wifi_security_type.dart';

/// Maps an authoritative [ParsedScan] onto the Milestone 002
/// [ResultFixture] view model, so a real parse result renders through the
/// unmodified [ScanResultView]/[ScanResultSheet] widget tree.
///
/// This is deliberately a one-way, presentation-only adapter — it holds
/// no state and makes no platform calls. Two mapping decisions are worth
/// calling out because they are not 1:1 with the domain:
///
/// - [ScanKind.isbn] renders through [ResultFixtureKind.product] (the
///   same card shape/icon as a generic product), with its own
///   [ResultFixture.typeLabel] ("Book (ISBN)") — Milestone 002 has no
///   distinct ISBN card, and adding one is out of this milestone's scope
///   ("avoid rewriting result widgets unnecessarily").
/// - [ResultFixture.security] is always null here. Milestone 003 does not
///   compute a structural risk assessment (that's Milestone 004); a real
///   [ScanKind.url] result therefore renders without the security panel
///   until that lands. [UrlPayload] already exposes every structural
///   field that assessment will need.
ResultFixture mapParsedScanToResultFixture(ParsedScan scan) {
  final actions = _resolveActions(scan.actions);

  return ResultFixture(
    id: 'scan-${scan.identity.kind.name}-${scan.identity.value}',
    kind: _mapKind(scan.kind),
    typeLabel: _typeLabel(scan.kind),
    title: scan.title,
    subtitle: scan.subtitle,
    fields: _mapFields(scan.payload),
    security: null,
    primaryAction: actions.primary,
    secondaryActions: actions.secondary,
    technicalDetails: scan.attributes.entries
        .map(
          (entry) => ResultFieldFixture(label: entry.key, value: entry.value),
        )
        .toList(growable: false),
    rawPayload: scan.rawValue,
  );
}

ResultFixtureKind _mapKind(ScanKind kind) => switch (kind) {
  ScanKind.url => ResultFixtureKind.trustedUrl,
  ScanKind.wifi => ResultFixtureKind.wifi,
  ScanKind.contact => ResultFixtureKind.contact,
  ScanKind.email => ResultFixtureKind.email,
  ScanKind.phone => ResultFixtureKind.phone,
  ScanKind.sms => ResultFixtureKind.sms,
  ScanKind.location => ResultFixtureKind.location,
  ScanKind.calendarEvent => ResultFixtureKind.calendarEvent,
  ScanKind.product => ResultFixtureKind.product,
  ScanKind.isbn => ResultFixtureKind.product,
  ScanKind.plainText => ResultFixtureKind.plainText,
  ScanKind.unknown => ResultFixtureKind.unsupported,
};

String _typeLabel(ScanKind kind) => switch (kind) {
  ScanKind.url => 'Website link',
  ScanKind.wifi => 'Wi-Fi network',
  ScanKind.contact => 'Contact card',
  ScanKind.email => 'Email address',
  ScanKind.phone => 'Phone number',
  ScanKind.sms => 'Text message',
  ScanKind.location => 'Location',
  ScanKind.calendarEvent => 'Calendar event',
  ScanKind.product => 'Product',
  ScanKind.isbn => 'Book (ISBN)',
  ScanKind.plainText => 'Plain text',
  ScanKind.unknown => 'Unsupported content',
};

List<ResultFieldFixture> _mapFields(ScanPayload payload) => switch (payload) {
  UrlPayload p => _urlFields(p),
  WifiPayload p => _wifiFields(p),
  ContactPayload p => _contactFields(p),
  ProductPayload p => _productFields(
    format: p.symbology.name.toUpperCase(),
    identifier: p.identifier,
    isCheckDigitValid: p.isCheckDigitValid,
  ),
  IsbnPayload p => _productFields(
    format: p.format == IsbnFormat.isbn10 ? 'ISBN-10' : 'ISBN-13',
    identifier: p.normalized,
    isCheckDigitValid: p.isValidCheckDigit,
  ),
  CalendarEventPayload p => _calendarFields(p),
  PhonePayload() => const [],
  EmailPayload p => [
    ResultFieldFixture(label: 'Subject', value: p.subject ?? 'Not provided'),
  ],
  SmsPayload p => [
    ResultFieldFixture(
      label: 'Message',
      value: p.body ?? 'No message',
      icon: Icons.sms_outlined,
    ),
  ],
  LocationPayload p => _locationFields(p),
  PlainTextPayload p => [ResultFieldFixture(label: 'Content', value: p.text)],
  UnknownPayload() => const [],
};

List<ResultFieldFixture> _urlFields(UrlPayload p) => [
  ResultFieldFixture(
    label: 'Destination',
    value: p.host ?? p.rawUrl,
    icon: Icons.public,
  ),
  ResultFieldFixture(
    label: 'Connection',
    value: p.scheme == 'https' ? 'HTTPS (encrypted)' : 'HTTP (not encrypted)',
    icon: p.scheme == 'https'
        ? Icons.lock_outline
        : Icons.no_encryption_outlined,
  ),
  if (p.path.isNotEmpty && p.path != '/')
    ResultFieldFixture(label: 'Path', value: p.path, icon: Icons.route),
];

List<ResultFieldFixture> _wifiFields(WifiPayload p) => [
  ResultFieldFixture(
    label: 'Security',
    value: _wifiSecurityLabel(p),
    icon: Icons.security_outlined,
  ),
  ResultFieldFixture(
    label: 'Password',
    value: p.hasPassword ? p.password! : 'None',
    icon: Icons.key_outlined,
    masked: p.hasPassword,
    monospace: true,
  ),
  ResultFieldFixture(
    label: 'Hidden network',
    value: p.isHidden ? 'Yes' : 'No',
    icon: Icons.visibility_off_outlined,
  ),
];

String _wifiSecurityLabel(WifiPayload p) => switch (p.securityType) {
  WifiSecurityType.open => 'Open (no password)',
  WifiSecurityType.wep => 'WEP',
  WifiSecurityType.wpa => 'WPA/WPA2',
  WifiSecurityType.unknown => p.securityRaw,
};

List<ResultFieldFixture> _contactFields(ContactPayload p) => [
  if (p.phones.isNotEmpty)
    ResultFieldFixture(
      label: 'Phone',
      value: p.phones.first,
      icon: Icons.call_outlined,
    ),
  if (p.emails.isNotEmpty)
    ResultFieldFixture(
      label: 'Email',
      value: p.emails.first,
      icon: Icons.mail_outline,
    ),
  if (p.organization != null)
    ResultFieldFixture(
      label: 'Organization',
      value: p.organization!,
      icon: Icons.apartment_outlined,
    ),
  if (p.websites.isNotEmpty)
    ResultFieldFixture(
      label: 'Website',
      value: p.websites.first,
      icon: Icons.public,
    ),
];

List<ResultFieldFixture> _productFields({
  required String format,
  required String identifier,
  required bool? isCheckDigitValid,
}) => [
  ResultFieldFixture(label: 'Format', value: format),
  ResultFieldFixture(label: 'Identifier', value: identifier, monospace: true),
  ResultFieldFixture(
    label: 'Check digit',
    value: switch (isCheckDigitValid) {
      true => 'Valid',
      false => 'Invalid',
      null => 'Not verified',
    },
    icon: isCheckDigitValid == true
        ? Icons.check_circle_outline
        : Icons.help_outline,
  ),
];

List<ResultFieldFixture> _calendarFields(CalendarEventPayload p) {
  final start = p.start;
  return [
    if (start != null)
      ResultFieldFixture(
        label: 'Date',
        value: _formatCalendarDate(start),
        icon: Icons.event_outlined,
      ),
    if (start != null && !p.isAllDay)
      ResultFieldFixture(
        label: 'Time',
        value: p.end == null
            ? _formatCalendarTime(start)
            : '${_formatCalendarTime(start)}–${_formatCalendarTime(p.end!)}',
        icon: Icons.schedule_outlined,
      ),
    if (p.location != null)
      ResultFieldFixture(
        label: 'Location',
        value: p.location!,
        icon: Icons.place_outlined,
      ),
    if (p.organizer != null)
      ResultFieldFixture(
        label: 'Organizer',
        value: p.organizer!,
        icon: Icons.person_outline,
      ),
  ];
}

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Anchoring in UTC here only extracts the day-of-week for a calendar
/// date, which is a property of the date alone — it does not assert
/// anything about the event's actual time zone (see
/// [CalendarDateTimeValue]'s doc comment).
String _formatCalendarDate(CalendarDateTimeValue value) {
  final weekday =
      _weekdayNames[DateTime.utc(value.year, value.month, value.day).weekday -
          1];
  return '$weekday, ${value.day} ${_monthNames[value.month - 1]} ${value.year}';
}

String _formatCalendarTime(CalendarDateTimeValue value) {
  final hour = (value.hour ?? 0).toString().padLeft(2, '0');
  final minute = (value.minute ?? 0).toString().padLeft(2, '0');
  final suffix = value.isUtc
      ? ' UTC'
      : (value.timeZoneId != null ? ' (${value.timeZoneId})' : '');
  return '$hour:$minute$suffix';
}

List<ResultFieldFixture> _locationFields(LocationPayload p) => [
  ResultFieldFixture(
    label: 'Coordinates',
    value: '${p.latitude}, ${p.longitude}',
    icon: Icons.my_location_outlined,
    monospace: true,
  ),
  if (p.query != null)
    ResultFieldFixture(
      label: 'Label',
      value: p.query!,
      icon: Icons.place_outlined,
    ),
];

({ResultActionFixture primary, List<ResultActionFixture> secondary})
_resolveActions(List<ScanActionDescriptor> descriptors) {
  if (descriptors.isEmpty) {
    throw StateError('A ParsedScan must have at least one action.');
  }
  final mapped = descriptors.map(_mapAction).toList(growable: false);
  final primaryIndex = descriptors.indexWhere((d) => d.isPrimary);
  final resolvedPrimaryIndex = primaryIndex == -1 ? 0 : primaryIndex;

  return (
    primary: mapped[resolvedPrimaryIndex],
    secondary: [
      for (var i = 0; i < mapped.length; i++)
        if (i != resolvedPrimaryIndex) mapped[i],
    ],
  );
}

ResultActionFixture _mapAction(ScanActionDescriptor descriptor) {
  final icon = _iconFor(descriptor.type);

  if (!descriptor.enabled) {
    return ResultActionFixture(
      label: descriptor.label,
      icon: icon,
      tier: ResultActionTier.disabled,
      semanticHint: descriptor.disabledReason ?? 'Not available yet.',
    );
  }

  if (descriptor.type == ScanActionType.copy) {
    return ResultActionFixture(
      label: descriptor.label,
      icon: icon,
      tier: ResultActionTier.demonstrable,
      copyValue: descriptor.copyValue ?? '',
    );
  }

  // share/save (and any future enabled-but-unintegrated type) render as a
  // preview: the tap is real, but the terminal effect is a snackbar until
  // share_plus/Drift are integrated — see AGENTS.md's excluded
  // dependencies.
  final previewMessage = switch (descriptor.type) {
    ScanActionType.save =>
      'Saving will be available once Library persistence is added.',
    _ => 'Sharing will be available once share actions are connected.',
  };
  return ResultActionFixture(
    label: descriptor.label,
    icon: icon,
    tier: ResultActionTier.previewOnly,
    previewMessage: previewMessage,
  );
}

IconData _iconFor(ScanActionType type) => switch (type) {
  ScanActionType.open => Icons.open_in_new,
  ScanActionType.call => Icons.call,
  ScanActionType.composeEmail => Icons.outgoing_mail,
  ScanActionType.composeSms => Icons.send_outlined,
  ScanActionType.openLocation => Icons.map_outlined,
  ScanActionType.addCalendarEvent => Icons.calendar_month_outlined,
  ScanActionType.addContact => Icons.person_add_alt,
  ScanActionType.openWifiSettings => Icons.settings_ethernet,
  ScanActionType.searchProduct => Icons.search,
  ScanActionType.copy => Icons.content_copy_outlined,
  ScanActionType.share => Icons.share_outlined,
  ScanActionType.save => Icons.bookmark_border,
  ScanActionType.addNote => Icons.note_add_outlined,
};
