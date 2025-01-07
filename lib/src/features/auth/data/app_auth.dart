import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';

abstract class AppAuth {
  // Current user getters
  Future<AppUser?> getCurrentUser();
  Stream<AppUser?> get authStateChanges;
  Stream<bool> get isEmailVerified;

  // Authentication methods
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  });

  Future<void> signOut();

  // Email verification
  Future<void> sendEmailVerification();
  Future<void> reload();

  // Password reset
  // Future<void> resetPassword(String email);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  });

  // Update profile
  Future<void> updateEmail(String newEmail);
  Future<void> updatePassword(String newPassword);
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  });

  // Delete account
  Future<void> deleteAccount();
  Future<void> reauthenticateWithPassword({
    required String email,
    required String password,
  });
}
