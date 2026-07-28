import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/router/app_routes.dart';

import '../support/library_router_harness.dart';

void main() {
  testWidgets('typing filters the visible results live', (tester) async {
    final router = buildLibraryTestRouter(
      initialLocation: AppRoutes.librarySearch,
    );
    await tester.pumpWidget(wrapWithLibraryRouter(router));
    await tester.pumpAndSettle();

    expect(find.text('Search your Library'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'sarah');
    await tester.pumpAndSettle();

    expect(find.text('Sarah Jenkins'), findsOneWidget);
    expect(find.text('NEBO Guest'), findsNothing);
  });

  testWidgets('shows a no-matches message for an unmatched query', (
    tester,
  ) async {
    final router = buildLibraryTestRouter(
      initialLocation: AppRoutes.librarySearch,
    );
    await tester.pumpWidget(wrapWithLibraryRouter(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz-not-in-library');
    await tester.pumpAndSettle();

    expect(find.text('No matches'), findsOneWidget);
  });

  testWidgets('tapping a result navigates to its scan detail', (tester) async {
    final router = buildLibraryTestRouter(
      initialLocation: AppRoutes.librarySearch,
    );
    await tester.pumpWidget(wrapWithLibraryRouter(router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'sarah');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sarah Jenkins'));
    await tester.pumpAndSettle();

    expect(find.text('Scan detail'), findsOneWidget);
  });
}
