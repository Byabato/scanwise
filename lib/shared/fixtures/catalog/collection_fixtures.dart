import '../models/collection_fixture.dart';
import '../models/result_fixture_kind.dart';

/// Temporary fixture catalog for Milestone 002 static UI. Not an
/// authoritative content source — Milestone 003 replaces this with real,
/// user-created collections. Names mirror the example collections in
/// docs/product/product-contract.md.

const eventContactsCollectionFixture = CollectionFixture(
  id: 'collection-event-contacts',
  name: 'Event contacts',
  description: 'People met at conferences and events.',
  itemCount: 2,
  suggestedForKinds: [ResultFixtureKind.contact],
);

const productsCollectionFixture = CollectionFixture(
  id: 'collection-products',
  name: 'Products to compare',
  description: 'Barcodes worth a second look.',
  itemCount: 1,
  suggestedForKinds: [ResultFixtureKind.product],
);

const wifiNetworksCollectionFixture = CollectionFixture(
  id: 'collection-networks',
  name: 'Wi-Fi networks',
  description: 'Networks scanned from cards or posters.',
  itemCount: 2,
  suggestedForKinds: [ResultFixtureKind.wifi],
);

const researchCollectionFixture = CollectionFixture(
  id: 'collection-research',
  name: 'Research resources',
  description: 'Links worth reviewing again.',
  itemCount: 2,
  suggestedForKinds: [
    ResultFixtureKind.trustedUrl,
    ResultFixtureKind.suspiciousUrl,
  ],
);

const allCollectionFixtures = <CollectionFixture>[
  eventContactsCollectionFixture,
  productsCollectionFixture,
  wifiNetworksCollectionFixture,
  researchCollectionFixture,
];
