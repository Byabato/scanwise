import 'package:flutter/material.dart';

import '../models/result_action_fixture.dart';
import '../models/result_field_fixture.dart';
import '../models/result_fixture.dart';
import '../models/result_fixture_kind.dart';
import '../models/security_assessment_fixture.dart';

/// Temporary fixture catalog for Milestone 002 static UI. Not an
/// authoritative content source — Milestone 003 replaces every entry here
/// with parsed, real scan output.
///
/// One [ResultFixture] per `ResultFixtureKind`, written to mirror the
/// worked examples in docs/product/product-contract.md and the Stitch
/// references under docs/design/references, while staying within
/// docs/product/non-goals.md (no invented product data, no certainty claims
/// about URL safety).

const trustedUrlResultFixture = ResultFixture(
  id: 'result-trusted-url',
  kind: ResultFixtureKind.trustedUrl,
  typeLabel: 'Website link',
  title: 'University of Dar es Salaam',
  subtitle: 'udsm.ac.tz',
  fields: [
    ResultFieldFixture(
      label: 'Destination',
      value: 'udsm.ac.tz',
      icon: Icons.public,
    ),
    ResultFieldFixture(
      label: 'Connection',
      value: 'HTTPS (encrypted)',
      icon: Icons.lock_outline,
    ),
    ResultFieldFixture(label: 'Path', value: '/account', icon: Icons.route),
  ],
  security: SecurityAssessmentFixture(
    severity: ResultRiskLevel.none,
    headline: 'No obvious structural warning detected',
    explanation:
        'Review the destination before opening. ScanWise cannot confirm '
        'the current reputation of this site while offline.',
    findings: [
      SecurityFindingFixture(
        code: 'recognizable-domain',
        title: 'Recognizable domain structure',
        explanation:
            'The organization name appears directly in the main domain.',
      ),
    ],
  ),
  primaryAction: ResultActionFixture(
    label: 'Open website',
    icon: Icons.open_in_new,
    tier: ResultActionTier.disabled,
    semanticHint:
        'Opening links will be available once external actions are '
        'connected.',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Copy link',
      icon: Icons.content_copy_outlined,
      tier: ResultActionTier.demonstrable,
      copyValue: 'https://udsm.ac.tz/account?ref=poster-2026',
    ),
    ResultActionFixture(
      label: 'Share',
      icon: Icons.share_outlined,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Sharing will be available once share actions are connected.',
    ),
    ResultActionFixture(
      label: 'Save',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [
    ResultFieldFixture(label: 'Symbology', value: 'QR Code'),
    ResultFieldFixture(label: 'Scan source', value: 'Camera'),
    ResultFieldFixture(label: 'Parameters detected', value: '1'),
  ],
  rawPayload: 'https://udsm.ac.tz/account?ref=poster-2026',
);

const suspiciousUrlResultFixture = ResultFixture(
  id: 'result-suspicious-url',
  kind: ResultFixtureKind.suspiciousUrl,
  typeLabel: 'Website link',
  title: 'verify-account-example.net',
  subtitle: 'Detected destination',
  fields: [
    ResultFieldFixture(
      label: 'Connection',
      value: 'HTTP (not encrypted)',
      icon: Icons.no_encryption_outlined,
    ),
  ],
  security: SecurityAssessmentFixture(
    severity: ResultRiskLevel.caution,
    headline: 'This link looks suspicious',
    explanation: 'We found some things you should check before continuing.',
    findings: [
      SecurityFindingFixture(
        code: 'organization-in-subdomain',
        title: 'Organization name in a subdomain',
        explanation:
            'The organization name appears in a subdomain, not the main '
            'domain. The actual registered destination appears to be '
            'verify-account-example.net.',
      ),
      SecurityFindingFixture(
        code: 'insecure-http',
        title: 'Insecure connection',
        explanation:
            'This site lacks encryption. Any information you enter could '
            'be visible to others on the network.',
      ),
    ],
  ),
  primaryAction: ResultActionFixture(
    label: 'Open anyway',
    icon: Icons.open_in_new,
    tier: ResultActionTier.disabled,
    semanticHint:
        'Opening links will be available once external actions are '
        'connected, and destinations like this will still require '
        'confirmation.',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Copy destination',
      icon: Icons.content_copy_outlined,
      tier: ResultActionTier.demonstrable,
      copyValue: 'verify-account-example.net',
    ),
    ResultActionFixture(
      label: 'Share for verification',
      icon: Icons.share_outlined,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Sharing will be available once share actions are connected.',
    ),
    ResultActionFixture(
      label: 'Save',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [
    ResultFieldFixture(label: 'Symbology', value: 'QR Code'),
    ResultFieldFixture(label: 'Scan source', value: 'Camera'),
    ResultFieldFixture(
      label: 'Original host',
      value: 'udsm-login.verify-account-example.net',
      monospace: true,
    ),
    ResultFieldFixture(
      label: 'Full address',
      value:
          'http://udsm-login.verify-account-example.net/secure/verify'
          '?acct=2394',
      monospace: true,
    ),
  ],
  rawPayload:
      'http://udsm-login.verify-account-example.net/secure/verify?acct=2394',
);

const wifiResultFixture = ResultFixture(
  id: 'result-wifi',
  kind: ResultFixtureKind.wifi,
  typeLabel: 'Wi-Fi network',
  title: 'NEBO Guest',
  fields: [
    ResultFieldFixture(
      label: 'Security',
      value: 'WPA2',
      icon: Icons.security_outlined,
    ),
    ResultFieldFixture(
      label: 'Password',
      value: 'nebo_guest_2024',
      icon: Icons.key_outlined,
      masked: true,
      monospace: true,
    ),
    ResultFieldFixture(
      label: 'Hidden network',
      value: 'No',
      icon: Icons.visibility_off_outlined,
    ),
  ],
  primaryAction: ResultActionFixture(
    label: 'Copy password',
    icon: Icons.content_copy_outlined,
    tier: ResultActionTier.demonstrable,
    copyValue: 'nebo_guest_2024',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Wi-Fi settings',
      icon: Icons.settings_ethernet,
      tier: ResultActionTier.disabled,
      semanticHint:
          'Opening Wi-Fi settings will be available once settings '
          'integration is connected.',
    ),
    ResultActionFixture(
      label: 'Share details',
      icon: Icons.share_outlined,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Sharing will be available once share actions are connected.',
    ),
    ResultActionFixture(
      label: 'Save to Library',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [
    ResultFieldFixture(label: 'Symbology', value: 'QR Code'),
    ResultFieldFixture(label: 'Scan source', value: 'Camera'),
  ],
  rawPayload: 'WIFI:T:WPA;S:NEBO Guest;P:nebo_guest_2024;H:false;;',
);

const contactResultFixture = ResultFixture(
  id: 'result-contact',
  kind: ResultFixtureKind.contact,
  typeLabel: 'Contact card',
  title: 'Sarah Jenkins',
  subtitle: 'Senior Product Manager, TechConf',
  fields: [
    ResultFieldFixture(
      label: 'Phone',
      value: '+1 415 555 0142',
      icon: Icons.call_outlined,
    ),
    ResultFieldFixture(
      label: 'Email',
      value: 'sarah.jenkins@techconf.example',
      icon: Icons.mail_outline,
    ),
    ResultFieldFixture(
      label: 'Organization',
      value: 'TechConf',
      icon: Icons.apartment_outlined,
    ),
    ResultFieldFixture(
      label: 'Website',
      value: 'techconf.example',
      icon: Icons.public,
    ),
  ],
  primaryAction: ResultActionFixture(
    label: 'Add contact',
    icon: Icons.person_add_alt,
    tier: ResultActionTier.disabled,
    semanticHint:
        'Adding to your device contacts will be available once contacts '
        'integration is connected.',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Copy details',
      icon: Icons.content_copy_outlined,
      tier: ResultActionTier.demonstrable,
      copyValue:
          'Sarah Jenkins\nTechConf\n+1 415 555 0142\n'
          'sarah.jenkins@techconf.example',
    ),
    ResultActionFixture(
      label: 'Share contact',
      icon: Icons.share_outlined,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Sharing will be available once share actions are connected.',
    ),
    ResultActionFixture(
      label: 'Save',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [
    ResultFieldFixture(label: 'Symbology', value: 'QR Code'),
    ResultFieldFixture(label: 'Format', value: 'vCard 3.0'),
  ],
  rawPayload:
      'BEGIN:VCARD\nVERSION:3.0\nN:Jenkins;Sarah;;;\nORG:TechConf\n'
      'TEL:+14155550142\nEMAIL:sarah.jenkins@techconf.example\n'
      'URL:https://techconf.example\nEND:VCARD',
);

const productResultFixture = ResultFixture(
  id: 'result-product',
  kind: ResultFixtureKind.product,
  typeLabel: 'Product',
  title: 'Product barcode',
  subtitle: "Product details aren't available offline.",
  fields: [
    ResultFieldFixture(label: 'Format', value: 'EAN-13'),
    ResultFieldFixture(
      label: 'Identifier',
      value: '4006381333931',
      monospace: true,
    ),
    ResultFieldFixture(
      label: 'Check digit',
      value: 'Valid',
      icon: Icons.check_circle_outline,
    ),
  ],
  primaryAction: ResultActionFixture(
    label: 'Search product',
    icon: Icons.search,
    tier: ResultActionTier.disabled,
    semanticHint:
        'Searching the web for this product will be available once '
        'external actions are connected.',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Copy identifier',
      icon: Icons.content_copy_outlined,
      tier: ResultActionTier.demonstrable,
      copyValue: '4006381333931',
    ),
    ResultActionFixture(
      label: 'Share',
      icon: Icons.share_outlined,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Sharing will be available once share actions are connected.',
    ),
    ResultActionFixture(
      label: 'Save',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [ResultFieldFixture(label: 'Scan source', value: 'Camera')],
  rawPayload: '4006381333931',
);

const calendarEventResultFixture = ResultFixture(
  id: 'result-calendar-event',
  kind: ResultFixtureKind.calendarEvent,
  typeLabel: 'Calendar event',
  title: 'ScanWise Product Review',
  fields: [
    ResultFieldFixture(
      label: 'Date',
      value: 'Fri, 14 Aug 2026',
      icon: Icons.event_outlined,
    ),
    ResultFieldFixture(
      label: 'Time',
      value: '10:00–11:00 EAT',
      icon: Icons.schedule_outlined,
    ),
    ResultFieldFixture(
      label: 'Location',
      value: 'Conference Room B',
      icon: Icons.place_outlined,
    ),
    ResultFieldFixture(
      label: 'Organizer',
      value: 'kelvin@scanwise.example',
      icon: Icons.person_outline,
    ),
  ],
  primaryAction: ResultActionFixture(
    label: 'Add to calendar',
    icon: Icons.calendar_month_outlined,
    tier: ResultActionTier.disabled,
    semanticHint:
        'Adding events to your calendar will be available once calendar '
        'integration is connected.',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Copy details',
      icon: Icons.content_copy_outlined,
      tier: ResultActionTier.demonstrable,
      copyValue:
          'ScanWise Product Review\nFri, 14 Aug 2026, 10:00–11:00 EAT\n'
          'Conference Room B',
    ),
    ResultActionFixture(
      label: 'Share',
      icon: Icons.share_outlined,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Sharing will be available once share actions are connected.',
    ),
    ResultActionFixture(
      label: 'Save',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [
    ResultFieldFixture(label: 'Symbology', value: 'QR Code'),
    ResultFieldFixture(label: 'Format', value: 'iCalendar (VEVENT)'),
  ],
  rawPayload:
      'BEGIN:VEVENT\nSUMMARY:ScanWise Product Review\n'
      'DTSTART:20260814T100000\nDTEND:20260814T110000\n'
      'LOCATION:Conference Room B\nORGANIZER:mailto:kelvin@scanwise.example\n'
      'END:VEVENT',
);

const phoneResultFixture = ResultFixture(
  id: 'result-phone',
  kind: ResultFixtureKind.phone,
  typeLabel: 'Phone number',
  title: '+255 22 241 0500',
  primaryAction: ResultActionFixture(
    label: 'Call',
    icon: Icons.call,
    tier: ResultActionTier.disabled,
    semanticHint:
        'Placing calls will be available once phone integration is '
        'connected.',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Copy number',
      icon: Icons.content_copy_outlined,
      tier: ResultActionTier.demonstrable,
      copyValue: '+255222410500',
    ),
    ResultActionFixture(
      label: 'Add to contacts',
      icon: Icons.person_add_alt,
      tier: ResultActionTier.disabled,
      semanticHint:
          'Adding to your device contacts will be available once contacts '
          'integration is connected.',
    ),
    ResultActionFixture(
      label: 'Save',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [
    ResultFieldFixture(label: 'Symbology', value: 'QR Code'),
    ResultFieldFixture(label: 'Scheme', value: 'tel:', monospace: true),
  ],
  rawPayload: 'tel:+255222410500',
);

const emailResultFixture = ResultFixture(
  id: 'result-email',
  kind: ResultFixtureKind.email,
  typeLabel: 'Email address',
  title: 'admissions@udsm.ac.tz',
  fields: [ResultFieldFixture(label: 'Subject', value: 'Not provided')],
  primaryAction: ResultActionFixture(
    label: 'Compose email',
    icon: Icons.outgoing_mail,
    tier: ResultActionTier.disabled,
    semanticHint:
        'Composing email will be available once email integration is '
        'connected.',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Copy address',
      icon: Icons.content_copy_outlined,
      tier: ResultActionTier.demonstrable,
      copyValue: 'admissions@udsm.ac.tz',
    ),
    ResultActionFixture(
      label: 'Add to contacts',
      icon: Icons.person_add_alt,
      tier: ResultActionTier.disabled,
      semanticHint:
          'Adding to your device contacts will be available once contacts '
          'integration is connected.',
    ),
    ResultActionFixture(
      label: 'Save',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [
    ResultFieldFixture(label: 'Symbology', value: 'QR Code'),
    ResultFieldFixture(label: 'Scheme', value: 'mailto:', monospace: true),
  ],
  rawPayload: 'mailto:admissions@udsm.ac.tz',
);

const smsResultFixture = ResultFixture(
  id: 'result-sms',
  kind: ResultFixtureKind.sms,
  typeLabel: 'Text message',
  title: '+255 754 000 111',
  fields: [
    ResultFieldFixture(
      label: 'Message',
      value: 'REG 2026 to confirm attendance',
      icon: Icons.sms_outlined,
    ),
  ],
  primaryAction: ResultActionFixture(
    label: 'Send message',
    icon: Icons.send_outlined,
    tier: ResultActionTier.disabled,
    semanticHint:
        'Sending messages will be available once messaging integration is '
        'connected.',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Copy number',
      icon: Icons.content_copy_outlined,
      tier: ResultActionTier.demonstrable,
      copyValue: '+255754000111',
    ),
    ResultActionFixture(
      label: 'Call',
      icon: Icons.call_outlined,
      tier: ResultActionTier.disabled,
      semanticHint:
          'Placing calls will be available once phone integration is '
          'connected.',
    ),
    ResultActionFixture(
      label: 'Save',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [
    ResultFieldFixture(label: 'Symbology', value: 'QR Code'),
    ResultFieldFixture(label: 'Scheme', value: 'smsto:', monospace: true),
  ],
  rawPayload: 'smsto:+255754000111:REG 2026 to confirm attendance',
);

const locationResultFixture = ResultFixture(
  id: 'result-location',
  kind: ResultFixtureKind.location,
  typeLabel: 'Location',
  title: 'Mlimani City Mall',
  fields: [
    ResultFieldFixture(
      label: 'Coordinates',
      value: '-6.7735, 39.2087',
      icon: Icons.my_location_outlined,
      monospace: true,
    ),
    ResultFieldFixture(
      label: 'Approximate address',
      value: 'Sam Nujoma Rd, Dar es Salaam',
      icon: Icons.place_outlined,
    ),
  ],
  primaryAction: ResultActionFixture(
    label: 'Open map',
    icon: Icons.map_outlined,
    tier: ResultActionTier.disabled,
    semanticHint:
        'Opening maps will be available once external actions are '
        'connected.',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Copy coordinates',
      icon: Icons.content_copy_outlined,
      tier: ResultActionTier.demonstrable,
      copyValue: '-6.7735, 39.2087',
    ),
    ResultActionFixture(
      label: 'Share location',
      icon: Icons.share_outlined,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Sharing will be available once share actions are connected.',
    ),
    ResultActionFixture(
      label: 'Save',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [
    ResultFieldFixture(label: 'Symbology', value: 'QR Code'),
    ResultFieldFixture(label: 'Scheme', value: 'geo:', monospace: true),
  ],
  rawPayload: 'geo:-6.7735,39.2087?q=Mlimani%20City%20Mall',
);

const plainTextResultFixture = ResultFixture(
  id: 'result-plain-text',
  kind: ResultFixtureKind.plainText,
  typeLabel: 'Plain text',
  title: 'Scanned text',
  fields: [
    ResultFieldFixture(
      label: 'Content',
      value:
          'Booth 14B — badge pickup opens 08:00. Please bring photo ID and '
          'your confirmation email printout.',
    ),
  ],
  primaryAction: ResultActionFixture(
    label: 'Copy text',
    icon: Icons.content_copy_outlined,
    tier: ResultActionTier.demonstrable,
    copyValue:
        'Booth 14B — badge pickup opens 08:00. Please bring photo ID and '
        'your confirmation email printout.',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Share',
      icon: Icons.share_outlined,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Sharing will be available once share actions are connected.',
    ),
    ResultActionFixture(
      label: 'Save',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [
    ResultFieldFixture(label: 'Symbology', value: 'QR Code'),
    ResultFieldFixture(label: 'Character count', value: '112'),
    ResultFieldFixture(label: 'Detected language', value: 'English'),
  ],
  rawPayload:
      'Booth 14B — badge pickup opens 08:00. Please bring photo ID and '
      'your confirmation email printout.',
);

const unsupportedResultFixture = ResultFixture(
  id: 'result-unsupported',
  kind: ResultFixtureKind.unsupported,
  typeLabel: 'Unsupported content',
  title: 'Content type not recognized',
  subtitle: "ScanWise couldn't interpret this code's structure.",
  primaryAction: ResultActionFixture(
    label: 'Copy raw value',
    icon: Icons.content_copy_outlined,
    tier: ResultActionTier.demonstrable,
    copyValue: 'MP:UNK;X7Q==:9182::UNRECOGNIZED_SCHEMA',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Share',
      icon: Icons.share_outlined,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Sharing will be available once share actions are connected.',
    ),
    ResultActionFixture(
      label: 'Save',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [
    ResultFieldFixture(label: 'Symbology', value: 'Data Matrix'),
    ResultFieldFixture(label: 'Scan source', value: 'Camera'),
  ],
  rawPayload: 'MP:UNK;X7Q==:9182::UNRECOGNIZED_SCHEMA',
);

/// A second Wi-Fi fixture, distinct from [wifiResultFixture], used only to
/// back the Library's "scanned again" duplicate example — not part of
/// [allResultFixtures] since it doesn't represent a new result kind.
const secondWifiResultFixture = ResultFixture(
  id: 'result-wifi-guest-network',
  kind: ResultFixtureKind.wifi,
  typeLabel: 'Wi-Fi network',
  title: 'Guest_Network_742',
  fields: [
    ResultFieldFixture(
      label: 'Security',
      value: 'WPA2 Enterprise',
      icon: Icons.security_outlined,
    ),
    ResultFieldFixture(
      label: 'Password',
      value: 'frontdesk_2026',
      icon: Icons.key_outlined,
      masked: true,
      monospace: true,
    ),
    ResultFieldFixture(
      label: 'Hidden network',
      value: 'No',
      icon: Icons.visibility_off_outlined,
    ),
  ],
  primaryAction: ResultActionFixture(
    label: 'Copy password',
    icon: Icons.content_copy_outlined,
    tier: ResultActionTier.demonstrable,
    copyValue: 'frontdesk_2026',
  ),
  secondaryActions: [
    ResultActionFixture(
      label: 'Wi-Fi settings',
      icon: Icons.settings_ethernet,
      tier: ResultActionTier.disabled,
      semanticHint:
          'Opening Wi-Fi settings will be available once settings '
          'integration is connected.',
    ),
    ResultActionFixture(
      label: 'Share details',
      icon: Icons.share_outlined,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Sharing will be available once share actions are connected.',
    ),
    ResultActionFixture(
      label: 'Save to Library',
      icon: Icons.bookmark_border,
      tier: ResultActionTier.previewOnly,
      previewMessage:
          'Saving will be available once Library persistence is added.',
    ),
  ],
  technicalDetails: [
    ResultFieldFixture(label: 'Symbology', value: 'QR Code'),
    ResultFieldFixture(label: 'Scan source', value: 'Camera'),
  ],
  rawPayload: 'WIFI:T:WPA2-EAP;S:Guest_Network_742;P:frontdesk_2026;H:false;;',
);

/// Every result fixture, in the same order as
/// docs/design/screen-inventory.md's Results section.
const allResultFixtures = <ResultFixture>[
  trustedUrlResultFixture,
  suspiciousUrlResultFixture,
  wifiResultFixture,
  contactResultFixture,
  productResultFixture,
  calendarEventResultFixture,
  phoneResultFixture,
  emailResultFixture,
  smsResultFixture,
  locationResultFixture,
  plainTextResultFixture,
  unsupportedResultFixture,
];
