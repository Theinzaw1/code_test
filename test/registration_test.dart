import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/app/app.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/result.dart';
import 'package:jdonuts/features/auth/domain/auth_repository.dart';

class TestAuth implements AuthRepository {
  @override
  Future<Result<Account?>> restore() async => const Ok(null);
  @override
  Future<Result<bool>> requestCode(
    String phone, {
    required bool register,
  }) async => Ok(register);
  @override
  Future<Result<Account?>> verify(
    String phone,
    String code, {
    required bool register,
  }) async => const Ok(null);
  @override
  Future<Result<Account>> register(Account account) async => Ok(account);
  @override
  Future<Result<void>> logout() async => const Ok(null);
}

Finder get continueButton => find.widgetWithText(FilledButton, 'CONTINUE');
Finder field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
);

Future<void> openAuth(WidgetTester tester, String entry) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authProvider.overrideWithValue(TestAuth())],
      child: const DonutApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(entry));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'invalid phone disables Continue and unknown login opens prefilled registration',
    (tester) async {
      await openAuth(tester, 'Already have an account? Log in');
      await tester.enterText(field('Phone number'), '123');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);
      expect(find.text('Enter a valid Myanmar mobile number.'), findsOneWidget);
      await tester.enterText(field('Phone number'), '09254135592');
      await tester.pumpAndSettle();
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Register this number'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(field('Phone number')).controller?.text,
        '09254135592',
      );
    },
  );

  testWidgets(
    'wrong OTP clears, valid OTP advances, and name and birth date validate',
    (tester) async {
      await openAuth(tester, 'LET’S GET STARTED');
      await tester.enterText(field('Phone number'), '09254135592');
      await tester.pump();
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      await tester.enterText(field('Verification code'), '000000');
      await tester.pump();
      await tester.tap(continueButton);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Incorrect code. Try again.'), findsOneWidget);
      expect(
        tester.widget<TextField>(field('Verification code')).controller?.text,
        isEmpty,
      );
      await tester.enterText(field('Verification code'), '123456');
      await tester.pump();
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);
      await tester.enterText(field('First name'), 'မြင့်');
      await tester.pump();
      expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      await tester.enterText(field('Month (MM)'), '02');
      await tester.enterText(field('Day (DD)'), '30');
      await tester.enterText(field('Year (YYYY)'), '2000');
      await tester.pump();
      expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);
      await tester.enterText(field('Day (DD)'), '29');
      await tester.pump();
      expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(field('First name')).controller?.text,
        'မြင့်',
      );
    },
  );
}
