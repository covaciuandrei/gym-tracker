# Auth Action Page — Prep Notes

## Route
`/auth/action`
Receives deep-link from Firebase email actions (verify email / reset password).

## Angular Source
`src/app/features/auth/auth-action/`

## Query Parameters
Parsed from the URL (Firebase sends `?mode=...&oobCode=...`):
- `mode`: `'verifyEmail'` | `'resetPassword'`
- `oobCode`: one-time action code string

In Flutter with auto_route, pass as `@QueryParam`:
```dart
@RoutePage()
class AuthActionPage extends StatefulWidget {
  const AuthActionPage({
    @QueryParam('mode') this.mode,
    @QueryParam('oobCode') this.oobCode,
    super.key,
  });
  final String? mode;
  final String? oobCode;
}
```

## States / UI Branches

### 1 — Loading (initial)
```
Scaffold → Center → Column
  CircularProgressIndicator(color: cs.primary)
  SizedBox(height: 16)
  Text('Verifying...' / 'Validating...', style: tt.bodyLarge, color: cs.onSurfaceVariant)
```
- `verifyEmail` mode: text = "Verifying your email..."  
- `resetPassword` mode: text = "Validating reset link..."

### 2 — verifyEmail success (`AuthEmailVerifiedState`)
```
Column(center)
  Text('✅', fontSize: 64)
  SizedBox(height: 16)
  Text('Email Verified!', style: tt.displaySmall)
  SizedBox(height: 8)
  Text('Your email has been verified successfully.', style: tt.bodyLarge, color: cs.onSurfaceVariant, textAlign: center)
  SizedBox(height: 32)
  PrimaryButton('Sign In') → context.router.replace(LoginRoute())
```

### 3 — resetPassword form (after link validated via oobCode)
```
Column(center, padding: 24)
  Text('🔑', fontSize: 64)
  SizedBox(height: 16)
  Text('Reset Password', style: tt.displaySmall)
  SizedBox(height: 8)
  Text(emailFromOobCode, style: tt.bodyMedium, color: cs.onSurfaceVariant)
  SizedBox(height: 32)
  CustomTextField(label: 'New Password', type: password toggle)
  ── password strength bar (same as register page) ──
  SizedBox(height: 16)
  CustomTextField(label: 'Confirm Password', type: password toggle)
  SizedBox(height: 24)
  PrimaryButton('Reset Password', onPressed: _onConfirmReset, isLoading: pending)
```

### 4 — resetPassword success (`AuthPasswordResetConfirmedState`)
```
Column(center)
  Text('🎉', fontSize: 64)
  SizedBox(height: 16)
  Text('Password Reset!', style: tt.displaySmall)
  SizedBox(height: 8)
  Text('Your password has been updated. You can now sign in.', textAlign: center)
  SizedBox(height: 32)
  PrimaryButton('Sign In') → context.router.replace(LoginRoute())
```

### 5 — Error (`AuthInvalidActionCodeState` or `SomethingWentWrongState`)
```
Column(center)
  Text('⚠️', fontSize: 64)
  SizedBox(height: 16)
  Text('Something Went Wrong', style: tt.displaySmall)
  SizedBox(height: 8)
  Text('The link may have expired or already been used.', textAlign: center)
  SizedBox(height: 32)
  PrimaryButton('Back to Sign In') → context.router.replace(LoginRoute())
```

## initState Logic
```dart
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final cubit = context.read<AuthCubit>();
    switch (widget.mode) {
      case 'verifyEmail':
        cubit.verifyEmail(widget.oobCode ?? '');
      case 'resetPassword':
        // Show form, validate oobCode via Firebase getOobCodeInfo or just proceed
        setState(() => _showResetForm = true);
      default:
        // Unknown mode → error state
    }
  });
}
```

## State → UI Mapping
| State | Behavior |
|---|---|
| `PendingState` | show loading |
| `AuthEmailVerifiedState` | show verifyEmail success |
| `AuthPasswordResetConfirmedState` | show resetPassword success |
| `AuthInvalidActionCodeState` | show error |
| `SomethingWentWrongState` | show error |

## Data
```dart
// Verify email:
context.read<AuthCubit>().verifyEmail(oobCode);

// Confirm password reset:
context.read<AuthCubit>().confirmPasswordReset(oobCode: oobCode, newPassword: newPassword);
```

## Navigation In/Out
- IN: Firebase deep link (email click) → `/auth/action?mode=...&oobCode=...`
- OUT: → `LoginRoute` (replace on all success/error actions)
