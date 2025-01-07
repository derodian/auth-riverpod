import 'dart:async';

import 'package:auth_riverpod/src/features/auth/data/app_auth.dart';
import 'package:auth_riverpod/src/features/auth/data/firebase_auth_service.dart';
import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  AppAuth get _auth => ref.watch(authServiceProvider);
  StreamSubscription<AppUser?>? _userSubscription;
  StreamSubscription<bool>? _emailVerificationSubscription;
  bool _disposed = false;

  @override
  FutureOr<AppUser?> build() async {
    _setupUserListener();
    _setupEmailVerificationListener();
    return await _auth.getCurrentUser();
  }

  Stream<AppUser?> get authStateChanges => _auth.authStateChanges;
  Stream<bool> get isEmailVerified => _auth.isEmailVerified;

  void _setupUserListener() {
    _userSubscription?.cancel();
    _userSubscription = _auth.authStateChanges.listen((user) {
      if (!_disposed && !state.isLoading) {
        // Only update if not in loading state
        state = AsyncData(user);
      }
    });
  }

  void clearError() {
    if (state.hasError) {
      state = AsyncValue.data(state.valueOrNull);
    }
  }

  void _setupEmailVerificationListener() {
    _emailVerificationSubscription?.cancel();
    _emailVerificationSubscription = _auth.isEmailVerified.listen((isVerified) {
      if (!_disposed && isVerified) {
        reload();
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    debugPrint('AuthController: Attempting sign in...'); // Debug print
    if (state.isLoading) return; // Prevent multiple calls while loading
    state = const AsyncValue.loading();
    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('AuthController: Sign in successful');
      if (!_disposed) {
        state = AsyncData(user);
      }
    } catch (e, st) {
      debugPrint('AuthController: Sign in error - $e');
      if (!_disposed) {
        state = AsyncError(e, st);
      }
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
      );
      if (!_disposed) {
        state = AsyncData(user);
      }
    } catch (e, st) {
      if (!_disposed) {
        state = AsyncError(e, st);
      }
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _auth.signOut();
      return null;
    });
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _auth.sendPasswordResetEmail(email);
      return null;
    });
  }

  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _auth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      return null;
    });
  }

  Future<void> sendEmailVerification() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _auth.sendEmailVerification();
      return state.valueOrNull;
    });
  }

  Future<void> reload() async {
    if (_disposed) return;
    state = const AsyncLoading();
    try {
      await _auth.reload();
      final user = await _auth.getCurrentUser();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _auth.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      return await _auth.getCurrentUser();
    });
  }

  Future<void> updateEmail(String newEmail) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _auth.updateEmail(newEmail);
      return await _auth.getCurrentUser();
    });
  }

  Future<void> updatePassword(String newPassword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _auth.updatePassword(newPassword);
      return state.valueOrNull;
    });
  }

  Future<bool> reauthenticateWithPassword(String password) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = state.valueOrNull;
      if (currentUser == null) {
        throw Exception('No user is signed in');
      }

      await _auth.reauthenticateWithPassword(
        email: currentUser.email,
        password: password,
      );

      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    try {
      await _auth.deleteAccount();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Optional: Add some extension methods for easier state handling
extension AuthStateX on AsyncValue<AppUser?> {
  bool get isAuthenticated => hasValue && value != null;
  bool get isUnauthenticated => hasValue && value == null;
  bool get isVerified => isAuthenticated && value!.isEmailVerified;
  bool get isApproved => isAuthenticated && value!.isAdminApproved;
}
