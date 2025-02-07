import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Social authentication
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithApple();
  // Future<AppUser> signInWithFacebook();
  // Future<AppUser> signInWithGithub();
  Future<List<AppAuthProvider>> checkEmailProviders(String email);
  Future<AppUser> getUserInfoFromCredential(OAuthCredential credential);

  // Delete account
  Future<void> deleteAccount();

  // Reauthentication methods
  Future<void> reauthenticateWithPassword({
    required String email,
    required String password,
  });

  Future<void> reauthenticateWithGoogle();
  Future<void> reauthenticateWithApple();
  // Future<void> reauthenticateWithFacebook();

  // Generic credential reauthentication
  Future<void> reauthenticateWithCredential(AuthCredential credential);

  // Provider linking methods
  Future<AppUser> linkProvider(AppAuthProvider provider);
  Future<AppUser> unlinkProvider(AppAuthProvider provider);
}
