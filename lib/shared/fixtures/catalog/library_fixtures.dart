import '../models/library_item_fixture.dart';
import 'collection_fixtures.dart';
import 'result_fixtures.dart';

/// Temporary fixture catalog for Milestone 002 static UI. Not an
/// authoritative content source — Milestone 003 replaces this with real,
/// persisted Library records.
///
/// Dates are fixed literals rather than `DateTime.now()`-relative values so
/// fixture-driven tests stay deterministic regardless of when they run.
/// `DateTime`'s constructor isn't `const`, so these fixtures are `final`
/// rather than `const`.
/// [secondWifiLibraryItemFixture] is the one item flagged
/// `isDuplicateExample: true`, backing the duplicate-scan sheet from the
/// populated Library.

final wifiLibraryItemFixture = LibraryItemFixture(
  id: 'library-wifi',
  result: wifiResultFixture,
  savedAt: DateTime(2026, 7, 26),
  collectionId: wifiNetworksCollectionFixture.id,
);

final secondWifiLibraryItemFixture = LibraryItemFixture(
  id: 'library-wifi-guest-network',
  result: secondWifiResultFixture,
  savedAt: DateTime(2026, 7, 28),
  collectionId: wifiNetworksCollectionFixture.id,
  note: 'Front desk network',
  occurrenceCount: 3,
  isDuplicateExample: true,
);

final contactLibraryItemFixture = LibraryItemFixture(
  id: 'library-contact',
  result: contactResultFixture,
  savedAt: DateTime(2026, 7, 25),
  collectionId: eventContactsCollectionFixture.id,
  note: 'Met at TechConf 2026 keynote',
  isFavorite: true,
);

final productLibraryItemFixture = LibraryItemFixture(
  id: 'library-product',
  result: productResultFixture,
  savedAt: DateTime(2026, 7, 23),
  collectionId: productsCollectionFixture.id,
);

final calendarEventLibraryItemFixture = LibraryItemFixture(
  id: 'library-calendar-event',
  result: calendarEventResultFixture,
  savedAt: DateTime(2026, 7, 22),
);

final trustedUrlLibraryItemFixture = LibraryItemFixture(
  id: 'library-trusted-url',
  result: trustedUrlResultFixture,
  savedAt: DateTime(2026, 7, 20),
  collectionId: researchCollectionFixture.id,
  note: 'Official admissions portal',
  isFavorite: true,
);

final suspiciousUrlLibraryItemFixture = LibraryItemFixture(
  id: 'library-suspicious-url',
  result: suspiciousUrlResultFixture,
  savedAt: DateTime(2026, 7, 18),
  collectionId: researchCollectionFixture.id,
  note: 'Reported to IT — looked like phishing',
);

final phoneLibraryItemFixture = LibraryItemFixture(
  id: 'library-phone',
  result: phoneResultFixture,
  savedAt: DateTime(2026, 7, 15),
);

final emailLibraryItemFixture = LibraryItemFixture(
  id: 'library-email',
  result: emailResultFixture,
  savedAt: DateTime(2026, 7, 12),
  collectionId: eventContactsCollectionFixture.id,
);

final smsLibraryItemFixture = LibraryItemFixture(
  id: 'library-sms',
  result: smsResultFixture,
  savedAt: DateTime(2026, 7, 8),
);

final locationLibraryItemFixture = LibraryItemFixture(
  id: 'library-location',
  result: locationResultFixture,
  savedAt: DateTime(2026, 7, 1),
  isFavorite: true,
);

final plainTextLibraryItemFixture = LibraryItemFixture(
  id: 'library-plain-text',
  result: plainTextResultFixture,
  savedAt: DateTime(2026, 6, 20),
);

final unsupportedLibraryItemFixture = LibraryItemFixture(
  id: 'library-unsupported',
  result: unsupportedResultFixture,
  savedAt: DateTime(2026, 6, 5),
);

/// A populated Library, newest first.
final populatedLibraryItemFixtures = <LibraryItemFixture>[
  secondWifiLibraryItemFixture,
  wifiLibraryItemFixture,
  contactLibraryItemFixture,
  productLibraryItemFixture,
  calendarEventLibraryItemFixture,
  trustedUrlLibraryItemFixture,
  suspiciousUrlLibraryItemFixture,
  phoneLibraryItemFixture,
  emailLibraryItemFixture,
  smsLibraryItemFixture,
  locationLibraryItemFixture,
  plainTextLibraryItemFixture,
  unsupportedLibraryItemFixture,
];

/// The empty-Library fixture state.
const emptyLibraryItemFixtures = <LibraryItemFixture>[];
