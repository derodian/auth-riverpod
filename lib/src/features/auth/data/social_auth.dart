import 'package:firebase_auth/firebase_auth.dart';

abstract class SocialAuthService {
  Future<OAuthCredential> getGoogleCredential();
  Future<void> signOut();
}
