# J’Donuts

A Flutter assessment app for Android and iOS. It demonstrates fake registration and login, a local storefront, product detail, and animated member rewards.

## Run

Use Flutter stable **3.47.7** and Dart **3.13.5**, with Android Studio and an Android emulator or Xcode and an iOS Simulator. Confirm the toolchains with `flutter doctor`.

```sh
flutter pub get
flutter run -d <device-id>
```

Start with **Let’s get started** and enter a Myanmar number such as `09254135592`. The fake OTP is **123456**. First name is required, surname is optional, and age must be at least 13. Settings → Log out clears the secure session. Log in with the registered number to skip registration. The same flow works without a network.

## Source map

| Path | Responsibility |
|---|---|
| `lib/app` | Riverpod composition, session guard, tab navigation |
| `lib/core` | Drift schema and seed transaction, typed auth results, reachability, design and motion tokens |
| `lib/features/auth` | Pure validation, repository contract and implementation, onboarding and registration |
| `lib/features/home` | Catalog repository, member header, carousel, product sections and shops |
| `lib/features/product` | Product records, repository, detail and quantity pricing |
| `lib/features/rewards` | Challenges repository, member progress and rewards UI |
| `lib/l10n` | English ARB strings and generated bindings |
| `assets` | JSON seed and original WebP artwork |

Riverpod owns dependency construction, the session, and async read state. Auth keeps draft fields and focus nodes with the active flow so back navigation retains the draft and leaving the flow disposes it. Domain contracts and validators use pure Dart. Fake auth uses a one-second request delay, versioned SQLite account storage and platform secure storage for the current phone identifier.

## Offline behavior

On first database access, Drift creates the version 1 schema and imports bundled JSON within a transaction. Home, Product and Rewards query SQLite. Home and Rewards share the same Riverpod member query. Product details can display the selected database record immediately during the Hero transition, then query by ID. Images use bundled WebP assets with loading and error placeholders. Pull-to-refresh rereads the database, as does Home when connectivity returns. The app has a single local data source. A connectivity change or periodic poll triggers an HTTPS 204 reachability check against gstatic. A failed probe only changes the offline indicator and does not block content.

The mockups disagree on membership values. The seed uses Silver, 500 points to Gold, and 680,000 total points. The ring uses the stored progress target of 900,000 to reproduce the approximate ring fill in the Rewards design.

## Motion

Named durations and curves coordinate staggered onboarding and Welcome art, registration slides, progress ring, OTP shake, press scaling, skeleton shimmer, carousel, product Hero, quantity count changes, Rewards and the bottom tab pill. Reward artwork uses a painted ring, clipped donut progress and a coffee arc. Reduce Motion skips the local transitions and carousel autoplay.

## Verification and builds

```sh
dart format .
flutter analyze
flutter test
flutter test integration_test/registration_flow_test.dart -d <device-id>
flutter build apk --release
flutter build ios --simulator --debug
ditto -c -k --sequesterRsrc --keepParent build/ios/iphonesimulator/Runner.app JDonuts-iOS-Simulator.zip
```

The assessment APK uses Flutter’s template debug signing for evaluator installation. The simulator archive is for iOS Simulator only.

The analyzer reported no issues and all nine unit, repository, and widget tests passed. The Android emulator completed the registration, shopping, Rewards, logout and returning-login journey online and in airplane mode. The iPhone 16e simulator completed the journey at a 320×568 logical viewport with 1.3× text scale, including secure session restoration after recreating the app root.

The social and legal controls, Menu and Orders tabs, nearby shop actions and reward redemption are previews. Add to cart provides visual feedback. The optional remote service, persistent cart and Burmese translation are outside this implementation. Some domain validation messages and seed content remain in English. 60 FPS on a mid-range physical Android phone requires profile-mode measurement.

## Time spent

Approximately 55 minutes of elapsed workspace time, including analysis, implementation, builds, device tests, recording and visual review.

## Artwork

Original artwork was created with the built-in image generator and cropped into `assets/images/`. The client’s reference screens were used for visual comparison.

> Create a square 3 by 3 exact grid of separate original product photography asset tiles for a cheerful Myanmar donut shop Flutter app, nine tiles each using exactly one third of width and height, no gutters, no type, no logos. Top row: chocolate iced donut with thin white coconut drizzle on off-white, strawberry sprinkle pink donut on blush, violet iced donut on sky blue. Middle row: iced americano clear cup on white, orange-glazed donut on sunny yellow, glazed donut with candy pieces on pastel lavender. Bottom row: assortment of colorful donuts in open box on purple, cozy modern donut shop interior, and cheerful young Burmese woman member portrait with light peach background. All subjects centered within their own tile with generous margin. Bright natural light, product catalog photography.
