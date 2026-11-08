// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'strings.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class StringsEn extends Strings {
  StringsEn([String locale = 'en']) : super(locale);

  @override
  String get onboarding => 'Round food for every mood';

  @override
  String get start => 'LET’S GET STARTED';

  @override
  String get login => 'Log in';

  @override
  String get continueLabel => 'CONTINUE';

  @override
  String get phone => 'Enter your phone number';

  @override
  String get verify => 'Verify your number';

  @override
  String get name => 'What’s your name?';

  @override
  String get birthday => 'What’s your date of birth?';

  @override
  String get welcome => 'Welcome to the world of J’Donuts';

  @override
  String get explore => 'LET’S EXPLORE';

  @override
  String get offline => 'Offline · showing saved data';

  @override
  String get home => 'Home';

  @override
  String get rewards => 'Rewards';

  @override
  String get rewardTitle => 'J’Donuts Rewards';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Log out';

  @override
  String get legalIntro => 'By continuing, you agree to our';

  @override
  String get terms => 'Terms of Use';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get facebook => 'Facebook';

  @override
  String get back => 'Back';

  @override
  String get phoneField => 'Phone number';

  @override
  String get phoneError => 'Enter a valid Myanmar mobile number.';

  @override
  String get unknownNumber => 'This number has no account.';

  @override
  String get registerNumber => 'Register this number';

  @override
  String get resend => 'Resend';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name (optional)';

  @override
  String get month => 'Month (MM)';

  @override
  String get day => 'Day (DD)';

  @override
  String get year => 'Year (YYYY)';

  @override
  String get locked => 'Too many attempts. Wait to resend.';

  @override
  String get wrongCode => 'Incorrect code. Try again.';

  @override
  String get otpField => 'Verification code';

  @override
  String get noProducts => 'No products available.';

  @override
  String get noShops => 'No shops available.';

  @override
  String get exploreNow => 'Explore now';

  @override
  String get orderOnline => 'Order online';

  @override
  String get retry => 'Retry';

  @override
  String get offers => 'Offers';

  @override
  String get memberProfile => 'Member profile';

  @override
  String get seasonal => 'Seasonal specials';

  @override
  String get popular => 'Popular';

  @override
  String get orderAgain => 'Order again';

  @override
  String get shops => 'Nearby shops';

  @override
  String get unavailableProduct => 'This product is unavailable.';

  @override
  String get productError => 'Could not load product · Retry';

  @override
  String get newBadge => 'NEW';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get description => 'What’s this?';

  @override
  String get rewardPreview => 'Your rewards are shown below.';

  @override
  String get pointsError => 'Could not load points · Retry';

  @override
  String get noChallenges => 'No challenges yet.';

  @override
  String get challengeError => 'Could not load challenges · Retry';

  @override
  String get eatMore => 'Eat more earn more';

  @override
  String get gift => 'Gift';

  @override
  String get totalPoints => 'Total points';

  @override
  String get currentTier => 'You’re here now';

  @override
  String get futureTier => 'You’ll be here soon';

  @override
  String get earn => 'EARN';

  @override
  String get challengeComplete => 'Challenge complete!';

  @override
  String get menu => 'Menu';

  @override
  String get orders => 'Orders';

  @override
  String get menuPreview => 'Menu preview';

  @override
  String get ordersPreview => 'Orders preview';

  @override
  String get restoreError => 'Could not restore session · Retry';

  @override
  String otpSent(String phone) {
    return 'We sent a six-digit code to $phone.';
  }

  @override
  String birthError(int age) {
    return 'Enter a valid date. You must be at least $age.';
  }

  @override
  String stepCount(int step) {
    return 'Step $step of 4';
  }

  @override
  String addToCart(String total) {
    return 'ADD TO CART    $total';
  }

  @override
  String added(int quantity, String product) {
    return 'Added $quantity × $product';
  }
}
