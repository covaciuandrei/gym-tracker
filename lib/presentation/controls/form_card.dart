import 'package:flutter/material.dart';

/// Reusable styled form card container used across auth screens.
///
/// Provides the shared surface/shadow/border decoration for form panels.
/// Pass form fields as [children] — they are rendered inside an
/// [AutofillGroup], an optional [Form] (when [formKey] is supplied), and a
/// left-aligned [Column].
///
/// Omit [formKey] for panels that perform no local validation (e.g. login),
/// which skips the [Form] wrapper while keeping the same visual shell.
class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    this.formKey,
    required this.children,
  });

  final GlobalKey<FormState>? formKey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AutofillGroup(
        child: formKey != null
            ? Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
      ),
    );
  }
}
