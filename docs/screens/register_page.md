# Register Page — Screen Doc

> Last updated: 2026-04-08

## Route
`/register`

## Angular Source
`src/app/features/auth/register/`

## Visual Layout
```
Scaffold(backgroundColor: cs.surface)
  SingleChildScrollView → Center → ConstrainedBox(maxWidth: 400)
    Column(crossAxisAlignment: center)
      SizedBox(height: 48)
      Text('💪', fontSize: 64)               ← logo
      SizedBox(height: 16)
      Text('Create Account', style: tt.displaySmall)
      SizedBox(height: 8)
      Text('Start tracking your gym progress today', style: tt.bodyLarge, color: cs.onSurfaceVariant)
      SizedBox(height: 40)

      ── Form card ──
      Column(padding: 24)
        CustomTextField(label: 'Email', type: email)
        SizedBox(height: 16)
        CustomTextField(label: 'Password', type: password toggle)
        ── Password strength bar (visible when password is non-empty) ──
        SizedBox(height: 4)
        LinearProgressIndicator(
          value: strength (0.33 / 0.66 / 1.0),
          color: weak=cs.error / medium=Colors.orange / strong=cs.primary,
        )
        SizedBox(height: 4)
        Text(strengthLabel, color: matching color, style: tt.bodySmall)
        SizedBox(height: 8)
        ── Requirements checklist (visible when password non-empty) ──
        _RequirementRow('8+ characters', met: len >= 8)
        _RequirementRow('Uppercase letter', met: hasUppercase)
        _RequirementRow('Lowercase letter', met: hasLowercase)
        _RequirementRow('Number', met: hasNumber)
        SizedBox(height: 16)
        CustomTextField(label: 'Confirm Password', type: password toggle)
        ── Match indicator row ──
        Row [
          Icon(match ? Icons.check_circle : Icons.cancel,
               color: match ? cs.primary : cs.error, size: 16)
          SizedBox(width: 4)
          Text(match ? 'Passwords match' : 'Passwords do not match',
               color: same, style: tt.bodySmall)
        ]  ← only visible when confirmPassword is non-empty
        SizedBox(height: 24)
        PrimaryButton(label: 'Create Account', onPressed: _onRegister, isLoading: state is PendingState)

      SizedBox(height: 24)
      ── Footer ──
      Row(center)
        Text('Welcome Back?', style: tt.bodyMedium)
        TextButton('Sign In') → navigates to /login
```

## Success Card (replaces form on `AuthSignUpSuccessState`)
```
Card(cs.primaryContainer, padding: 24, rounded)
  Column(center)
    Icon(Icons.check_circle, color: cs.primary, size: 64)
    SizedBox(height: 16)
    Text('Account Created!', style: tt.headlineMedium)
    SizedBox(height: 8)
    Text('Please check your email to verify your account.', style: tt.bodyMedium, textAlign: center)
    SizedBox(height: 24)
    PrimaryButton('Go to Sign In (Xs)', onPressed: _goToLogin)
    ── countdown: starts at 5s, decrements each second, auto-navigates at 0 ──
```

## Password Strength Logic
```dart
String _strengthLabel(String pw) {
  int score = 0;
  if (pw.length >= 8) score++;
  if (pw.contains(RegExp(r'[A-Z]'))) score++;
  if (pw.contains(RegExp(r'[a-z]'))) score++;
  if (pw.contains(RegExp(r'[0-9]'))) score++;
  return score <= 1 ? 'Weak' : score <= 3 ? 'Medium' : 'Strong';
}
```

## State → UI Mapping
| State | Behavior |
|---|---|
| `PendingState` | button loading, fields disabled |
| `AuthSignUpSuccessState` | show success card with countdown, auto-navigate to /login after 5s |
| `AuthEmailAlreadyInUseState` | show "An account with this email already exists." error |
| `AuthWeakPasswordState` | show "Password is too weak." error |
| `SomethingWentWrongState` | show generic error |

## Colors / Styles
- Background: `cs.surface`
- Strength bar colors: weak=`cs.error`, medium=`Colors.orange`, strong=`cs.primary`
- Requirements: met=`cs.primary`, unmet=`cs.outline`
- Success card: `cs.primaryContainer`

## Navigation In/Out
- IN: from `LoginPage` (replace)
- OUT: → `LoginRoute` (replace, after success or footer link)

## Data
```dart
context.read<AuthCubit>().signUp(email: email, password: password);
```

## Status

✅ **IMPLEMENTED**
