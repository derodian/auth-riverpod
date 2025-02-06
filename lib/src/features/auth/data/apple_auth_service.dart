// apple_auth_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:auth_riverpod/src/features/auth/data/social_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService implements SocialAuthService {
  // Generate a random nonce for Apple Sign In
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  // Convert nonce to sha256 hash
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<OAuthCredential> getCredential() async {
    try {
      // Generate random nonce and its sha256 hash
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      final state = generateNonce();

      // Request credential for the Apple ID
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        state: state,
      );

      // Create OAuthCredential for Firebase
      return OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      throw 'AuthException: ${e.code.name}, ${e.message}';
    } catch (e) {
      throw 'Failed to sign in with Apple: $e';
    }
  }

  // Apple doesn't need explicit sign out as it's handled by the OS
  @override
  Future<void> signOut() async {
    // No implementation needed
    return;
  }

  // Helper method to format display name from Apple response
  String? formatFullName(AuthorizationCredentialAppleID credential) {
    final givenName = credential.givenName;
    final familyName = credential.familyName;

    if (givenName != null || familyName != null) {
      return [givenName, familyName].where((name) => name != null).join(' ');
    }
    return null;
  }
}
