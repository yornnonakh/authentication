import 'package:flutter/material.dart';

import '../view_models/auth_feedback.dart';

void showAuthFeedback(
  BuildContext context,
  AuthFeedback feedback, {
  EdgeInsets? margin,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: margin,
      backgroundColor: feedback.isError
          ? Colors.redAccent
          : Colors.green.shade600,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Row(
        children: [
          Icon(
            feedback.isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feedback.message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    ),
  );
}
