// lib/core/extensions/firebase_user_extension.dart
import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

extension FirebaseUserExtension on firebase.User {
  AppUser toAppUser({
    required String name,
    required String address,
    String? phoneNumber,
  }) {
    return AppUser.create(
      id: uid,
      email: email!,
      name: name,
      phoneNumber: phoneNumber,
    );
  }
}
