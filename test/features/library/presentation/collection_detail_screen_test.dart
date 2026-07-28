import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/features/library/presentation/collection_detail_screen.dart';
import 'package:scanwise/shared/fixtures/catalog/collection_fixtures.dart';

import '../support/library_router_harness.dart';

void main() {
  testWidgets('shows only that collection\'s items and a live count', (
    tester,
  ) async {
    final harness = buildLibraryHarness(
      CollectionDetailScreen(collectionId: wifiNetworksCollectionFixture.id),
    );
    addTearDown(harness.container.dispose);

    await tester.pumpWidget(harness.widget);
    await tester.pumpAndSettle();

    // Appears both as the AppBar title and the header card's name.
    expect(find.text('Wi-Fi networks'), findsNWidgets(2));
    // Both Wi-Fi fixtures belong to this collection.
    expect(find.text('NEBO Guest'), findsOneWidget);
    expect(find.text('Guest_Network_742'), findsOneWidget);
    // An item from a different collection must not appear.
    expect(find.text('Sarah Jenkins'), findsNothing);

    expect(find.text('2 scans'), findsOneWidget);
  });

  testWidgets('search scopes results to this collection only', (tester) async {
    final harness = buildLibraryHarness(
      CollectionDetailScreen(collectionId: wifiNetworksCollectionFixture.id),
    );
    addTearDown(harness.container.dispose);

    await tester.pumpWidget(harness.widget);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '742');
    await tester.pumpAndSettle();

    expect(find.text('Guest_Network_742'), findsOneWidget);
    expect(find.text('NEBO Guest'), findsNothing);
  });

  testWidgets('shows an honest fallback for an unknown collection id', (
    tester,
  ) async {
    final harness = buildLibraryHarness(
      const CollectionDetailScreen(collectionId: 'does-not-exist'),
    );
    addTearDown(harness.container.dispose);

    await tester.pumpWidget(harness.widget);
    await tester.pumpAndSettle();

    expect(find.text('Collection not found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
