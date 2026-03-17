# Onboarding Page

## Purpose

A carousel-style walkthrough shown **only on first app launch** (before the user
has ever logged in). Three pages introduce the app's core features. After the
carousel the user taps "Get Started" and lands on the Login page.

## Trigger

`OnboardingHelper.isFirstLaunch` (backed by `SharedPreferences`).
Set to `false` when the user **first logs in successfully**.

## Flow

```
App Start → Splash → isFirstLaunch?
  ├── true  → OnboardingPage (carousel) → LoginPage
  └── false → (existing logic: logged-in → MainShell, else → LoginPage)
```

## Widget Tree (Flutter)

```
Scaffold
  body: SafeArea
    Column
      Expanded
        PageView (3 pages, physics: BouncingScrollPhysics)
          _OnboardingSlide(emoji, title, subtitle)   // × 3
      SmoothPageIndicator (3 dots)
      SizedBox(h: 32)
      Padding(h: 24)
        GradientButton("Next" / "Get Started")
      SizedBox(h: 16)
      TextButton("Skip")   // hidden on last page
      SizedBox(h: 24)
```

## Slides

| # | Emoji             | Title (en)                | Subtitle (en)                                           |
|---|-------------------|---------------------------|---------------------------------------------------------|
| 1 | 🏋️ weightLifting  | Track Your Workouts       | Log every gym session and see your attendance at a glance. |
| 2 | 💊 pill            | Monitor Your Health       | Keep track of your supplements and daily nutrition.       |
| 3 | 📊 barChart        | Analyze Your Progress     | View detailed stats, streaks, and monthly breakdowns.     |

## Colour / Theme Tokens (from context)

- Page background: `scaffoldBackgroundColor`
- Emoji size: `72`
- Title: `textTheme.headlineMedium`, `.copyWith(fontWeight: w700)`
- Subtitle: `textTheme.bodyLarge`, `.copyWith(color: cs.onSurfaceVariant)`
- Dot active colour: `cs.primary`
- Dot inactive colour: `cs.outline`
- Button: `GradientButton` (full-width indigo gradient)
- Skip button: `TextButton` with `cs.onSurfaceVariant` colour

## Interactions

- Swipe left/right to navigate between slides.
- Tap "Next" → animate to next page.
- Tap "Get Started" (last page) → `context.router.replace(LoginRoute())`.
- Tap "Skip" → same navigation as "Get Started".
- "Skip" label is hidden on the last page (already showing "Get Started").

## Angular Source

N/A — this is a new feature with no Angular counterpart.
