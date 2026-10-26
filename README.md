# Finsight

Flutter authentication and expense tracker UI using MVVM and Riverpod.

Android release setup and outstanding Google Play requirements are documented in
[Google Play release](docs/google-play-release.md).

## Folder structure

```text
lib/
  main.dart                      # Supabase initialization and ProviderScope
  app/app.dart                   # App configuration and theme
  app/view_models/               # Splash and startup destination
  core/
    constants/
    providers/                   # Infrastructure dependencies
    theme/
    widgets/                     # Shared UI
  features/
    auth/
      data/{providers,repositories}/
      domain/{models,repositories}/
      presentation/{view_models,views,widgets}/
    home/
      data/{providers,repositories}/
      domain/{models,repositories}/
      presentation/{view_models,views,widgets}/
    profile/
      data/{providers,repositories}/
      domain/{models,repositories}/
      presentation/{view_models,views,widgets}/
    onboarding/
      data/{providers,repositories}/
      domain/{models,repositories}/
      presentation/{view_models,views,widgets}/
test/
  features/home/                 # Finance models, storage, filters and UI flows
  features/profile/              # Profile, save, logout and navigation tests
  features/auth/                 # Session restoration and hot reload tests
  features/onboarding/           # First launch, completion, navigation and layout
  support/                       # Fake repositories
```

## MVVM and state

Views watch view-model providers with `ref.watch` and invoke actions through
`ref.read(provider.notifier)`. View models own validation, request status,
authentication results, recovery steps, and resend countdowns. Views own
navigation, snackbars, text controllers, focus, and visual effects. State is
immutable and updated with `copyWith`. No code generation is required.

Repository contracts keep Supabase types out of view models and views.
`authRepositoryProvider` injects `SupabaseAuthRepository`, which receives
its client from `supabaseClientProvider`. Override repository providers in
`ProviderScope` or `ProviderContainer` to test without Supabase or network calls.

Auth form providers automatically dispose with their consumers. Verification
uses a provider family keyed by email. Timers are canceled with `ref.onDispose`,
and asynchronous state updates check `ref.mounted`.

Google OAuth waits for a `signedIn` event with a session before navigating.
Opening the browser alone does not count as authentication. Starting recovery
or registration cancels pending Google navigation. Recovery signs out after a
password update or when leaving the password step.

## Personal finance

`DashboardScreen` uses a rounded white navigation bar for Home, Report, Plan and
Settings, with a raised purple quick-add button in the center. The UI follows the
supplied finance reference: a compact purple balance card, soft gray backgrounds,
rounded white cards, colorful category icons and progress indicators. Profile is
available from the Home avatar and Settings account card. `TrackerPalette` and
`AppTheme` provide shared light/dark styling. Account, onboarding, recovery,
entry, scanner, details, history and settings use the same visual language. System
appearance is the default; Settings can save a light/dark override. Transaction
rows open a detail screen with a Hero transition and an edit action. Pages share
`IosScrollPage` / `IosSliverNavigationBar` for iOS large titles that collapse on
scroll, translucent pinned bars, and chevron back controls.

Home groups the all-time available balance and monthly income and expenses in one
summary card, with grouped recent transactions, a monthly budget, and compact
spending charts. The shared month selector controls
monthly totals, budgets and reports. Report switches between income and expense
distributions, with an interactive rounded donut and category rows that open a
filtered transaction list. Comparisons use the previous calendar month. Plan shows
the saved monthly spending goal and each category’s share of that limit; without
a limit, it shows each category’s share of spending. All figures use saved records.
The budget slider updates pacing while dragging and saves when released; Edit
accepts an exact amount. Budget pacing is On Pace below 80%, Approaching Limit at 80–100%, and Over Budget
above 100%. Amounts display in USD using `intl`; sums use integer cents to avoid
floating-point drift.

`Transaction` is immutable and includes ID, title, double amount, date, type,
contextual category and optional notes. The form rejects empty descriptions,
nonpositive amounts, more than two decimal places and future dates. Expense and
income categories are defined in `TransactionCategories`.
`transactionFormProvider` handles validation, saving and receipt scanning.
“Scan Receipt (AI)” intentionally simulates a two-second scan and populates
Starbucks / $4.75 / Food & Dining. No camera permission or AI service is used.

History uses a pinned search app bar, fuzzy title matching, type chips, category
filters and sticky month/year headers. Records sort newest first. Swipe left
and tap Delete in the confirmation snackbar to remove a record. Ignoring the
snackbar keeps the transaction. Failed writes preserve records and offer retry.

`expenseViewModelProvider` loads and saves through `expenseRepositoryProvider`.
`PreferencesExpenseRepository` stores JSON in shared preferences per profile ID.
It migrates the previous `finsight.expenses.v1` records to `finsight.finance.v2`
without losing transactions or monthly budgets. New accounts start empty.
Data persists on the same device; cloud sync is not implemented.

Settings exports all transactions, including notes, to CSV using `csv` and the
native `share_plus` sheet (with a download fallback on web). The export quotes
commas/newlines and protects user-entered spreadsheet formula cells. Reset All
Data requires two dialogs and typing RESET. It clears this account’s transactions,
budgets and legacy finance backup, keeping the account profile and other accounts.

Feature logic stays in Riverpod view models and repository/service interfaces;
views handle controllers, navigation and presentation. Finance tests cover local
migration, account isolation, exact totals, pacing thresholds, filtering, scanning,
edit/delete, reset confirmation, CSV export and layouts in dark mode.

## User profiles and logout

The profile tab loads the authenticated user's name and email, including the
`full_name` entered during signup or the name returned by Google. Home displays
this identity and the user's avatar or initials instead of a sample user.

`profileRepositoryProvider` injects `SupabaseProfileRepository`. Saving the
full name, optional contact phone, and optional bio uses Supabase Auth user
metadata (`full_name`, `contact_phone`, `bio`), so no extra database table or
migration is required. Email displays the authenticated account address.
Contact phone is a profile field and does not change phone authentication.

`profileViewModelProvider` validates input and exposes saving status and feedback.
`logoutViewModelProvider` signs out through the auth repository. Successful logout
removes the dashboard routes and returns to sign-in; form and user providers
automatically dispose after the dashboard closes. Signed-out events also exit
the dashboard. A failed save preserves the typed input, and a failed logout
keeps the current screen available for retry.

Supabase reference: [updating user metadata](https://supabase.com/docs/reference/dart/auth-updateuser).

## Run and verify

```sh
flutter pub get
flutter run
flutter analyze
flutter test
```

Startup shows a branded splash while `StartupViewModel` checks the SDK-persisted
session through `SessionRestoreViewModel`.
A valid saved session opens the dashboard and loads its profile; an expired
access token is refreshed before entering. Restoration failures offer retry
instead of deleting the local account. Session persistence and token refresh
are enabled in `main.dart`. Sign-in reads an existing account; signup creates
the account and saves the supplied full name.

First-time signed-out users see three onboarding pages with swipe navigation and
tappable page indicators. Get Started opens registration; Log in opens sign-in.
Both actions save the onboarding completion flag through
`PreferencesOnboardingRepository` and `SharedPreferencesAsync`. Later signed-out
launches go to sign-in, while signed-in users always go to the dashboard.
The preference is separate from the Supabase session and survives logout and
app restarts. The illustrated cards and logo are drawn in Flutter and require
no network images. Native Android and iOS launch screens use matching colors
and branding before Flutter starts. Native launch changes require a full restart.

After changing `main.dart` or adding startup providers, perform one hot restart
(`R` in the `flutter run` terminal) to apply the initialization changes. Hot
reload (`r`) rebuilds the current screen without rerunning `main()`. Once the
current initialization is running, hot reload should keep the signed-in screen
and profile. See [Flutter hot reload](https://docs.flutter.dev/tools/hot-reload).

The existing Supabase configuration remains in `main.dart`. Google uses
`com.finsight.auth://login-callback/`, which must match the Supabase redirect
allowlist and the Android/iOS callback settings. Email templates should deliver
six-digit signup and recovery codes. Apple and Facebook remain unconfigured.

Riverpod lifecycle reference: [automatic disposal](https://riverpod.dev/docs/concepts2/auto_dispose).
