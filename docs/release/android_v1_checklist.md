# Android v1.0 First-Approval Checklist (Minimum) — gym_tracker

This version is intentionally minimal and sequential, focused on what is required to get a first Google Play approval with the lowest risk. Store photos/screenshots are kept at the end.

---

## 0) Scope (what is in / out)

- In scope: mandatory items for first approval + the minimum technical checks needed to avoid reviewer-blocking issues.
- Out of scope for now: optional polish/hardening (R8, branded native splash, manifest hardening refinements) unless you choose to include them.

## 3) Build and upload path (minimum)

### 3.1 Pre-upload checks

1. `dart analyze lib/` → 0 issues.
2. `flutter test` → green.
3. `flutter build appbundle --release` → succeeds.

### 3.2 Upload for reviewable testing

1. Upload AAB to Internal testing.
2. Add yourself as tester.
3. Install from Play link on a real device.

---

## 5) Store listing assets (do this last)

Per your request, keep this section at the end.

1. Hi-res icon (512x512).
2. Feature graphic (1024x500).
3. Phone screenshots (min 2).
4. Short + full description (EN and RO).
5. Category + release notes (“What’s new”).

---

## 6) Optional after first approval (recommended, not mandatory)

These improve quality/security but are not required for first approval:

1. Enable R8/minify and maintain ProGuard keep rules.
2. Add branded native splash (`flutter_native_splash`).
3. Add manifest hardening (`allowBackup=false`, locale config).
4. Configure Firebase Auth Play Integrity for release fingerprints.
5. Validate Crashlytics deobfuscation pipeline.
