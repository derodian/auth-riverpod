// lib/core/models/app_user.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

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
  }) {
    final now = DateTime.now();
    return AppUser(
      id: id,
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      createdAt: now,
      lastLoginAt: now,
      lastUpdatedAt: now,
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
