import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/presentation/helpers/onboarding_helper.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/resources/app_colors.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  AnimationController? _entryCtrl;

  // Logo: elastic pop-in
  Animation<double>? _logoScale;
  Animation<double>? _logoFade;

  // App name: fade + slide up
  Animation<double>? _titleFade;
  Animation<double>? _titleY;

  // Subtitle: fade + slide up (delayed)
  Animation<double>? _subtitleFade;
  Animation<double>? _subtitleY;

  // Dots loader: fade in last
  Animation<double>? _dotsFade;

  AnimationController? _dotsCtrl;

  @override
  void initState() {
    super.initState();

    final entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _entryCtrl = entryCtrl;

    final dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dotsCtrl = dotsCtrl;

    // Logo: 0.0 → 0.6 elastic scale, 0.0 → 0.3 fade
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
      ),
    );

    // Title: 0.30 → 0.65
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.30, 0.65, curve: Curves.easeOut),
      ),
    );
    _titleY = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.30, 0.65, curve: Curves.easeOut),
      ),
    );

    // Subtitle: 0.50 → 0.82
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.50, 0.82, curve: Curves.easeOut),
      ),
    );
    _subtitleY = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.50, 0.82, curve: Curves.easeOut),
      ),
    );

    // Dots: 0.75 → 1.0
    _dotsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  Future<void> _navigate() async {
    await Future<void>.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    final onboardingHelper = getIt<OnboardingHelper>();
    if (onboardingHelper.isFirstLaunch) {
      context.router.replace(const OnboardingRoute());
      return;
    }
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    if (isLoggedIn) {
      context.router.replace(const MainShellRoute());
    } else {
      context.router.replace(const LoginRoute());
    }
  }

  @override
  void dispose() {
    _entryCtrl?.dispose();
    _dotsCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final entryCtrl = _entryCtrl;
    final dotsCtrl = _dotsCtrl;

    if (entryCtrl == null ||
        dotsCtrl == null ||
        _logoScale == null ||
        _logoFade == null ||
        _titleFade == null ||
        _titleY == null ||
        _subtitleFade == null ||
        _subtitleY == null ||
        _dotsFade == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: AnimatedBuilder(
            animation: entryCtrl,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: _logoFade!.value,
                    child: Transform.scale(
                      scale: _logoScale!.value,
                      child: const _LogoCard(),
                    ),
                  ),
                  const SizedBox(height: 36),

                  Opacity(
                    opacity: _titleFade!.value,
                    child: Transform.translate(
                      offset: Offset(0, _titleY!.value),
                      child: Text(
                        'Gym Tracker',
                        style: tt.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Opacity(
                    opacity: _subtitleFade!.value,
                    child: Transform.translate(
                      offset: Offset(0, _subtitleY!.value),
                      child: Text(
                        'Track your gym journey',
                        style: tt.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 72),

                  Opacity(
                    opacity: _dotsFade!.value,
                    child: _DotsLoader(controller: dotsCtrl, color: cs.primary),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

//
// Rounded-square container with the primary gradient and a coloured shadow —
// the same gradient as Angular's .btn-primary (135deg #6366f1 → #4f46e5).
class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.38),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Center(
        child: EmojiText(Emojis.biceps, style: TextStyle(fontSize: 56)),
      ),
    );
  }
}

//
// Each dot bounces up using a sin wave with a 120° (2π/3) phase offset so
// they cascade in sequence. Dot brightness also pulses with the bounce.
class _DotsLoader extends StatelessWidget {
  const _DotsLoader({required this.controller, required this.color});

  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Stagger each dot by 120° around the unit circle
            final phase =
                controller.value * 2 * math.pi + i * (2 * math.pi / 3);
            final sinVal = math.sin(phase);
            // Only lift upward (negative y) on the positive half of the wave
            final yOffset = sinVal > 0 ? -10.0 * sinVal : 0.0;
            // Opacity pulses from 0.45 → 1.0 in sync with the lift
            final opacity = sinVal > 0 ? 0.45 + 0.55 * sinVal : 0.45;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.translate(
                offset: Offset(0, yOffset),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
