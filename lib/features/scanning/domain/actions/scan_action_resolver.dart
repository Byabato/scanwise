import '../entities/scan_action_descriptor.dart';
import '../entities/scan_payload.dart';
import '../enums/scan_action_type.dart';
import '../enums/scan_kind.dart';
import '../security/risk_level.dart';
import '../security/structural_assessment.dart';

/// Derives the context-aware [ScanActionDescriptor]s for a parsed result,
/// per docs/product/product-contract.md pillar 3 ("Context-Aware
/// Actions") and the per-kind action inventory in
/// docs/product/v1-scope.md.
///
/// Exactly one descriptor is marked [ScanActionDescriptor.isPrimary] per
/// call, matching the product contract's "one main action" principle.
/// `copy`/`share`/`save` are always [ScanActionDescriptor.enabled] — they
/// need no plugin this milestone excludes (copy is real via `Clipboard`;
/// share/save are legitimate action *types* even though their terminal
/// platform behavior isn't wired up yet, see
/// `parsed_scan_presentation_mapper.dart` for how that nuance maps to a
/// UI tier). Every other action type needs an integration explicitly
/// excluded from this milestone (see AGENTS.md) and is always disabled
/// with a reason.
List<ScanActionDescriptor> resolveScanActions({
  required ScanKind kind,
  required ScanPayload payload,
  StructuralAssessment? structuralAssessment,
}) {
  return switch (payload) {
    UrlPayload p => _urlActions(p, structuralAssessment),
    WifiPayload p => _wifiActions(p),
    ContactPayload p => _contactActions(p),
    ProductPayload p => _productOrIsbnActions(copyValue: p.identifier),
    IsbnPayload p => _productOrIsbnActions(copyValue: p.normalized),
    CalendarEventPayload p => _calendarActions(p),
    PhonePayload p => _phoneActions(p),
    EmailPayload p => _emailActions(p),
    SmsPayload p => _smsActions(p),
    LocationPayload p => _locationActions(p),
    PlainTextPayload p => _plainTextActions(p),
    UnknownPayload p => _unknownActions(p),
  };
}

const _openDisabledReason =
    'Opening links will be available once external actions are connected.';
const _callDisabledReason =
    'Placing calls will be available once phone integration is connected.';
const _composeEmailDisabledReason =
    'Composing email will be available once email integration is connected.';
const _composeSmsDisabledReason =
    'Sending messages will be available once messaging integration is '
    'connected.';
const _openLocationDisabledReason =
    'Opening maps will be available once external actions are connected.';
const _addCalendarDisabledReason =
    'Adding events to your calendar will be available once calendar '
    'integration is connected.';
const _addContactDisabledReason =
    'Adding to your device contacts will be available once contacts '
    'integration is connected.';
const _wifiSettingsDisabledReason =
    'Opening Wi-Fi settings will be available once settings integration is '
    'connected.';
const _searchProductDisabledReason =
    'Searching the web for this product will be available once external '
    'actions are connected.';

const _shareLabel = 'Share';
const _saveLabel = 'Save';

ScanActionDescriptor _share({
  String? label,
  bool requiresConfirmation = false,
}) {
  return ScanActionDescriptor(
    type: ScanActionType.share,
    label: label ?? _shareLabel,
    enabled: true,
    requiresConfirmation: requiresConfirmation,
  );
}

ScanActionDescriptor _save() {
  return const ScanActionDescriptor(
    type: ScanActionType.save,
    label: _saveLabel,
    enabled: true,
  );
}

List<ScanActionDescriptor> _urlActions(
  UrlPayload payload,
  StructuralAssessment? assessment,
) => [
  ScanActionDescriptor(
    type: ScanActionType.open,
    label: 'Open website',
    enabled: false,
    disabledReason: _openDisabledReason,
    requiresConfirmation:
        assessment == null ||
        assessment.riskLevel == RiskLevel.caution ||
        assessment.riskLevel == RiskLevel.high,
    isPrimary: true,
  ),
  ScanActionDescriptor(
    type: ScanActionType.copy,
    label: 'Copy link',
    enabled: true,
    copyValue: payload.rawUrl,
  ),
  _share(),
  _save(),
];

List<ScanActionDescriptor> _wifiActions(WifiPayload payload) => [
  ScanActionDescriptor(
    type: ScanActionType.copy,
    label: 'Copy password',
    enabled: payload.hasPassword,
    disabledReason: payload.hasPassword
        ? null
        : 'This network has no password.',
    copyValue: payload.password,
    isSensitive: payload.hasPassword,
    isPrimary: true,
  ),
  const ScanActionDescriptor(
    type: ScanActionType.openWifiSettings,
    label: 'Wi-Fi settings',
    enabled: false,
    disabledReason: _wifiSettingsDisabledReason,
  ),
  _share(label: 'Share details', requiresConfirmation: payload.hasPassword),
  ScanActionDescriptor(
    type: ScanActionType.save,
    label: 'Save to Library',
    enabled: true,
  ),
];

List<ScanActionDescriptor> _contactActions(ContactPayload payload) {
  final details = [
    payload.fullName,
    payload.organization,
    if (payload.phones.isNotEmpty) payload.phones.first,
    if (payload.emails.isNotEmpty) payload.emails.first,
  ].whereType<String>().join('\n');

  return [
    const ScanActionDescriptor(
      type: ScanActionType.addContact,
      label: 'Add contact',
      enabled: false,
      disabledReason: _addContactDisabledReason,
      isPrimary: true,
    ),
    ScanActionDescriptor(
      type: ScanActionType.copy,
      label: 'Copy details',
      enabled: true,
      copyValue: details,
    ),
    _share(label: 'Share contact'),
    _save(),
  ];
}

List<ScanActionDescriptor> _productOrIsbnActions({required String copyValue}) =>
    [
      const ScanActionDescriptor(
        type: ScanActionType.searchProduct,
        label: 'Search product',
        enabled: false,
        disabledReason: _searchProductDisabledReason,
        isPrimary: true,
      ),
      ScanActionDescriptor(
        type: ScanActionType.copy,
        label: 'Copy identifier',
        enabled: true,
        copyValue: copyValue,
      ),
      _share(),
      _save(),
    ];

List<ScanActionDescriptor> _calendarActions(CalendarEventPayload payload) {
  final details = [
    payload.title,
    payload.location,
  ].whereType<String>().join('\n');

  return [
    const ScanActionDescriptor(
      type: ScanActionType.addCalendarEvent,
      label: 'Add to calendar',
      enabled: false,
      disabledReason: _addCalendarDisabledReason,
      isPrimary: true,
    ),
    ScanActionDescriptor(
      type: ScanActionType.copy,
      label: 'Copy details',
      enabled: true,
      copyValue: details,
    ),
    _share(),
    _save(),
  ];
}

List<ScanActionDescriptor> _phoneActions(PhonePayload payload) => [
  const ScanActionDescriptor(
    type: ScanActionType.call,
    label: 'Call',
    enabled: false,
    disabledReason: _callDisabledReason,
    isPrimary: true,
  ),
  ScanActionDescriptor(
    type: ScanActionType.copy,
    label: 'Copy number',
    enabled: true,
    copyValue: payload.normalizedNumber,
  ),
  const ScanActionDescriptor(
    type: ScanActionType.addContact,
    label: 'Add to contacts',
    enabled: false,
    disabledReason: _addContactDisabledReason,
  ),
  _save(),
];

List<ScanActionDescriptor> _emailActions(EmailPayload payload) => [
  const ScanActionDescriptor(
    type: ScanActionType.composeEmail,
    label: 'Compose email',
    enabled: false,
    disabledReason: _composeEmailDisabledReason,
    isPrimary: true,
  ),
  ScanActionDescriptor(
    type: ScanActionType.copy,
    label: 'Copy address',
    enabled: true,
    copyValue: payload.recipients.isEmpty ? '' : payload.recipients.first,
  ),
  const ScanActionDescriptor(
    type: ScanActionType.addContact,
    label: 'Add to contacts',
    enabled: false,
    disabledReason: _addContactDisabledReason,
  ),
  _save(),
];

List<ScanActionDescriptor> _smsActions(SmsPayload payload) => [
  const ScanActionDescriptor(
    type: ScanActionType.composeSms,
    label: 'Send message',
    enabled: false,
    disabledReason: _composeSmsDisabledReason,
    isPrimary: true,
  ),
  ScanActionDescriptor(
    type: ScanActionType.copy,
    label: 'Copy number',
    enabled: true,
    copyValue: payload.recipient,
  ),
  const ScanActionDescriptor(
    type: ScanActionType.call,
    label: 'Call',
    enabled: false,
    disabledReason: _callDisabledReason,
  ),
  _save(),
];

List<ScanActionDescriptor> _locationActions(LocationPayload payload) => [
  const ScanActionDescriptor(
    type: ScanActionType.openLocation,
    label: 'Open map',
    enabled: false,
    disabledReason: _openLocationDisabledReason,
    isPrimary: true,
  ),
  ScanActionDescriptor(
    type: ScanActionType.copy,
    label: 'Copy coordinates',
    enabled: true,
    copyValue: '${payload.latitude}, ${payload.longitude}',
  ),
  _share(label: 'Share location'),
  _save(),
];

List<ScanActionDescriptor> _plainTextActions(PlainTextPayload payload) => [
  ScanActionDescriptor(
    type: ScanActionType.copy,
    label: 'Copy text',
    enabled: true,
    copyValue: payload.text,
    isPrimary: true,
  ),
  _share(),
  _save(),
];

List<ScanActionDescriptor> _unknownActions(UnknownPayload payload) => [
  ScanActionDescriptor(
    type: ScanActionType.copy,
    label: 'Copy raw value',
    enabled: true,
    copyValue: payload.rawValue,
    isPrimary: true,
  ),
  _share(),
  _save(),
];
