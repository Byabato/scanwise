import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/router/app_routes.dart';

import 'support/settings_test_harness.dart';

void main() {
  group('AboutScreen', () {
    testWidgets('renders version and honestly-disabled legal rows', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapSettingsRouter(initialLocation: AppRoutes.settingsAbout),
      );
      await tester.pumpAndSettle();

      expect(find.text('Version'), findsOneWidget);
      expect(find.text('Version 1.0.0'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      // One "Coming soon" tag each for Terms of Service and Privacy Policy.
      expect(find.text('Coming soon'), findsNWidgets(2));
    });

    testWidgets(
      'the component gallery row is present in debug builds (flutter test '
      'always runs in debug mode, so kDebugMode is true here; a release '
      'build would omit this row and the section entirely) and navigates '
      'to the debug destination',
      (tester) async {
        // Sanity-check the premise this test relies on.
        expect(kDebugMode, isTrue);

        await tester.pumpWidget(
          wrapSettingsRouter(initialLocation: AppRoutes.settingsAbout),
        );
        await tester.pumpAndSettle();

        expect(find.text('Component gallery (debug)'), findsOneWidget);

        await tester.tap(find.text('Component gallery (debug)'));
        await tester.pumpAndSettle();

        expect(find.text('Debug gallery stub'), findsOneWidget);
      },
    );
  });
}
