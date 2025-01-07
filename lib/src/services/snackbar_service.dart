import 'package:auth_riverpod/src/constants/keys.dart';
import 'package:flutter/material.dart';

// lib/services/snackbar_service.dart
class SnackBarService {
  static String? _lastMessage;
  static DateTime? _lastMessageTime;

  static void showError(String message) {
    // Prevent duplicate messages within 2 seconds
    if (_lastMessage == message &&
        _lastMessageTime != null &&
        DateTime.now().difference(_lastMessageTime!) <
            const Duration(seconds: 2)) {
      return;
    }

    _lastMessage = message;
    _lastMessageTime = DateTime.now();

    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () => messenger.hideCurrentSnackBar(),
          ),
        ),
      );
    });
  }

  static void showSuccess(String message) {
    debugPrint('SnackBarService - Attempting to show success: $message');

    // Prevent duplicate messages within 2 seconds
    if (_lastMessage == message &&
        _lastMessageTime != null &&
        DateTime.now().difference(_lastMessageTime!) <
            const Duration(seconds: 2)) {
      return;
    }

    _lastMessage = message;
    _lastMessageTime = DateTime.now();

    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      debugPrint('SnackBarService - ScaffoldMessengerState is null');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () => messenger.hideCurrentSnackBar(),
          ),
        ),
      );
    });

    // messenger.showSnackBar(snackBar);
    debugPrint('SnackBarService - SnackBar shown');
  }
}
