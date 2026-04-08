# Forgot Password Page — Screen Doc

> Last updated: 2026-04-08

## Route
`/forgot-password`

## Angular Source
`src/app/features/auth/forgot-password/`

## Visual Layout
```
Scaffold(backgroundColor: cs.surface)
  SingleChildScrollView → Center → ConstrainedBox(maxWidth: 400)
    Column(crossAxisAxisAlignment: center)
      SizedBox(height: 48)
      Text('🔐', fontSize: 64)               ← logo
      SizedBox(height: 16)
      Text('Reset Password', style: tt.displaySmall)
      SizedBox(height: 8)
      Text("Enter your email and we'll send you a reset link",
           style: tt.bodyLarge, color: cs.onSurfaceVariant, textAlign: center)
      SizedBox(height: 40)

      ── FORM STATE (default) ──
      Column(padding: 24)
        CustomTextField(label: 'Email', type: email)
        SizedBox(height: 24)
        PrimaryButton(label: 'Send Reset Link', onPressed: _onSend, isLoading: state is PendingState)

      SizedBox(height: 24)
      TextButton('← Back to Sign In') → context.router.replace(LoginRoute())
```

## Success State (shown after `AuthPasswordResetSentState`)
Replaces form content:
```
Column(center, padding: 24)
  Icon('📧' or Icons.email, color: cs.primary, size: 64)
  SizedBox(height: 16)
  Text('Reset Link Sent!', style: tt.headlineMedium)
  SizedBox(height: 8)
  Text('Check your inbox for the password reset link.',
       style: tt.bodyMedium, textAlign: center)
  SizedBox(height: 24)
  OutlinedButton('← Back to Sign In') → context.router.replace(LoginRoute())
```

## State → UI Mapping
| State | Behavior |
|---|---|
| `PendingState` | button loading |
| `AuthPasswordResetSentState` | hide form, show success content |
| `SomethingWentWrongState` | show error message below button |

## Colors / Styles
- Background: `cs.surface`
- Success icon: `cs.primary`

## Navigation In/Out
- IN: from `LoginPage` via "Forgot password?" link (push)
- OUT: → `LoginRoute` (replace on back button or success action)

## Data
```dart
context.read<AuthCubit>().resetPassword(email);
```

## Status

✅ **IMPLEMENTED**
