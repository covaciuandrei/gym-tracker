# Login Page — Prep Notes

## Route
`/login`

## Angular Source
`src/app/features/auth/login/`

## Visual Layout
```
Scaffold(backgroundColor: cs.surface)
  SingleChildScrollView → Center → ConstrainedBox(maxWidth: 400)
    Column(crossAxisAlignment: center)
      SizedBox(height: 48)
      Text('💪', fontSize: 64)               ← logo
      SizedBox(height: 16)
      Text('Welcome Back', style: tt.displaySmall)
      SizedBox(height: 8)
      Text('Sign in to track your gym attendance', style: tt.bodyLarge, color: cs.onSurfaceVariant)
      SizedBox(height: 40)

      ── Form card (Card or Container with rounded corners, cs.surfaceContainerHigh) ──
      Column(padding: 24)
        CustomTextField(label: 'Email', type: email, autocomplete: email)
        SizedBox(height: 16)
        CustomTextField(
          label: 'Password',
          type: password/text toggle,
          suffix: IconButton(Icons.visibility / Icons.visibility_off)
        )
        SizedBox(height: 8)
        Align(right) → TextButton('Forgot password?') → navigates to /forgot-password
        SizedBox(height: 24)

        ── Error area (visible only on error) ──
        Container(color: cs.errorContainer, padding: 12, rounded)
          Text(errorMessage, color: cs.onErrorContainer, style: tt.bodySmall)
        SizedBox(height: 16)  ← only when error visible

        PrimaryButton(
          label: 'Sign In',
          onPressed: _onSignIn,
          isLoading: state is PendingState,
        )

      SizedBox(height: 24)
      ── Footer ──
      Row(center)
        Text("Don't have an account?", style: tt.bodyMedium)
        TextButton('Sign up') → navigates to /register
```

## Interactions
| Element | Action |
|---|---|
| Email field | Updates local state, trims on submit |
| Password field | Updates local state; eye icon toggles obscureText |
| "Forgot password?" | `context.router.push(ForgotPasswordRoute())` |
| "Sign In" button | calls `authCubit.signIn(email, password)` |
| "Sign up" link | `context.router.replace(RegisterRoute())` |

## State → UI Mapping (AuthCubit)
| State | Behavior |
|---|---|
| `PendingState` | button shows spinner, fields disabled |
| `AuthSignInSuccessState` | `context.router.replace(MainShellRoute())` |
| `AuthInvalidCredentialsState` | show "Invalid email or password." error |
| `AuthEmailNotVerifiedState` | show "Please verify your email before signing in." error |
| `SomethingWentWrongState` | show "Something went wrong. Please try again." error |

## Colors / Styles
- Background: `cs.surface`
- Card: `cs.surfaceContainerHigh`, `BorderRadius.circular(16)`
- Error container: `cs.errorContainer` / `cs.onErrorContainer`
- Footer text: `tt.bodyMedium` default
- "Sign up" link: `cs.primary`

## Navigation In/Out
- IN: from `SplashPage` (replace) or `RegisterPage` (replace)
- OUT: → `ForgotPasswordRoute` (push), → `RegisterRoute` (replace), → `MainShellRoute` (replace on success)

## Data
```dart
// Cubit call:
context.read<AuthCubit>().signIn(email: email, password: password);

// Listen in initState/BlocListener:
BlocListener<AuthCubit, BaseState>(
  listener: (context, state) {
    if (state is AuthSignInSuccessState) {
      context.router.replace(const MainShellRoute());
    } else if (state is AuthInvalidCredentialsState) {
      // show error
    }
  },
)
```
