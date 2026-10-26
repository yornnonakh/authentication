# Google Play release

## Current state

Release signing is configured to use `android/key.properties`; it no longer falls
back to the debug key. Release builds reject the sample package ID and missing
signing details. The configured package ID is `com.yornnona.expensetracker` for
both debug and release builds. The Android launcher name is Finsight, matching
the Flutter app.

No Play upload or submission has been made. A local upload keystore and signing
properties have been generated on this machine and are excluded from Git.
Play publishing credentials are still required. There is no connected Play
Console publishing integration available in this session.

## Package ID and signing

1. The confirmed package ID, `com.yornnona.expensetracker`, is set in
   `android/gradle.properties`. Keep this ID for the existing Play listing.
   The Kotlin namespace can remain `com.example.authentication`; it is separate
   from the published ID.
2. For an existing listing, use its registered upload key. For a new upload key,
   run `python3 scripts/setup_android_signing.py` from the project root. This
   creates `android/upload-keystore.jks`, `android/key.properties`, and the public
   `android/upload-certificate.pem`, with private file permissions and random
   passwords. It never overwrites existing signing files. The keystore and
   properties must be backed up securely. Alternatively, follow the
   [Flutter signing instructions](https://docs.flutter.dev/deployment/android#sign-the-app).
   A newly generated certificate must match the registered Play upload key;
   otherwise, use the original key or request an upload key reset in
   [Play Console](https://support.google.com/googleplay/android-developer/answer/9842756).
   Creating a local key does not change the registered key in Play Console.
3. To use an existing key, copy `android/key.properties.example` to
   `android/key.properties` and fill in the path, alias, and passwords locally.
   The setup script already fills this file when generating a new key.
   Both the populated properties file and Android keystores are excluded by `android/.gitignore`.
   Relative keystore paths resolve from `android/`.
4. Keep Play service account JSON credentials outside the repository. Give the
   account only the required app publishing permissions in Play Console.

## Build and validate

```sh
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```

The signed bundle is produced at
`build/app/outputs/bundle/release/app-release.aab`. Building a bundle does not
upload it or publish the app.

The source version is `1.0.0+1`. For an existing app, use a version code greater
than every previous upload; for example, supply `--build-name` and `--build-number`
to the build command. Check the actual previous version in Play Console first.

The installed Flutter SDK defaults to compile/target API 36 and NDK 28.2.
[Google currently requires API 36 for new phone apps and updates](https://support.google.com/googleplay/android-developer/answer/11926878).
Verify the finished bundle's manifest, signature, native library compatibility
(including 16 KB pages), and Google Play pre-launch report before rollout.
Exercise email signup, OTP, recovery, Google OAuth, session restoration, CSV
sharing, and finance persistence on a physical Android device. The OAuth callback
`com.finsight.auth://login-callback/` must remain allowed in Supabase.

## Outstanding app and listing requirements

- Account deletion: signup exists, but there is no in-app account deletion request
  path or public deletion request page. "Reset All Data" clears local finance
  records and preserves the Supabase account; it does not meet the
  [account deletion requirement](https://support.google.com/googleplay/android-developer/answer/13327111).
  Implement an authenticated deletion request or deletion service and its in-app
  path, plus a working public request page. Supabase administrative credentials
  must stay on the server.
- Privacy: publish a policy for the actual developer/operator and link it in the
  app and store listing. Supply a support contact and actual retention/deletion
  practices before finalizing the policy.
- Data safety: review the backend and SDK behavior. Email and profile metadata
  use Supabase, and Google OAuth is supported. Finance records are stored locally
  per account and can be exported through the platform share sheet. Optional
  profile fields include phone and bio. Do not claim that all app data stays
  on the device.
- Listing assets: provide a 512 × 512 store icon, 1024 × 500 feature graphic, and
  at least two representative phone screenshots. See
  [Google's asset requirements](https://support.google.com/googleplay/android-developer/answer/9866151).
  The Android launcher PNGs still use the Flutter template icon.
- Complete content rating, target audience, ads, financial features, app access,
  countries, pricing, and other applicable Play Console declarations. This code
  has no advertising or billing SDK. Verify that against the final release and
  backend before submitting declarations. Supply reviewer access for authenticated
  screens through Play Console; do not put account passwords in source control.
- The receipt scanner uses simulated Starbucks/$4.75 data. Store text must not
  advertise live AI scanning or cloud finance sync.

## Submission

An accurate English listing draft is available in
[google-play-store-listing.md](google-play-store-listing.md).

Create or open the app in [Play Console](https://play.google.com/console/), enable
Play App Signing, and upload the signed AAB to an internal test release first.
Complete the listing and app content declarations, test the distributed build,
then prepare the appropriate production or closed testing release.

For personal developer accounts created after November 13, 2023, Google requires
[at least 12 testers opted into a closed test continuously for 14 days](https://support.google.com/googleplay/android-developer/answer/14151465)
before applying for production access. Internal testing does not satisfy that
requirement. Account verification, review, and production access are controlled
by Google; an upload alone does not make the app public.
