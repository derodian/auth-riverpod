import 'package:auth_riverpod/src/features/auth/data/google_auth_service.dart';
import 'package:auth_riverpod/src/features/auth/data/reauthentication_required_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:auth_riverpod/src/features/auth/data/app_auth.dart';
import 'package:auth_riverpod/src/features/auth/data/app_user_storage_service.dart';
import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';

part 'firebase_auth_service.g.dart';

class FirebaseAuthService implements AppAuth {
  FirebaseAuthService(this._auth, this._userStorage);

  final FirebaseAuth _auth;
  final AppUserStorageService _userStorage;

  // Add social auth service fields
  final GoogleAuthService _googleAuth = GoogleAuthService();
  // final AppleAuthService _appleAuth = AppleAuthService();
  // final FacebookAuthService _facebookAuth = FacebookAuthService();

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _userStorage.getUser(user.uid);
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) {
      if (user == null) return null;
      return _userStorage.getUser(user.uid);
    });
  }

  @override
  Stream<bool> get isEmailVerified {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return false;

      // Force refresh the token to get latest email verification status
      await firebaseUser.reload();

      // Get latest Firebase Auth status
      final isVerifiedInAuth = firebaseUser.emailVerified;

      if (isVerifiedInAuth) {
        // Update Firestore if Firebase Auth shows verified
        final appUser = await _userStorage.getUser(firebaseUser.uid);
        if (appUser != null && !appUser.isEmailVerified) {
          final updatedUser = appUser.copyWith(
            isEmailVerified: true,
            lastUpdatedAt: DateTime.now(),
          );
          await _userStorage.updateUser(updatedUser);
        }
      }

      return isVerifiedInAuth;
    });
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('No user found after sign in');
      }

      // Update last login
      final user = await _userStorage.getUser(userCredential.user!.uid);
      if (user == null) throw Exception('User data not found');

      await _userStorage.updateLastLogin(user.id);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<AppUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      // Create AppUser
      final newUser = AppUser.create(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
      );

      // Save to storage
      await _userStorage.createUser(newUser);

      // Send email verification
      await sendEmailVerification();

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleAuth.signOut(),
      // _facebookAuth.signOut(),
      // Apple doesn't need sign out
    ]);
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user found');
    await user.sendEmailVerification();
  }

  // Add social sign-in methods
  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final credential = await _googleAuth.getGoogleCredential();
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('No user found after Google sign in');
      }

      return await _handleSocialSignIn(
        userCredential: userCredential,
        provider: AppAuthProvider.google,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  // Helper method to handle social sign-in
  Future<AppUser> _handleSocialSignIn({
    required UserCredential userCredential,
    required AppAuthProvider provider,
  }) async {
    final firebaseUser = userCredential.user!;
    final userData = userCredential.additionalUserInfo?.profile;

    // Check if user exists
    final existingUser = await _userStorage.getUser(firebaseUser.uid);

    if (existingUser != null) {
      // Update last login and return existing user
      await _userStorage.updateLastLogin(existingUser.id);
      return existingUser;
    }

    // Create new user
    final newUser = AppUser.fromSocialAuth(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      name: firebaseUser.displayName ?? firebaseUser.email!.split('@')[0],
      provider: provider,
      phoneNumber: firebaseUser.phoneNumber,
      profileImageUrl: firebaseUser.photoURL,
      providerData: userData,
    );

    // Save to storage
    await _userStorage.createUser(newUser);
    return newUser;
  }

  @override
  Future<AppUser> linkProvider(AppAuthProvider provider) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user found');

      AuthCredential? credential;
      switch (provider) {
        case AppAuthProvider.google:
          credential = await _googleAuth.getGoogleCredential();
          break;
        // case AppAuthProvider.apple:
        //   credential = await _appleAuth.getAppleCredential();
        //   break;
        // case AppAuthProvider.facebook:
        //   credential = await _facebookAuth.getFacebookCredential();
        //   break;
        // case AppAuthProvider.github:
        //   credential = await _githubAuth.getGithubCredential();
        // break;
        default:
          throw Exception('Unsupported provider for linking');
      }

      final result = await user.linkWithCredential(credential);
      if (result.user == null) throw Exception('Failed to link provider');

      // Get provider data from the result
      final providerData = result.additionalUserInfo?.profile;

      // Update user in Firestore
      // First update the provider data if available
      AppUser updatedUser;
      if (providerData != null) {
        updatedUser = await _userStorage.updateUserProviderData(
          result.user!.uid,
          providerData,
        );
      }

      // Then link the provider
      updatedUser = await _userStorage.linkProvider(
        result.user!.uid,
        provider,
      );

      return updatedUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<AppUser> unlinkProvider(AppAuthProvider provider) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user found');

      await user.unlink(provider.providerId);

      // Update user in Firestore
      final updatedUser = await _userStorage.unlinkProvider(
        user.uid,
        provider,
      );

      return updatedUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  AppAuthProvider _getProviderFromCredential(AuthCredential credential) {
    switch (credential.providerId) {
      case 'google.com':
        return AppAuthProvider.google;
      case 'apple.com':
        return AppAuthProvider.apple;
      case 'facebook.com':
        return AppAuthProvider.facebook;
      case 'github.com':
        return AppAuthProvider.github;
      default:
        return AppAuthProvider.email;
    }
  }

  @override
  Future<void> reload() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) throw Exception('No user found');

      // Reload Firebase Auth user
      await firebaseUser.reload();

      // If email is verified in Firebase Auth, update Firestore
      if (firebaseUser.emailVerified) {
        final appUser = await _userStorage.getUser(firebaseUser.uid);
        if (appUser != null && !appUser.isEmailVerified) {
          final updatedUser = appUser.copyWith(
            isEmailVerified: true,
            lastUpdatedAt: DateTime.now(),
          );
          await _userStorage.updateUser(updatedUser);
        }
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _auth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user found');
      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user found');
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user found');
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user found');

      // First delete from Firestore
      await _userStorage.deleteUser(user.uid);

      // Then delete the Firebase Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Add to existing reauthenticate method
  @override
  Future<void> reauthenticateWithCredential(AuthCredential credential) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user found');
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> reauthenticateWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user found');

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<void> reauthenticateWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user found');

      final credential = await _googleAuth.getGoogleCredential();
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to reauthenticate with Google: $e');
    }
  }

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'invalid-email':
        return Exception('Invalid email format');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later');
      case 'email-already-in-use':
        return Exception('An account already exists with this email');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'invalid-credential':
        return Exception('Invalid email or password');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection');
      case 'invalid-verification-code':
        return Exception('Invalid verification code');
      case 'invalid-verification-id':
        return Exception('Invalid verification ID');
      case 'requires-recent-login':
        return Exception('Please sign in again to complete this action');
      case 'account-exists-with-different-credential':
        return Exception(
            'An account already exists with the same email address but different sign-in credentials');
      case 'operation-not-allowed':
        return Exception('This sign-in provider is not enabled');
      case 'popup-blocked':
        return Exception('The popup was blocked by the browser');
      case 'popup-closed-by-user':
        return Exception(
            'The popup was closed by the user before finalizing the sign-in');
      case 'provider-already-linked':
        return Exception('This provider is already linked to your account');
      case 'no-such-provider':
        return Exception('This provider is not linked to your account');
      case 'credential-already-in-use':
        return Exception('This account is already linked to another user');
      default:
        return Exception(e.message ?? 'An unknown error occurred');
    }
  }
}

// Add provider ID extension
extension AppAuthProviderX on AppAuthProvider {
  String get providerId {
    switch (this) {
      case AppAuthProvider.google:
        return 'google.com';
      case AppAuthProvider.apple:
        return 'apple.com';
      case AppAuthProvider.facebook:
        return 'facebook.com';
      case AppAuthProvider.github:
        return 'github.com';
      case AppAuthProvider.email:
        return 'password';
    }
  }
}

@riverpod
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@riverpod
AppAuth authService(Ref ref) {
  return FirebaseAuthService(
    ref.watch(firebaseAuthProvider),
    ref.watch(appUserStorageServiceProvider.notifier),
  );
}
