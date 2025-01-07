// lib/core/services/auth/firebase_auth_service.dart
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
    await _auth.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user found');
    await user.sendEmailVerification();
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
    } catch (e) {
      throw Exception(e.toString());
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
      case 'operation-not-allowed':
        return Exception('Email/password sign in is not enabled');
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
      default:
        return Exception(e.message ?? 'An unknown error occurred');
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
