import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jdonuts/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'registers, opens the selected product, and updates its cart total',
    (tester) async {
      app.main();
      await tester.pumpAndSettle();
      if (find.byTooltip('Settings').evaluate().isNotEmpty) {
        await tester.tap(find.byTooltip('Settings'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Log out'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('LET’S GET STARTED'));
      await tester.pumpAndSettle();

      Future<void> type(String label, String input) async {
        final field = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == label,
        );
        await tester.ensureVisible(field);
        await tester.enterText(field, input);
        await tester.pumpAndSettle();
      }

      Future<void> next() async {
        final button = find.text('CONTINUE');
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
      }

      final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(
        5,
      );
      await type('Phone number', '09$suffix');
      await next();
      await type('Verification code', '123456');
      await next();
      await type('First name', 'Hania');
      await next();
      await type('Month (MM)', '05');
      await type('Day (DD)', '01');
      await type('Year (YYYY)', '1999');
      await next();
      await tester.tap(find.text('LET’S EXPLORE'));
      await tester.pumpAndSettle();

      final coconut = find.text('Coconut Donut');
      await tester.scrollUntilVisible(
        coconut.first,
        130,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(coconut.first);
      await tester.pumpAndSettle();
      expect(find.text('JD022123'), findsOneWidget);
      expect(find.text('3,200 MMK'), findsOneWidget);
      await tester.tap(find.byTooltip('Increase quantity'));
      await tester.pumpAndSettle();
      expect(find.textContaining('6,400 MMK'), findsOneWidget);
    },
  );
}
