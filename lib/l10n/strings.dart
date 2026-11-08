import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'strings_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of Strings
/// returned by `Strings.of(context)`.
///
/// Applications need to include `Strings.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/strings.dart';
///
/// return MaterialApp(
///   localizationsDelegates: Strings.localizationsDelegates,
///   supportedLocales: Strings.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the Strings.supportedLocales
/// property.
abstract class Strings {
  Strings(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static Strings of(BuildContext context) {
    return Localizations.of<Strings>(context, Strings)!;
  }

  static const LocalizationsDelegate<Strings> delegate = _StringsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @onboarding.
  ///
  /// In en, this message translates to:
  /// **'Round food for every mood'**
  String get onboarding;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'LET’S GET STARTED'**
  String get start;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueLabel;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phone;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get verify;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'What’s your name?'**
  String get name;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'What’s your date of birth?'**
  String get birthday;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the world of J’Donuts'**
  String get welcome;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'LET’S EXPLORE'**
  String get explore;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline · showing saved data'**
  String get offline;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @rewardTitle.
  ///
  /// In en, this message translates to:
  /// **'J’Donuts Rewards'**
  String get rewardTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @legalIntro.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get legalIntro;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @phoneField.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneField;

  /// No description provided for @phoneError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Myanmar mobile number.'**
  String get phoneError;

  /// No description provided for @unknownNumber.
  ///
  /// In en, this message translates to:
  /// **'This number has no account.'**
  String get unknownNumber;

  /// No description provided for @registerNumber.
  ///
  /// In en, this message translates to:
  /// **'Register this number'**
  String get registerNumber;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name (optional)'**
  String get lastName;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month (MM)'**
  String get month;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day (DD)'**
  String get day;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year (YYYY)'**
  String get year;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait to resend.'**
  String get locked;

  /// No description provided for @wrongCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code. Try again.'**
  String get wrongCode;

  /// No description provided for @otpField.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpField;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products available.'**
  String get noProducts;

  /// No description provided for @noShops.
  ///
  /// In en, this message translates to:
  /// **'No shops available.'**
  String get noShops;

  /// No description provided for @exploreNow.
  ///
  /// In en, this message translates to:
  /// **'Explore now'**
  String get exploreNow;

  /// No description provided for @orderOnline.
  ///
  /// In en, this message translates to:
  /// **'Order online'**
  String get orderOnline;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @memberProfile.
  ///
  /// In en, this message translates to:
  /// **'Member profile'**
  String get memberProfile;

  /// No description provided for @seasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal specials'**
  String get seasonal;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @orderAgain.
  ///
  /// In en, this message translates to:
  /// **'Order again'**
  String get orderAgain;

  /// No description provided for @shops.
  ///
  /// In en, this message translates to:
  /// **'Nearby shops'**
  String get shops;

  /// No description provided for @unavailableProduct.
  ///
  /// In en, this message translates to:
  /// **'This product is unavailable.'**
  String get unavailableProduct;

  /// No description provided for @productError.
  ///
  /// In en, this message translates to:
  /// **'Could not load product · Retry'**
  String get productError;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'What’s this?'**
  String get description;

  /// No description provided for @rewardPreview.
  ///
  /// In en, this message translates to:
  /// **'Your rewards are shown below.'**
  String get rewardPreview;

  /// No description provided for @pointsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load points · Retry'**
  String get pointsError;

  /// No description provided for @noChallenges.
  ///
  /// In en, this message translates to:
  /// **'No challenges yet.'**
  String get noChallenges;

  /// No description provided for @challengeError.
  ///
  /// In en, this message translates to:
  /// **'Could not load challenges · Retry'**
  String get challengeError;

  /// No description provided for @eatMore.
  ///
  /// In en, this message translates to:
  /// **'Eat more earn more'**
  String get eatMore;

  /// No description provided for @gift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get gift;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total points'**
  String get totalPoints;

  /// No description provided for @currentTier.
  ///
  /// In en, this message translates to:
  /// **'You’re here now'**
  String get currentTier;

  /// No description provided for @futureTier.
  ///
  /// In en, this message translates to:
  /// **'You’ll be here soon'**
  String get futureTier;

  /// No description provided for @earn.
  ///
  /// In en, this message translates to:
  /// **'EARN'**
  String get earn;

  /// No description provided for @challengeComplete.
  ///
  /// In en, this message translates to:
  /// **'Challenge complete!'**
  String get challengeComplete;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @menuPreview.
  ///
  /// In en, this message translates to:
  /// **'Menu preview'**
  String get menuPreview;

  /// No description provided for @ordersPreview.
  ///
  /// In en, this message translates to:
  /// **'Orders preview'**
  String get ordersPreview;

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Could not restore session · Retry'**
  String get restoreError;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a six-digit code to {phone}.'**
  String otpSent(String phone);

  /// No description provided for @birthError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date. You must be at least {age}.'**
  String birthError(int age);

  /// No description provided for @stepCount.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 4'**
  String stepCount(int step);

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'ADD TO CART    {total}'**
  String addToCart(String total);

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added {quantity} × {product}'**
  String added(int quantity, String product);
}

class _StringsDelegate extends LocalizationsDelegate<Strings> {
  const _StringsDelegate();

  @override
  Future<Strings> load(Locale locale) {
    return SynchronousFuture<Strings>(lookupStrings(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_StringsDelegate old) => false;
}

Strings lookupStrings(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return StringsEn();
  }

  throw FlutterError(
    'Strings.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
