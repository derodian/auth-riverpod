import 'dart:async';

import 'package:auth_riverpod/src/features/auth/data/app_auth.dart';
import 'package:auth_riverpod/src/features/auth/data/firebase_auth_service.dart';
import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:auth_riverpod/src/services/snackbar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  AppAuth get _auth => ref.watch(authServiceProvider);
  StreamSubscription<AppUser?>? _userSubscription;
  StreamSubscription<bool>? _emailVerificationSubscription;
  bool _disposed = false;
  bool _isReauthenticating = false;

  // Add this getter for the router
  bool get isReauthenticating => _isReauthenticating;

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

  Future<void> signInEmail(String email, String password) async {
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
    try {
      // Check providers before attempting sign up
      final providers = await checkEmailProviders(email);
      if (providers.isNotEmpty) {
        throw Exception('Email already registered with other providers');
      }

      state = const AsyncValue.loading();
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

  // Update signOut to handle all providers
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _auth.signOut();
      if (!_disposed) {
        state = const AsyncData(null);
      }
    } catch (e, st) {
      debugPrint('AuthController: Sign out error - $e');
      if (!_disposed) {
        state = AsyncError(e, st);
      }
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _auth.sendPasswordResetEmail(email);
      // Add success message after successful operation
      SnackBarService.showSuccess(
        'Password reset link sent to $email. Please check your email.',
      );
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

  Future<void> signInWithSocialProvider(AppAuthProvider provider) async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    try {
      AppUser user;
      switch (provider) {
        case AppAuthProvider.google:
          user = await _auth.signInWithGoogle();
          break;
        case AppAuthProvider.apple:
          user = await _auth.signInWithApple();
          break;
        default:
          throw UnimplementedError('Provider not supported');
      }
      state = AsyncData(user);
    } on FirebaseAuthException catch (e) {
      state = AsyncError(_handleFirebaseError(e), StackTrace.current);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // Add social sign-in methods
  Future<void> signInWithGoogle() async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    try {
      final user = await _auth.signInWithGoogle();
      if (!_disposed) {
        state = AsyncData(user);
      }
    } catch (e, st) {
      debugPrint('AuthController: Google sign in error - $e');
      if (!_disposed) {
        state = AsyncError(e, st);
      }
    }
  }

  // Add social sign-in methods
  Future<void> signInWithApple() async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();

    try {
      final user = await _auth.signInWithApple();
      if (!_disposed) {
        state = AsyncData(user);
      }
    } catch (e, st) {
      debugPrint('AuthController: Apple sign in error - $e');
      if (!_disposed) {
        state = AsyncError(e, st);
      }
    }
  }

  // Add provider linking methods
  Future<void> linkProvider(AppAuthProvider provider) async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    try {
      final user = await _auth.linkProvider(provider);
      if (!_disposed) {
        state = AsyncData(user);
      }
    } catch (e, st) {
      debugPrint('AuthController: Provider linking error - $e');
      if (!_disposed) {
        state = AsyncError(e, st);
      }
    }
  }

  Future<void> unlinkProvider(AppAuthProvider provider) async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    try {
      final currentUser = state.valueOrNull;
      if (currentUser == null) {
        throw Exception('No user is signed in');
      }

      // Prevent unlinking if it's the only provider
      if (currentUser.linkedProviders.length <= 1) {
        throw Exception('Cannot unlink the only authentication method');
      }

      final user = await _auth.unlinkProvider(provider);
      if (!_disposed) {
        state = AsyncData(user);
      }
    } catch (e, st) {
      debugPrint('AuthController: Provider unlinking error - $e');
      if (!_disposed) {
        state = AsyncError(e, st);
      }
    }
  }

  Future<void> deleteAccount() async {
    try {
      state = const AsyncLoading();
      await _auth.deleteAccount();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // Update other reauthentication methods similarly
  Future<void> reauthenticateWithProvider(AppAuthProvider provider) async {
    debugPrint('AuthController: Starting provider reauthentication');
    try {
      _isReauthenticating = true; // Set flag before authentication
      await _reauthenticateWithProvider(provider);
      debugPrint('AuthController: Reauthentication successful');
    } catch (e) {
      debugPrint('AuthController: Reauthentication failed: $e');
      rethrow;
    } finally {
      _isReauthenticating = false; // Clear flag after authentication
    }
  }

  Future<void> reauthenticateWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncLoading();
      await _auth.reauthenticateWithPassword(
        email: email,
        password: password,
      );
      // Don't update state on success to maintain current user
    } catch (e) {
      // Don't update error state, just rethrow for handling in UI
      rethrow;
    }
  }

  Future<void> _reauthenticateWithProvider(AppAuthProvider provider) async {
    switch (provider) {
      case AppAuthProvider.google:
        await _auth.reauthenticateWithGoogle();
        break;
      case AppAuthProvider.apple:
        await _auth.reauthenticateWithApple();
        break;
      case AppAuthProvider.facebook:
        // await _auth.reauthenticateWithFacebook();
        break;
      case AppAuthProvider.github:
        // await _auth.reauthenticateWithGithub();
        break;
      case AppAuthProvider.email:
        throw Exception('Email authentication requires email and password');
    }
  }

  Future<List<AppAuthProvider>> checkEmailProviders(String email) async {
    try {
      debugPrint('Checking providers for email: $email');
      final providers = await _auth.checkEmailProviders(email);
      debugPrint('Found providers: $providers');
      return providers;
    } catch (e, st) {
      debugPrint('Error checking providers: $e');
      // Don't update error state for validation checks
      // state = AsyncError(e, st);
      rethrow;
    }
  }

  String _handleFirebaseError(FirebaseAuthException e) {
    return switch (e.code) {
      'account-exists-with-different-credential' =>
        'An account already exists with this email. Try signing in with a different method.',
      'popup-blocked' =>
        'Sign in popup was blocked. Please allow popups and try again.',
      'popup-closed-by-user' => 'Sign in was cancelled.',
      'network-request-failed' =>
        'Network error. Please check your connection.',
      _ => e.message ?? 'An error occurred during sign in'
    };
  }
}

@riverpod
class DeletionState extends _$DeletionState {
  @override
  bool build() => false;

  void setDeleting(bool isDeleting) => state = isDeleting;
}

// Optional: Add some extension methods for easier state handling
extension AuthStateX on AsyncValue<AppUser?> {
  bool get isAuthenticated => hasValue && value != null;
  bool get isUnauthenticated => hasValue && value == null;
  bool get isVerified => isAuthenticated && value!.isEmailVerified;
  bool get isApproved => isAuthenticated && value!.isAdminApproved;

  // Add helper for providers
  List<String> get linkedProviders =>
      isAuthenticated ? value!.linkedProviders : const [];
  AppAuthProvider get mainProvider =>
      isAuthenticated ? value!.provider : AppAuthProvider.email;
}
