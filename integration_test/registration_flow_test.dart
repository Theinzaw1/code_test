import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jdonuts/main.dart' as app;

const _recordDemo = bool.fromEnvironment('RECORD_DEMO');
const _compactLayout = bool.fromEnvironment('COMPACT_LAYOUT');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('registers, shops, restores the session and logs in again', (
    tester,
  ) async {
    if (_compactLayout) {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      tester.view.physicalSize =
          const Size(320, 568) * tester.view.devicePixelRatio;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.view.resetPhysicalSize);
    }
    app.main();
    await tester.pumpAndSettle();
    final journey = _Journey(tester);
    await journey.ensureLoggedOut();
    if (_recordDemo) {
      debugPrint('JDONUTS_DEMO_BEGIN');
      await journey.pause(3);
    }
    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(
      5,
    );
    await journey.walkthrough('09$suffix');

    if (_recordDemo) {
      await journey.ensureLoggedOut();
      debugPrint('JDONUTS_DEMO_ENABLE_AIRPLANE');
      await journey.pause(12);
      await journey.walkthrough('091$suffix', offline: true);
      debugPrint('JDONUTS_DEMO_COMPLETE');
    }
  });
}

class _Journey {
  _Journey(this.tester);
  final WidgetTester tester;

  Future<void> pause([int beats = 2]) async {
    if (_recordDemo) {
      await Future<void>.delayed(Duration(milliseconds: beats * 550));
    }
  }

  Future<void> tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
    await pause();
  }

  Future<void> type(String label, String input) async {
    final field = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == label,
    );
    await tester.ensureVisible(field);
    await tester.enterText(field, input);
    await tester.pumpAndSettle();
    await pause();
  }

  Future<void> ensureLoggedOut() async {
    if (find.byTooltip('Settings').evaluate().isEmpty) return;
    await tap(find.byTooltip('Settings'));
    await tap(find.text('Log out'));
  }

  Future<void> authenticate(String phone) async {
    await type('Phone number', phone);
    await tap(find.text('CONTINUE'));
    await type('Verification code', '123456');
    await tap(find.text('CONTINUE'));
  }

  Future<void> walkthrough(String phone, {bool offline = false}) async {
    await tap(find.text('LET’S GET STARTED'));
    await authenticate(phone);
    await type('First name', 'Hania');
    await tap(find.text('CONTINUE'));
    await type('Month (MM)', '05');
    await type('Day (DD)', '01');
    await type('Year (YYYY)', '1999');
    await tap(find.text('CONTINUE'));
    await tap(find.text('LET’S EXPLORE'));
    if (offline) {
      for (
        var i = 0;
        i < 10 && find.textContaining('Offline ·').evaluate().isEmpty;
        i++
      ) {
        await pause(1);
        await tester.pumpAndSettle();
      }
      expect(find.textContaining('Offline ·'), findsOneWidget);
    }
    await product();
    await tap(find.byTooltip('Rewards'));
    expect(find.text('680,000'), findsOneWidget);
    await tap(find.text('Gift'));
    expect(find.text('A sweet gift'), findsOneWidget);
    await tap(find.text('Eat more earn more'));

    if (!_recordDemo) {
      await tester.pumpWidget(const SizedBox.shrink());
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('Hania'), findsOneWidget);
    }
    await ensureLoggedOut();
    await tap(find.text('Already have an account? Log in'));
    await authenticate(phone);
    expect(find.text('Hania'), findsOneWidget);
    if (_recordDemo) {
      await product();
      await tap(find.byTooltip('Rewards'));
      await pause(4);
    }
  }

  Future<void> product() async {
    final coconut = find.byKey(const ValueKey('p_coconut:1:0'));
    await tester.scrollUntilVisible(
      coconut.hitTestable(),
      130,
      scrollable: find.byType(Scrollable).first,
    );
    await tap(coconut);
    expect(find.text('JD022123'), findsOneWidget);
    expect(find.text('3,200 MMK'), findsOneWidget);
    await tap(find.byTooltip('Increase quantity'));
    expect(find.textContaining('6,400 MMK'), findsOneWidget);
    await tap(find.byTooltip('Back'));
  }
}
