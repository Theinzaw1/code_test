const minimumAge = 13;
const fakeOtp = '123456';
const otpLength = 6;
const resendDelay = Duration(minutes: 5);
const maxAttempts = 3;

String? normalizePhone(String input) {
  final digits = input
      .replaceAll(RegExp(r'[\s-]'), '')
      .replaceFirst(RegExp(r'^0'), '');
  return RegExp(r'^9\d{7,9}$').hasMatch(digits) ? '+95$digits' : null;
}

bool validOtp(String input) => input == fakeOtp;

String? nameError(String input, {required bool required}) {
  final name = input.trim();
  if (name.isEmpty) return required ? 'Enter your first name.' : null;
  final letters = RegExp(r'^(?:\p{L}\p{M}*| )+$', unicode: true);
  if (name.runes.length > 50 || !letters.hasMatch(name)) {
    return 'Use up to 50 letters and spaces.';
  }
  return null;
}

DateTime? birthDate(String month, String day, String year, DateTime now) {
  final m = int.tryParse(month);
  final d = int.tryParse(day);
  final y = int.tryParse(year);
  if (m == null || d == null || y == null || y < 1 || y > now.year) return null;
  final date = DateTime(y, m, d);
  if (date.year != y || date.month != m || date.day != d) return null;
  final age =
      now.year - y - ((now.month * 100 + now.day < m * 100 + d) ? 1 : 0);
  return age >= minimumAge ? date : null;
}

class OtpChallenge {
  OtpChallenge(DateTime now) : resendAt = now.add(resendDelay);
  final DateTime resendAt;
  int _attempts = 0;
  bool get locked => _attempts >= maxAttempts;
  bool canResend(DateTime now) => !now.isBefore(resendAt);

  bool verify(String input) {
    if (locked || input.length != otpLength) return false;
    if (validOtp(input)) return true;
    _attempts++;
    return false;
  }
}
