import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/core/app_router.gr.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  Future<void> _navigate() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    if (isLoggedIn) {
      context.router.replace(const MainShellRoute());
    } else {
      context.router.replace(const LoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              '💪',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            Text(
              'Gym Tracker',
              style: tt.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Track your gym journey',
              style: tt.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            CircularProgressIndicator(color: cs.primary),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
