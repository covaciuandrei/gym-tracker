import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Handles Firebase email action codes (email verification + password reset).
@RoutePage()
class AuthActionPage extends StatelessWidget implements AutoRouteWrapper {
  const AuthActionPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => this;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Auth Action')),
    );
  }
}
