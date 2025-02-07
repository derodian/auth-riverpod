import 'dart:async';
import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'email_verification_controller.g.dart';

@riverpod
class EmailVerificationController extends _$EmailVerificationController {
  Timer? _timer;

  @override
  bool build() {
    ref.onDispose(() => _timer?.cancel());
    return false;
  }

  Future<void> startVerificationCheck() async {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => checkVerification(showError: false),
    );
  }

  Future<void> checkVerification({bool showError = false}) async {
    try {
      final authController = ref.read(authControllerProvider.notifier);
      await authController.reload();

      // Only update state if verification status changed
      final isVerified =
          ref.read(authControllerProvider).value?.isEmailVerified ?? false;
      if (state != isVerified) {
        state = isVerified;
      }
    } catch (e) {
      if (showError) {
        throw e;
      }
    }
  }
}
