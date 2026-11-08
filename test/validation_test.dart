import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/design.dart';
import 'package:jdonuts/features/auth/domain/validation.dart';
import 'package:jdonuts/features/product/domain/product.dart';

void main() {
  test('normalizes Myanmar phones and accepts inclusive digit boundaries', () {
    expect(normalizePhone('09 254-135 592'), '+959254135592');
    expect(normalizePhone('91234567'), '+9591234567');
    expect(normalizePhone('9123456789'), '+959123456789');
    for (final phone in [
      '9123456',
      '91234567890',
      '0091234567',
      '81234567',
      '9a1234567',
    ]) {
      expect(normalizePhone(phone), isNull);
    }
  });

  test('OTP locks after three full wrong codes and resend unlocks only after five minutes', () {
    final now = DateTime(2026, 11, 8);
    final otp = OtpChallenge(now);
    expect(otp.verify('123'), isFalse);
    expect(otp.verify('000000'), isFalse);
    expect(otp.verify('000000'), isFalse);
    expect(otp.locked, isFalse);
    expect(otp.verify('000000'), isFalse);
    expect(otp.locked, isTrue);
    expect(otp.verify(fakeOtp), isFalse);
    expect(otp.canResend(now.add(const Duration(seconds: 299))), isFalse);
    expect(otp.canResend(now.add(resendDelay)), isTrue);
    expect(OtpChallenge(now.add(resendDelay)).verify(fakeOtp), isTrue);
  });

  test('names accept Myanmar, accents and optional surname and reject invalid length or digits', () {
    expect(nameError(' မြင့် ', required: true), isNull);
    expect(nameError(' Élodie A ', required: true), isNull);
    expect(nameError('A' * 50, required: true), isNull);
    expect(nameError('A' * 51, required: true), isNotNull);
    expect(nameError('   ', required: false), isNull);
    expect(nameError('   ', required: true), isNotNull);
    expect(nameError('Hania 3', required: true), isNotNull);
  });

  test('birth dates reject impossible, future and underage dates', () {
    final now = DateTime(2026, 11, 8);
    expect(birthDate('11', '8', '2013', now), DateTime(2013, 11, 8));
    expect(birthDate('11', '9', '2013', now), isNull);
    expect(birthDate('11', '9', '2026', now), isNull);
    expect(birthDate('02', '29', '2012', now), DateTime(2012, 2, 29));
    expect(birthDate('02', '29', '2011', now), isNull);
    expect(birthDate('04', '31', '2000', now), isNull);
  });

  test('cart total floors quantity at one and formats grouped MMK', () {
    expect(productTotal(3200, 0), 3200);
    expect(mmk(productTotal(3200, 3)), '9,600 MMK');
  });
}
