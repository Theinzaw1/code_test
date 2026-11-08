# Assessment traceability

| Ref | Acceptance target |
|---|---|
| 1 | Onboarding has register, login and social/legal placeholders |
| 2 | Phone uses +95 and validates after blur |
| 3 | OTP uses six cells, accepts paste and autofill, shakes, clears and locks after three errors until resend |
| 4–5 | Empty and filled Name are states of one screen with optional surname |
| 6 | Birth date validates calendar date, future dates and age 13 |
| 7 | Welcome enters Home after registration |
| 8 | Persisted member, carousel, three product lists, four shops, offline status and navigation |
| 9 | Selected product, offline image, Hero, MMK total and cart feedback |
| 10 | Shared member, animated points and tiers, tabs, progress art and reward badge |

Register → Phone → Verify → Name → Birth date → Welcome → Home.
Login → Phone → Verify → Home for a registered phone. Unknown numbers see a registration link.
Home → Product and Home ↔ Rewards. Settings → Log out → Onboarding. A restored session starts at Home.

| Input | Validation |
|---|---|
| Phone | Strip spaces, hyphens, then one leading zero. Require 9 plus 7–9 digits. |
| OTP | 123456, three incorrect attempts, 300 seconds before resend |
| Name | 1–50 trimmed letters or spaces, including Myanmar combining marks. Last name optional. |
| Birth date | Round-trip calendar components, today or earlier, at least 13 years old |

Use feature-first presentation/domain/data, Riverpod injection and query providers, go_router, Drift SQLite, secure storage, connectivity_plus with a reachability probe, gen-l10n and Flutter motion. Data records are account, member, product, banner, section, shop and challenge. A seed transaction populates a versioned database. The two references disagree about the tier. Use Silver, 500 to Gold, and 680,000 total everywhere.

Day one covers foundation, auth and local data through Home and Product. Day two covers Rewards, motion, accessibility, tests and packaging. Main risks are SDK/platform build access, visual fidelity without client art, and simulator and airplane-mode verification. Remote API, Burmese translations, persistent cart and CI are optional. Keep the client screenshots out of the source repository. Submission email is outside this workspace task.

## Phase reports

| Phase | A. Requirements | B. Plan | C–D. Files and implementation | E. Verification |
|---|---|---|---|---|
| Foundation | Android and iOS, routing, offline dependencies | Scaffold the empty workspace and inject platform services centrally | `lib/app`, `lib/core`, platform runners, `pubspec.yaml` | Dependency resolution, analyzer and launch on both emulators |
| Auth | Four registration steps, returning login, secure session | Keep a draft for each active flow, validate in pure Dart, persist the account and session separately | `lib/features/auth`, auth tests | Phone, OTP, name, birth date, and price unit checks. Repository and widget tests. Android registration, logout and returning login. |
| Catalog | Seeded Home, product detail, offline images | Use SQLite for records and bundle images with the app | `lib/features/home`, `lib/features/product`, `assets` | SQLite seed test. Android selected-product code, price, quantity total and back navigation. Offline indicators and data in airplane mode. |
| Rewards | Shared member, points ring, tiers, tabs and challenges | Drive visuals from the member and challenge records | `lib/features/rewards`, shared motion and shell | Android checked the animated total after settling, opened Gift and returned to challenges in both network states. |
| Delivery | Build artifacts and documentation | Build one platform at a time and package the outputs locally | `README.md`, ignored `deliverables/` folder | Signed APK archive check and install. Simulator ZIP archive check and install. |

## F. Remaining work

Publishing requires a destination repository. Performance on a mid-range physical Android device remains unmeasured. English strings and seed copy have partial ARB coverage. The full shopping journey passed on the iPhone 16e simulator with a 320×568 logical viewport and 1.3× text scale. A physical-device sweep across the full size range remains open.

## Delivery audit

- `flutter analyze` completed with no issues. All nine unit, repository, and widget tests passed.
- The iOS Simulator integration passed at 320×568 and 1.3× text scale. It exercised registration, product detail, Rewards, secure session restoration, logout and returning login.
- The final Android integration passed online and in airplane mode. The 2:22 recording was decoded and sampled in both network states to verify the Rewards rendering correction.
- The Android APK signature and both platform archives passed integrity checks. The source bundle preserves the standalone Git history.
