import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HealthPage extends StatelessWidget implements AutoRouteWrapper {
  const HealthPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => this;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Health')),
    );
  }
}
