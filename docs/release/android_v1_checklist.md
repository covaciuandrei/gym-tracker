# Android v1.0 Release Checklist — gym_tracker

Ordered list of everything that must be done before the first Google Play release. Items are grouped into **Blockers** (Play will reject or app ships broken/insecure), **High** (fix before upload, UX/security impact), and **Final verification** (smoke test before pushing to Internal Testing).

---

## BLOCKERS

### 1. Firebase Crashlytics

**What it is.** Crashlytics is Firebase's crash reporting service. When a user's app crashes or hits a caught-but-unexpected error, the stack trace, device info, and a breadcrumb trail are uploaded to the Firebase Console so you can diagnose and fix it without the user having to report anything.

**Why it's a blocker.** Without Crashlytics you are shipping blind: if 5% of users crash on sign-up, you will never know. Once you have real users you cannot retroactively collect crashes that already happened — you must have it wired before first release.

**What to do.**
1. Add `firebase_crashlytics: ^<latest-compatible>` to `pubspec.yaml` under `dependencies`.
2. In `android/build.gradle.kts` (project-level) add the Crashlytics Gradle plugin classpath. In `android/app/build.gradle.kts` apply `id("com.google.firebase.crashlytics")`.
3. In `lib/main.dart`, wrap `runApp(...)` in `runZonedGuarded`. Inside, set:
   - `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;` — catches Flutter framework errors.
   - `PlatformDispatcher.instance.onError = (e, s) { FirebaseCrashlytics.instance.recordError(e, s, fatal: true); return true; };` — catches uncaught async errors outside Flutter.
   - The `runZonedGuarded` `onError` callback calls `recordError(..., fatal: true)` — catches anything else.
4. In `lib/cubit/base_cubit.dart`, in the `catch (e, s)` block that emits `SomethingWentWrongState`, call `FirebaseCrashlytics.instance.recordError(e, s, fatal: false)` first. These are **non-fatal** reports: they show up in Crashlytics as handled exceptions, useful for detecting buggy flows even when the app didn't crash.
5. Build release with `--obfuscate --split-debug-info=build/symbols` and upload the symbols (Firebase CLI or Gradle task) so stack traces are readable in Console.

**How to verify.** Temporarily add a button that calls `FirebaseCrashlytics.instance.crash()`. Run a release build, tap it, reopen the app, and within ~5 minutes the crash should appear in Firebase Console → Crashlytics.

---

### 2. Release signing configuration

**What it is.** Every Android APK/AAB must be cryptographically signed with a keystore. Play Console refuses debug-signed builds and requires the same key for every subsequent update — if you lose the key you can never update your app again (without delisting and re-publishing under a new package name). The current build uses the debug keystore for release (`android/app/build.gradle.kts` line ~34), which is a hard rejection.

**Why it's a blocker.** Play Console will not accept a debug-signed AAB. Also, any build you ship publicly must be signed with a key you control and have backed up.

**What to do.**
1. Generate an **upload keystore** (kept on your machine — you sign with it, Google re-signs with the real app-signing key once uploaded):
   ```
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Store the `.jks` outside the repo (e.g. `~/keystores/`). **Back it up to two separate locations.**
2. Create `android/key.properties` (not committed) with:
   ```
   storeFile=/absolute/path/to/upload-keystore.jks
   storePassword=...
   keyAlias=upload
   keyPassword=...
   ```
3. In `android/app/build.gradle.kts`, load these properties and declare a `signingConfigs { create("release") { ... } }` block that uses them. Then set `buildTypes.release.signingConfig = signingConfigs.getByName("release")`. Remove the debug-signing fallback and the `TODO` comment.
4. Accept **Play App Signing** when setting up the app in Play Console (recommended — Google holds the real app-signing key; you only need the upload key).

**How to verify.** `flutter build appbundle --release` completes without errors and `bundletool` or Play Console accepts the AAB.

---

### 3. R8 / code shrinking + ProGuard keep rules

**What it is.** R8 is Android's default minifier: it strips unused classes, renames symbols (obfuscation), and shrinks resources. Without it, the APK is larger and anyone can decompile it to near-original Kotlin/Java. ProGuard rules (`proguard-rules.pro`) tell R8 which classes to leave untouched — required for reflection-heavy libraries like Firebase and JSON serializers, otherwise the release build silently breaks at runtime.

**Why it's a blocker.** Not strictly required by Play, but shipping without it means (a) the APK ships with readable code and (b) you will almost certainly hit runtime crashes in release builds that don't occur in debug (Firebase SDK classes removed, JSON parsing failing, etc.) that are very hard to debug.

**What to do.**
1. In `android/app/build.gradle.kts` under `buildTypes.release`:
   ```
   isMinifyEnabled = true
   isShrinkResources = true
   proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
   ```
2. Create `android/app/proguard-rules.pro` with keep rules for:
   - Firebase (`-keep class com.google.firebase.** { *; }`, and rules for Firestore model serialization)
   - `kotlinx.serialization` / `json_serializable` generated classes
   - `auto_route` generated routers
   - `injectable` generated DI
   - `flutter_bloc` / `bloc` (usually not required but safe)
3. Build a release AAB and smoke-test the full auth → main-shell → log-workout → delete-account flow. If anything crashes with `ClassNotFoundException` or silently returns null from Firestore, you need to add the corresponding keep rule.

**How to verify.** Release AAB is noticeably smaller, and the smoke test passes end-to-end.

---

### 4. Android App Links (Firebase email verification / password reset)

**What it is.** When Firebase sends a verification or password-reset email, it links back to a URL under your Firebase Hosting domain. Android App Links let that URL open directly in your installed app instead of a browser, by verifying a file at `https://<yourdomain>/.well-known/assetlinks.json` that lists your app's package name and signing-key fingerprints.

**Why it's a blocker.** Without this, users tapping the verification link will get dumped into the browser-hosted Firebase action page and may or may not make it back to the app. The flow is already designed to rely on this (see `docs/screens/register_page.md` / `login_page.md`).

**What to do.**
1. Your hosting public root is `legal/` (see `firebase.json`). Create `legal/.well-known/assetlinks.json`:
   ```json
   [{
     "relation": ["delegate_permission/common.handle_all_urls"],
     "target": {
       "namespace": "android_app",
       "package_name": "com.gymtracker.gym_tracker",
       "sha256_cert_fingerprints": [
         "<UPLOAD_KEY_SHA256>",
         "<PLAY_APP_SIGNING_SHA256>"
       ]
     }
   }]
   ```
2. Get the **upload key** fingerprint: `keytool -list -v -keystore upload-keystore.jks -alias upload` — copy the SHA-256.
3. Get the **Play App Signing key** fingerprint from Play Console → your app → Setup → App Integrity (available only **after** the first AAB upload). You'll do a second pass on this file at that point.
4. Deploy hosting: `firebase deploy --only hosting`.
5. Verify the file is reachable: `curl https://<your-firebase-project>.web.app/.well-known/assetlinks.json`.

**How to verify.** On a real device signed with the release key, tap a verification link from an email — it should open directly in the app with no browser chrome.

---

### 5. Public privacy policy + account-deletion URLs

**What it is.** Google Play requires every app to publish (a) a privacy policy URL reachable on the public internet and (b) a dedicated web URL explaining how users can delete their account and associated data. Both are entered into the Play Console Data Safety form; without them the app cannot be published.

**Why it's a blocker.** Play Console will reject submission without these URLs. Independently, the account-deletion URL must exist even for apps that offer in-app deletion — Play policy explicitly requires a web-accessible page so users who have uninstalled the app can still request deletion.

**What to do.**
1. `legal/privacy-en.html` and `legal/terms-en.html` already exist (plus RO variants). Confirm they are accurate for the real data you collect (email, displayName, workout history, supplement logs, device theme/language preference, `lastLoginAt`, `createdAt`).
2. Create `legal/delete-account.html` with:
   - A plain-language description that inside the app, users can delete their account from Settings → Account → Delete Account.
   - What gets deleted (everything under `users/{uid}/...` in Firestore and the Firebase Auth user record).
   - A contact email for users who no longer have the app installed to request deletion manually.
3. `firebase deploy --only hosting` and capture the two public URLs.
4. Enter them into Play Console → App Content → Privacy Policy, and the Data Safety form's "How can users request their data be deleted?" field.

**How to verify.** Load both URLs in an incognito window from a non-Google network; both render correctly.

---

### 6. Deploy Firestore security rules to production

**What it is.** `firestore.rules` defines who can read/write what in your Firestore database. If rules aren't deployed (or are still in default "test mode" that allows anyone to read/write anything for 30 days), any client — malicious or otherwise — can read every user's data.

**Why it's a blocker.** The rules file exists in the repo but a committed file does not equal a deployed rule set. Default test-mode rules are the single most common cause of Firestore data leaks in early-stage apps.

**What to do.**
1. Review `firestore.rules` and confirm it enforces:
   - `users/{uid}/**` → readable/writable only when `request.auth.uid == uid`.
   - `supplementProducts/{id}` → readable by any authenticated user; writable only when `request.auth.uid == resource.data.createdBy`.
   - `ingredients/{id}` → readable by any authenticated user; not client-writable.
   - `appConfig/version` → public read, no client writes.
2. Deploy: `firebase deploy --only firestore:rules`.
3. In Firebase Console → Firestore → Rules, confirm the deployed rules match your repo file (not the test-mode default `allow read, write: if request.time < timestamp.date(...)`).

**How to verify.** Using a second test account, attempt to read `users/<other-uid>/attendances/...` — should be denied with `permission-denied`. Use the Rules Playground in the Console for targeted tests.

---

## HIGH (fix before upload — UX, security polish)

### 7. Root `.gitignore` hardening

**What it is.** `.gitignore` tells Git to never commit certain files. You currently ignore `key.properties` and `*.jks` in `android/.gitignore` but not in the root `.gitignore`.

**Why it matters.** Defense in depth — if anyone places a keystore or properties file outside `android/` by mistake (say, at the repo root during a rushed setup), it would be committed. Leaked signing keys are unrecoverable.

**What to do.** Add to root `.gitignore`:
```
key.properties
*.jks
*.keystore
```

**How to verify.** `git check-ignore -v key.properties` prints the rule.

---

### 8. Android manifest hardening

**What it is.** Small Play-recommended manifest attributes that improve security, privacy, and listing quality.

**Why it matters.**
- `android:allowBackup="false"` — prevents Android's auto-backup from copying your app's private data (including cached auth tokens and SharedPreferences) to the user's Google Drive. Sensible default unless you deliberately want cross-device state restoration.
- `android:localeConfig="@xml/locales_config"` — tells Android 13+ and the Play Store which languages your app supports, enabling per-app language settings and showing localized store listings.

**What to do.**
1. In `android/app/src/main/AndroidManifest.xml` on the `<application>` tag add `android:allowBackup="false"` and `android:localeConfig="@xml/locales_config"`.
2. Create `android/app/src/main/res/xml/locales_config.xml`:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <locale-config xmlns:android="http://schemas.android.com/apk/res/android">
       <locale android:name="en"/>
       <locale android:name="ro"/>
   </locale-config>
   ```

**How to verify.** Build release AAB. On an Android 13+ device, go to Settings → Apps → Gym Tracker → Language — EN and RO appear in the list.

---

### 9. Branded cold-launch splash screen

**What it is.** The splash screen is the very first image a user sees while the app process is starting up, before Flutter itself has drawn anything. Without configuration, Android shows a white/black screen with the default Flutter logo. `flutter_native_splash` generates the native Android 12+ splash resources (and legacy pre-12 fallback) from a single config block.

**Why it matters.** Perception: a plain white flash looks broken. A branded splash is a 30-minute win that materially improves first-run polish.

**What to do.**
1. Add `flutter_native_splash: ^<latest>` to `dev_dependencies` in `pubspec.yaml`.
2. Add a `flutter_native_splash:` configuration block specifying:
   - `color`: your dark background color (e.g. `#0f172a` — `AppColors.backgroundDark`).
   - `image`: a 1:1 centered logo PNG (512×512 at least).
   - `android_12: { icon_background_color, image }` — Android 12+ uses a separate adaptive splash.
3. Run `dart run flutter_native_splash:create`.
4. Commit the generated resources.

**How to verify.** Cold-launch the release build on a real device — you see your branded splash, not a white flash, before `SplashPage` appears.

---

### 10. Firebase Auth production hardening (Play Integrity)

**What it is.** Firebase Auth uses either reCAPTCHA or Play Integrity to stop abuse (bots creating fake accounts). In debug you may have reCAPTCHA disabled (`lib/main.dart` has a `kDebugMode`-guarded call that looks like this). In release, Firebase enforces one of the two — if neither is configured in the Console for your release SHA-256, legitimate sign-ins can intermittently fail with cryptic errors.

**Why it matters.** Intermittent sign-in failures in production are hard to debug and will cost you real users.

**What to do.**
1. Firebase Console → Authentication → Settings → App Check / Play Integrity.
2. Register your release SHA-256 (upload key **and** Play App Signing key, same two fingerprints as the assetlinks file).
3. Enable Play Integrity for the Auth product.
4. Leave reCAPTCHA Enterprise disabled unless you deliberately want it.

**How to verify.** Fresh install of the release AAB on a clean device, then sign up + sign in — no unexpected failures.

---

### 11. Play Store listing assets

**What it is.** The marketing and compliance content shown on the Play Store page: icon, screenshots, descriptions, category, content rating, Data Safety form.

**Why it matters.** Required at submission time. Can be prepared in parallel with technical work.

**What to do (checklist).**
- **Hi-res icon** — 512×512 PNG, 32-bit with alpha. Typically an upscale of your adaptive icon foreground on a solid-color background.
- **Feature graphic** — 1024×500 PNG/JPG. Shown at the top of the Play listing. Include your app name and a one-line value proposition.
- **Phone screenshots** — 2 minimum, 8 maximum. Portrait. Taken from a **release build** on a real device or high-fidelity emulator. Suggested screens: Calendar (with some data), Stats, Health tab, Workout Types, Profile/Settings. Add captions overlaid in Figma/Canva.
- **Short description** — ≤80 characters. EN and RO.
- **Full description** — ≤4000 characters. Cover: what the app does, main features (workout tracking, supplement logging, stats), privacy (no ads, no tracking, your data stays in your account), free. EN and RO.
- **Category** — Health & Fitness.
- **Content rating questionnaire** — answer truthfully; this app will likely be rated Everyone / PEGI 3.
- **Data Safety form** — declare collected data: email (PII, account creation), user ID (app functionality), app activity (workout + supplement logs). Encrypted in transit (HTTPS): yes. User can request deletion: yes, in-app and via URL (from item 5).
- **App access** — declare the app requires an account; provide test credentials if the review team needs them.
- **Target audience** — 18+ (health tracking) or 13+ depending on your preference.

**How to verify.** Every field in the Play Console "Store listing", "Main store listing", "Data safety", and "Content rating" sections is filled and all validation ticks are green.

---

## Final verification before uploading AAB

Run all of these in order. Do not upload until every step passes.

1. `dart analyze lib/` → **0 issues**.
2. `flutter test` → all green.
3. `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols` → succeeds.
4. Upload the AAB to Play Console → **Internal testing** track. Add yourself as a tester. Install via the Play Store listing link on a real device.
5. Smoke test (full user journey on the installed internal-testing build):
   - Register with a new email → receive verification email → tap link → **opens directly in app**.
   - Log in before verifying → see "verify email" state → resend verification (cooldown works).
   - Forgot password → receive email → tap link → reset → log in with new password.
   - Log a workout for today.
   - Log a supplement for today.
   - Open Stats — each tab loads and shows data.
   - Toggle theme; toggle language (app restarts with new locale).
   - Change password while signed in.
   - **Delete account** → verify in Firebase Console that the Firestore `users/{uid}` subtree is gone AND the Auth user is gone.
6. Force-trigger a test crash → it appears in Firebase Console → Crashlytics within ~5 minutes with a readable (deobfuscated) stack trace.
7. With a second test account, attempt a direct Firestore read of the first account's data → denied with `permission-denied`.
8. Load the privacy policy URL and the account-deletion URL from an incognito browser on a non-Google network → both render.

If all 8 pass, promote the AAB from Internal testing → Closed testing (or straight to Production if you're confident).

---

## Explicitly out of scope for Android v1

- iOS-specific items (`apple-app-site-association`, entitlements, `CFBundleName`, iOS signing).
- Firebase Analytics (recommended but not a blocker).
- Custom auth domain.
- Product flavors (dev/staging/prod).
- Firebase Remote Config / feature flags.
- Push notifications.
- App Check enforcement beyond Auth.
- In-app review prompts.
