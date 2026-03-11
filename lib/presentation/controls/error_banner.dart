import 'package:flutter/material.dart';

/// Inline error banner shown inside forms after a failed action.
///
/// Mirrors Angular `.error-message`:
///   background: rgba(239,68,68,0.1) · color: #ef4444
///   border: 1px solid rgba(239,68,68,0.2) · border-radius: 12px
///   padding: 14px 16px · font-size: 14px
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFEF4444);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: red.withValues(alpha: 0.2)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: red,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}
