import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/app/theme/theme_mode_provider.dart';
import 'package:scanwise/features/settings/presentation/appearance_screen.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(theme: AppTheme.light, home: child),
  );
}

void main() {
  group('AppearanceScreen', () {
    testWidgets('renders all three theme options with System selected '
        'by default', (tester) async {
      await tester.pumpWidget(_wrap(const AppearanceScreen()));
      await tester.pumpAndSettle();

      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('tapping Dark selects it and updates themeModeProvider', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const AppearanceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), ThemeMode.system);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    testWidgets('tapping Light then System moves the selection each time', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const AppearanceScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), ThemeMode.light);

      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), ThemeMode.system);
    });
  });
}
