import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

enum AppAuthProvider {
  email,
  google,
  apple,
  facebook,
  github;

  String get providerId {
    switch (this) {
      case AppAuthProvider.email:
        return 'password';
      case AppAuthProvider.google:
        return 'google.com';
      case AppAuthProvider.apple:
        return 'apple.com';
      case AppAuthProvider.facebook:
        return 'facebook.com';
      case AppAuthProvider.github:
        return 'github.com';
    }
  }
}

// Create an interface for Firestore operations
abstract class FirestoreDoc {
  Map<String, dynamic> toFirestore();
}

@freezed
class AppUser with _$AppUser implements FirestoreDoc {
  const AppUser._(); // Add this line to implement custom methods

  const factory AppUser({
    required String id,
    required String email,
    required String name,
    String? phoneNumber,
    String? profileImageUrl,
    String? profileBackgroundUrl,
    String? address,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isAdminApproved,
    @Default(false) bool isAdmin,
    @Default(AppAuthProvider.email) AppAuthProvider provider,
    @Default([]) List<String> linkedProviders,
    Map<String, dynamic>? providerData,
    @DateTimeConverter() required DateTime createdAt,
    @DateTimeConverter() required DateTime lastLoginAt,
    @DateTimeConverter() required DateTime lastUpdatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  // Implement toFirestore method
  @override
  Map<String, dynamic> toFirestore() {
    final json = toJson()
      ..remove('id'); // Remove id as it's stored as document ID
    return {
      ...json,
      'provider': provider.name,
      'linkedProviders': linkedProviders,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
    };
  }

  // Factory constructor for Firestore
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser.fromJson({
      ...data,
      'id': doc.id,
      'provider': data['provider'] ?? AppAuthProvider.email.name,
      'linkedProviders': (data['linkedProviders'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'lastLoginAt':
          (data['lastLoginAt'] as Timestamp).toDate().toIso8601String(),
      'lastUpdatedAt':
          (data['lastUpdatedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  // Factory constructor for new users
  factory AppUser.create({
    required String id,
    required String email,
    required String name,
    String? phoneNumber,
    AppAuthProvider provider = AppAuthProvider.email,
    Map<String, dynamic>? providerData,
    String? profileImageUrl,
  }) {
    final now = DateTime.now();
    return AppUser(
      id: id,
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      provider: provider,
      linkedProviders: [provider.name],
      providerData: providerData,
      profileImageUrl: profileImageUrl,
      createdAt: now,
      lastLoginAt: now,
      lastUpdatedAt: now,
    );
  }

  // Factory constructor for social auth
  factory AppUser.fromSocialAuth({
    required String id,
    required String email,
    required String name,
    required AppAuthProvider provider,
    String? phoneNumber,
    String? profileImageUrl,
    Map<String, dynamic>? providerData,
  }) {
    final now = DateTime.now();
    return AppUser(
      id: id,
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      provider: provider,
      linkedProviders: [provider.name],
      providerData: providerData,
      profileImageUrl: profileImageUrl,
      isEmailVerified: true, // Social auth emails are typically verified
      createdAt: now,
      lastLoginAt: now,
      lastUpdatedAt: now,
    );
  }

  // Helper methods
  AppUser withUpdatedLoginTime() {
    return copyWith(
      lastLoginAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );
  }

  AppUser withUpdatedProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    String? profileBackgroundUrl,
  }) {
    return copyWith(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileBackgroundUrl: profileBackgroundUrl ?? this.profileBackgroundUrl,
      lastUpdatedAt: DateTime.now(),
    );
  }

  AppUser withEmailVerification(bool isVerified) {
    return copyWith(
      isEmailVerified: isVerified,
      lastUpdatedAt: DateTime.now(),
    );
  }

  AppUser withAdminApproval(bool isApproved) {
    return copyWith(
      isAdminApproved: isApproved,
      lastUpdatedAt: DateTime.now(),
    );
  }
}

// Extension method for DocumentSnapshot
extension FirestoreX on DocumentSnapshot<Map<String, dynamic>> {
  AppUser? toAppUser() {
    try {
      return AppUser.fromFirestore(this);
    } catch (e) {
      print('Error converting document to AppUser: $e');
      return null;
    }
  }
}

// DateTime converter for JSON serialization
class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

// Provider converter for JSON serialization
class AuthProviderConverter implements JsonConverter<AppAuthProvider, String> {
  const AuthProviderConverter();

  @override
  AppAuthProvider fromJson(String json) {
    return AppAuthProvider.values.firstWhere(
      (e) => e.name == json,
      orElse: () => AppAuthProvider.email,
    );
  }

  @override
  String toJson(AppAuthProvider provider) => provider.name;
}
