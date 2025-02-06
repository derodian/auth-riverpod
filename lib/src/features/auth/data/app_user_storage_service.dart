import 'dart:io';

import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:auth_riverpod/src/util/image_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_user_storage_service.g.dart';

@riverpod
class AppUserStorageService extends _$AppUserStorageService {
  late final FirebaseFirestore _firestore;
  late final FirebaseStorage _storage;
  late final CollectionReference<Map<String, dynamic>> _usersCollection;

  @override
  Future<void> build() async {
    _firestore = FirebaseFirestore.instance;
    _storage = FirebaseStorage.instance;
    _usersCollection = _firestore.collection('users');
  }

  // Basic CRUD with Transactions

  Future<void> createUser(AppUser user) async {
    return _runTransactionSafely((transaction) async {
      final userDoc = _usersCollection.doc(user.id);
      final snapshot = await transaction.get(userDoc);

      if (snapshot.exists) {
        throw Exception('User already exists');
      }

      transaction.set(userDoc, user.toFirestore());
    });
  }

  // Method to handle user creation or update from social auth
  Future<AppUser> createOrUpdateSocialUser(AppUser user) async {
    return _runTransactionSafely((transaction) async {
      final userDoc = _usersCollection.doc(user.id);
      final snapshot = await transaction.get(userDoc);

      if (snapshot.exists) {
        // User exists, update last login and merge any new data
        final existingUser = snapshot.toAppUser();
        if (existingUser == null) throw Exception('Invalid user data');

        final updatedUser = existingUser.copyWith(
          lastLoginAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          // Update these fields only if they're empty in existing user
          name: existingUser.name.isEmpty ? user.name : existingUser.name,
          profileImageUrl: existingUser.profileImageUrl ?? user.profileImageUrl,
          phoneNumber: existingUser.phoneNumber ?? user.phoneNumber,
          // Always update these fields
          isEmailVerified: true, // Social auth emails are typically verified
          providerData: user.providerData,
        );

        transaction.update(userDoc, updatedUser.toFirestore());
        return updatedUser;
      } else {
        // New user, create with social auth data
        transaction.set(userDoc, user.toFirestore());
        return user;
      }
    });
  }

  // Method to link additional providers to existing user
  Future<AppUser> linkProvider(String userId, AppAuthProvider provider) async {
    return _runTransactionSafely((transaction) async {
      final userDoc = _usersCollection.doc(userId);
      final snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        throw Exception('User does not exist');
      }

      final existingUser = snapshot.toAppUser();
      if (existingUser == null) throw Exception('Invalid user data');

      // Update the user's linked providers
      final updatedProviders = [
        ...existingUser.linkedProviders
      ]; // Since it has default empty list
      if (!updatedProviders.contains(provider.name)) {
        updatedProviders.add(provider.name);
      }

      // Create updated user
      final updatedUser = existingUser.copyWith(
        linkedProviders: updatedProviders,
        lastUpdatedAt: DateTime.now(),
      );

      // Update in Firestore
      transaction.update(userDoc, updatedUser.toFirestore());

      return updatedUser;
    });
  }

  // Method to unlink provider
  Future<AppUser> unlinkProvider(
      String userId, AppAuthProvider provider) async {
    return _runTransactionSafely((transaction) async {
      final userDoc = _usersCollection.doc(userId);
      final snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        throw Exception('User does not exist');
      }

      final existingUser = snapshot.toAppUser();
      if (existingUser == null) throw Exception('Invalid user data');

      // Remove the provider from linked providers
      final updatedProviders = List<String>.from(existingUser.linkedProviders)
        ..remove(provider.name);

      // Prevent unlinking if it's the only provider
      if (updatedProviders.isEmpty) {
        throw Exception('Cannot unlink the only authentication method');
      }

      // Create updated user
      final updatedUser = existingUser.copyWith(
        linkedProviders: updatedProviders,
        lastUpdatedAt: DateTime.now(),
      );

      // Update in Firestore
      transaction.update(userDoc, updatedUser.toFirestore());

      return updatedUser;
    });
  }

  // Helper method to get user with updated provider data
  Future<AppUser> updateUserProviderData(
    String userId,
    Map<String, dynamic> providerData,
  ) async {
    return _runTransactionSafely((transaction) async {
      final userDoc = _usersCollection.doc(userId);
      final snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        throw Exception('User does not exist');
      }

      final existingUser = snapshot.toAppUser();
      if (existingUser == null) throw Exception('Invalid user data');

      // Create updated user
      final updatedUser = existingUser.copyWith(
        providerData: providerData,
        lastUpdatedAt: DateTime.now(),
      );

      // Update in Firestore
      transaction.update(userDoc, updatedUser.toFirestore());

      return updatedUser;
    });
  }

  // Optional: Helper method to get user's linked providers
  Future<List<String>> getLinkedProviders(String userId) async {
    return _runTransactionSafely((transaction) async {
      final userDoc = _usersCollection.doc(userId);
      final snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        throw Exception('User does not exist');
      }

      final existingUser = snapshot.toAppUser();
      if (existingUser == null) throw Exception('Invalid user data');

      return existingUser.linkedProviders;
    });
  }

  // Method to check if email exists (for preventing duplicate accounts)
  Future<bool> checkEmailExists(String email) async {
    try {
      final querySnapshot = await _usersCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  // Method to merge accounts if needed
  Future<void> mergeAccounts(
      String primaryUserId, String secondaryUserId) async {
    return _runTransactionSafely((transaction) async {
      final primaryDoc = _usersCollection.doc(primaryUserId);
      final secondaryDoc = _usersCollection.doc(secondaryUserId);

      final primarySnapshot = await transaction.get(primaryDoc);
      final secondarySnapshot = await transaction.get(secondaryDoc);

      if (!primarySnapshot.exists || !secondarySnapshot.exists) {
        throw Exception('One or both users do not exist');
      }

      final primaryUser = primarySnapshot.toAppUser();
      final secondaryUser = secondarySnapshot.toAppUser();

      if (primaryUser == null || secondaryUser == null) {
        throw Exception('Invalid user data');
      }

      // Merge user data
      final mergedProviders = <String>{
        ...List<String>.from(primaryUser.linkedProviders ?? []),
        ...List<String>.from(secondaryUser.linkedProviders ?? []),
      }.toList(); // Convert to Set and back to List to remove duplicates

      final mergedUser = primaryUser.copyWith(
        linkedProviders: mergedProviders,
        lastUpdatedAt: DateTime.now(),
      );

      // Update primary user with merged data
      transaction.update(primaryDoc, mergedUser.toFirestore());

      // Delete secondary user
      transaction.delete(secondaryDoc);
    });
  }

  Future<void> updateUser(AppUser user) async {
    return _runTransactionSafely((transaction) async {
      final userDoc = _usersCollection.doc(user.id);
      final snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        throw Exception('User does not exist');
      }

      transaction.update(userDoc, user.toFirestore());
    });
  }

  Future<AppUser?> getUser(String userId) async {
    return _runTransactionSafely((transaction) async {
      final snapshot = await transaction.get(_usersCollection.doc(userId));
      return snapshot.toAppUser();
    });
  }

  Future<void> deleteUser(String userId) async {
    // return _runTransactionSafely((transaction) async {
    //   final userDoc = _usersCollection.doc(userId);
    //   final snapshot = await transaction.get(userDoc);

    //   if (!snapshot.exists) {
    //     throw Exception('User does not exist');
    //   }

    //   transaction.delete(userDoc);
    // });
    try {
      await _usersCollection.doc(userId).delete();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  Stream<AppUser?> watchUser(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.toAppUser();
    });
  }

  Future<void> updateLastLogin(String userId) async {
    await _usersCollection.doc(userId).update({
      'lastLoginAt': Timestamp.now(),
    });
  }

  // Complex Transactions

  Future<void> updateUserWithRelatedData({
    required AppUser user,
    required Map<String, dynamic> additionalData,
    required String relatedCollectionPath,
  }) async {
    return _runTransactionSafely((transaction) async {
      final userDoc = _usersCollection.doc(user.id);
      final userSnapshot = await transaction.get(userDoc);

      if (!userSnapshot.exists) {
        throw Exception('User does not exist');
      }

      final relatedDoc = _firestore.doc(relatedCollectionPath);
      final relatedSnapshot = await transaction.get(relatedDoc);

      if (!relatedSnapshot.exists) {
        throw Exception('Related document does not exist');
      }

      transaction.update(userDoc, user.toFirestore());
      transaction.update(relatedDoc, additionalData);
    });
  }

  Future<void> updateEmailVerificationStatus(
      String userId, bool isVerified) async {
    return _firestore.runTransaction((transaction) async {
      final userDoc = _usersCollection.doc(userId);
      final snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        throw Exception('User does not exist');
      }

      transaction.update(userDoc, {
        'isEmailVerified': isVerified,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Image Upload Methods with Transactions
  Future<String> uploadProfileImage(String userId, File image) async {
    try {
      // Compress image before upload
      final compressedImage = await ImageUtils.compressImage(image);
      if (compressedImage == null) {
        throw Exception('Failed to compress image');
      }

      return await _firestore.runTransaction<String>((transaction) async {
        // Check if user exists
        final userDoc = _usersCollection.doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists) {
          throw Exception('User does not exist');
        }

        // Create storage reference
        final storageRef = _storage.ref().child('users/$userId/profile.jpg');

        // Delete old image if exists
        try {
          final oldImageUrl =
              userSnapshot.data()?['profileImageUrl'] as String?;
          if (oldImageUrl != null) {
            await _storage.refFromURL(oldImageUrl).delete();
          }
        } catch (e) {
          debugPrint('Error deleting old profile image: $e');
        }
        // Upload new image
        final uploadTask = await storageRef.putFile(
          compressedImage,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
              'userId': userId,
            },
          ),
        );

        // Get download URL
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        // Update user document with new image URL
        transaction.update(userDoc, {
          'profileImageUrl': downloadUrl,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });

        return downloadUrl;
      });
    } on FirebaseException catch (e) {
      throw _handleStorageException(e);
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<String> uploadProfileBackground(String userId, File image) async {
    try {
      // Compress image before upload
      final compressedImage = await ImageUtils.compressImage(image);
      if (compressedImage == null) {
        throw Exception('Failed to compress image');
      }

      return await _firestore.runTransaction<String>((transaction) async {
        // Check if user exists
        final userDoc = _usersCollection.doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists) {
          throw Exception('User does not exist');
        }

        // Create storage reference
        final storageRef = _storage.ref().child('users/$userId/background.jpg');

        // Delete old image if exists
        try {
          final oldImageUrl =
              userSnapshot.data()?['profileBackgroundUrl'] as String?;
          if (oldImageUrl != null) {
            await _storage.refFromURL(oldImageUrl).delete();
          }
        } catch (e) {
          debugPrint('Error deleting old background image: $e');
        }
        // Upload new image
        final uploadTask = await storageRef.putFile(
          compressedImage,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
              'userId': userId,
            },
          ),
        );

        // Get download URL
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        // Update user document with new image URL
        transaction.update(userDoc, {
          'profileBackgroundUrl': downloadUrl,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });

        return downloadUrl;
      });
    } on FirebaseException catch (e) {
      throw _handleStorageException(e);
    } catch (e) {
      throw Exception('Failed to upload profile background: $e');
    }
  }

  // Delete image methods with Transactions
  Future<void> deleteProfileImage(String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = _usersCollection.doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists) {
          throw Exception('User does not exist');
        }

        final imageUrl = userSnapshot.data()?['profileImageUrl'] as String?;
        if (imageUrl != null) {
          // Delete from storage
          await _storage.refFromURL(imageUrl).delete();

          // Update user document
          transaction.update(userDoc, {
            'profileImageUrl': FieldValue.delete(),
            'lastUpdatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } on FirebaseException catch (e) {
      throw _handleStorageException(e);
    }
  }

  Future<void> deleteProfileBackground(String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = _usersCollection.doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists) {
          throw Exception('User does not exist');
        }

        final imageUrl =
            userSnapshot.data()?['profileBackgroundUrl'] as String?;
        if (imageUrl != null) {
          // Delete from storage
          await _storage.refFromURL(imageUrl).delete();

          // Update user document
          transaction.update(userDoc, {
            'profileBackgroundUrl': FieldValue.delete(),
            'lastUpdatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } on FirebaseException catch (e) {
      throw _handleStorageException(e);
    }
  }

  // Batch delete all user images
  Future<void> deleteAllUserImages(String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = _usersCollection.doc(userId);
        final userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists) {
          throw Exception('User does not exist');
        }

        final data = userSnapshot.data()!;
        final profileImageUrl = data['profileImageUrl'] as String?;
        final backgroundImageUrl = data['profileBackgroundUrl'] as String?;

        // Delete images from storage
        if (profileImageUrl != null) {
          await _storage.refFromURL(profileImageUrl).delete();
        }
        if (backgroundImageUrl != null) {
          await _storage.refFromURL(backgroundImageUrl).delete();
        }

        // Update user document
        transaction.update(userDoc, {
          'profileImageUrl': FieldValue.delete(),
          'profileBackgroundUrl': FieldValue.delete(),
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw _handleStorageException(e);
    }
  }

  // Helper method to safely delete a storage file
  Future<void> _safeDeleteStorageFile(String? imageUrl) async {
    if (imageUrl != null) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (e) {
        debugPrint('Error deleting storage file: $e');
      }
    }
  }

  // Update user with image URLs
  Future<void> updateUserImages(
    String userId, {
    String? profileImageUrl,
    String? backgroundImageUrl,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final userDoc = _usersCollection.doc(userId);
      final userSnapshot = await transaction.get(userDoc);

      if (!userSnapshot.exists) {
        throw Exception('User does not exist');
      }

      final updates = <String, dynamic>{
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };

      if (profileImageUrl != null) {
        updates['profileImageUrl'] = profileImageUrl;
      }
      if (backgroundImageUrl != null) {
        updates['profileBackgroundUrl'] = backgroundImageUrl;
      }

      transaction.update(userDoc, updates);
    });
  }

  // Batch Operations

  Future<void> batchCreateUsers(List<AppUser> users) async {
    try {
      const maxBatchSize = 500;

      for (var i = 0; i < users.length; i += maxBatchSize) {
        final batch = _firestore.batch();
        final chunk = users.skip(i).take(maxBatchSize);

        for (final user in chunk) {
          final userDoc = _usersCollection.doc(user.id);
          batch.set(userDoc, user.toFirestore());
        }

        await batch.commit();
      }
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  Future<void> batchUpdateUsers(List<AppUser> users) async {
    try {
      const maxBatchSize = 500;

      for (var i = 0; i < users.length; i += maxBatchSize) {
        final batch = _firestore.batch();
        final chunk = users.skip(i).take(maxBatchSize);

        for (final user in chunk) {
          final userDoc = _usersCollection.doc(user.id);
          batch.update(userDoc, user.toFirestore());
        }

        await batch.commit();
      }
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  Future<void> batchDeleteUsers(List<String> userIds) async {
    try {
      const maxBatchSize = 500;

      for (var i = 0; i < userIds.length; i += maxBatchSize) {
        final batch = _firestore.batch();
        final chunk = userIds.skip(i).take(maxBatchSize);

        for (final userId in chunk) {
          final userDoc = _usersCollection.doc(userId);
          batch.delete(userDoc);
        }

        await batch.commit();
      }
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  // Atomic Counter Updates
  Future<void> incrementUserMetric(String userId, String field) async {
    return _runTransactionSafely((transaction) async {
      final userDoc = _usersCollection.doc(userId);
      final snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        throw Exception('User does not exist');
      }

      final currentValue = snapshot.data()?[field] ?? 0;
      transaction.update(userDoc, {field: currentValue + 1});
    });
  }

  // Conditional Updates
  Future<void> updateUserIfNotModified(
    AppUser user,
    DateTime lastKnownUpdate,
  ) async {
    return _runTransactionSafely((transaction) async {
      final userDoc = _usersCollection.doc(user.id);
      final snapshot = await transaction.get(userDoc);

      if (!snapshot.exists) {
        throw Exception('User does not exist');
      }

      final currentUser = snapshot.toAppUser();
      if (currentUser == null) {
        throw Exception('Invalid user data');
      }

      if (currentUser.lastUpdatedAt != lastKnownUpdate) {
        throw Exception('User has been modified');
      }

      transaction.update(userDoc, user.toFirestore());
    });
  }

  // Stream with Transactions
  Stream<AppUser?> watchUserWithTransactions(String userId) {
    return _usersCollection.doc(userId).snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists) return null;

      return await _runTransactionSafely((transaction) async {
        final user = snapshot.toAppUser();
        if (user == null) return null;

        // You could fetch additional data here if needed
        return user;
      });
    });
  }

  // Helper methods for error handling
  Future<T> _runTransactionSafely<T>(
    Future<T> Function(Transaction transaction) action,
  ) async {
    try {
      return await _firestore.runTransaction(action);
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    }
  }

  // Add retry mechanism for uploads
  Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        if (attempts >= maxAttempts) rethrow;
        await Future.delayed(delay * attempts);
      }
    }
  }

  Exception _handleFirestoreException(FirebaseException e) {
    switch (e.code) {
      case 'not-found':
        return Exception('Document not found');
      case 'already-exists':
        return Exception('Document already exists');
      case 'permission-denied':
        return Exception('Permission denied');
      case 'aborted':
        return Exception('Transaction was aborted');
      case 'cancelled':
        return Exception('Operation was cancelled');
      case 'deadline-exceeded':
        return Exception('Operation timed out');
      case 'failed-precondition':
        return Exception('Operation failed due to server state');
      case 'unavailable':
        return Exception('Service is currently unavailable');
      default:
        return Exception(e.message ?? 'Unknown error occurred');
    }
  }

  // Helper method to handle storage exceptions
  Exception _handleStorageException(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
        return Exception('Unauthorized to perform this action');
      case 'canceled':
        return Exception('Upload was canceled');
      case 'storage/retry-limit-exceeded':
        return Exception('Upload failed: too many retries');
      case 'storage/invalid-checksum':
        return Exception('Upload failed: file integrity check failed');
      case 'storage/unknown':
        return Exception('An unknown error occurred');
      default:
        return Exception(e.message ?? 'An error occurred during upload');
    }
  }
}
