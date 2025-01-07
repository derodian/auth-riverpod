import 'package:flutter/material.dart';

void showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onDismiss,
}) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
