import 'dart:async';
import 'package:flutter/foundation.dart';

Future<T> retryOperation<T>({
  required Future<T> Function() operation,
  int maxAttempts = 3,
  Duration initialDelay = const Duration(seconds: 1),
  Duration? maxDelay,
  bool Function(Exception)? retryIf,
}) async {
  int attempts = 0;
  Duration delay = initialDelay;
  maxDelay ??= initialDelay * 4;

  while (true) {
    try {
      attempts++;
      return await operation();
    } catch (error) {
      if (attempts >= maxAttempts ||
          (retryIf != null && !retryIf(error as Exception))) {
        rethrow;
      }

      debugPrint(
        'Operation failed. Attempt $attempts of $maxAttempts. Retrying in ${delay.inSeconds}s',
      );

      await Future.delayed(delay);

      // Exponential backoff with max delay
      delay *= 2;
      if (delay > maxDelay) {
        delay = maxDelay;
      }
    }
  }
}
