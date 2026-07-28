import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanwise/app/theme/app_theme.dart';
import 'package:scanwise/features/settings/presentation/permissions_screen.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

void main() {
  group('PermissionsScreen', () {
    testWidgets('reports camera permission status honestly', (tester) async {
      await tester.pumpWidget(_wrap(const PermissionsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Camera'), findsOneWidget);
      expect(
        find.text("Not yet requested — camera integration isn't connected."),
        findsOneWidget,
      );
    });

    testWidgets('the open app settings affordance is a real disabled button', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const PermissionsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Open app settings'), findsOneWidget);

      final button = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text('Open app settings'),
          matching: find.byWidgetPredicate(
            (widget) => widget is OutlinedButton,
          ),
        ),
      );
      expect(button.onPressed, isNull);

      final ancestorSemantics = tester.widgetList<Semantics>(
        find.ancestor(
          of: find.text('Open app settings'),
          matching: find.byType(Semantics),
        ),
      );
      expect(
        ancestorSemantics.any((s) => s.properties.enabled == false),
        isTrue,
      );
    });
  });
}
