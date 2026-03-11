import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ForgotPasswordPage extends StatelessWidget implements AutoRouteWrapper {
  const ForgotPasswordPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => this;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Forgot Password')),
    );
  }
}
