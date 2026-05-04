# TODO Later

Features that are partially implemented or designed but not yet shipped. Each
entry includes enough context to implement without re-reading code.

---

## Resend email-verification with cooldown

**Status:** Backend half done — no UI shipped.

### What exists already

- `users/{uid}.lastVerificationEmailSentAt` (`Timestamp?`) is **written** on
  signup inside `UserSource.create()` (`lib/data/remote/user/user_source.dart`,
  line ~64) and **deleted** on successful login via `FieldValue.delete()` in
  `UserSource.recordLogin()` (line ~73). The DTO, mapper, and domain model
  (`User.lastVerificationEmailSentAt: DateTime?`) are all in place.
- `AuthCubit` currently handles `AuthEmailNotVerifiedState` by signing the user
  out and emitting the state. `LoginPage` renders it as an inline `ErrorBanner`
  only — no resend CTA.

### What is missing

1. **Resend CTA** on `LoginPage` when `AuthEmailNotVerifiedState` is active.
2. **Cooldown logic** that reads `lastVerificationEmailSentAt` and disables the
   button until N minutes have elapsed since the last send.
3. **`AuthCubit.resendVerification(...)` method** that fires the verification
   email, updates the Firestore timestamp, and handles errors.
4. **Localized strings** for: button label, cooldown countdown, success
   confirmation.

### Implementation options (decision deferred)

Choose one before implementing:

#### Option A — Same-session resend (simplest)
When `signIn()` detects an unverified user, Firebase signs the user in
regardless. The limbo `currentUser` (authenticated but unverified) is still
accessible for a short window. Show a "Resend verification email" button that
calls `FirebaseAuth.instance.currentUser!.sendEmailVerification()` while the
limbo user still exists, then sign out.

- ✅ Simplest — no re-auth, no extra round-trip.
- ⚠️ `currentUser != null` briefly even though email is not verified; need to
  ensure routing guards treat this as unauthenticated.

#### Option B — Re-sign-in-on-resend (clean state)
The resend button re-runs `signInWithEmailAndPassword` silently (using the same
email/password still in the form fields), calls `sendEmailVerification()`, then
immediately `signOut()`. No persistent limbo state.

- ✅ No limbo `currentUser` window.
- ⚠️ User must still have their password in the form; if they cleared it they
  must retype it. Consider auto-reading from the password `TextEditingController`
  rather than asking again.
- Cubit signature: `resendVerification({required String email, required String password})`

#### Option C — Cloud Function (best UX, backend work required)
A Firebase callable function accepts `{email}` only, looks up the Firebase Auth
user server-side, and triggers `generateEmailVerificationLink` +
`sendCustomVerificationEmail`. The client never needs the password.

- ✅ Best UX — one tap, no password re-entry.
- ⚠️ Requires writing and deploying a Cloud Function before UI can be built.
- Cubit signature: `resendVerification({required String email})`

### Suggested cubit states to add (regardless of option)

```dart
// In auth_states.dart
class AuthVerificationEmailSentState extends BaseState {
  const AuthVerificationEmailSentState();
}
// SomethingWentWrongState already handles the error case.
// PendingState already handles loading via guardedAction.
```

### Suggested localization keys

| Key | English value (suggestion) |
|-----|---------------------------|
| `authResendVerification` | "Resend verification email" |
| `authVerificationSent` | "Verification email sent. Check your inbox." |
| `authResendCooldown` | "Please wait {seconds}s before resending." |

---
