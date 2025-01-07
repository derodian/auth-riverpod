// import 'dart:io';

// import 'package:auth_riverpod/src/features/auth/data/app_user_storage_service.dart';
// import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
// import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
// import 'package:auth_riverpod/src/util/image_utils.dart';
// import 'package:auth_riverpod/src/util/retry_utils.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'profile_controller.g.dart';

// @riverpod
// class ProfileController extends _$ProfileController {
//   @override
//   AsyncValue<AppUser?> build() {
//     final currentUser = ref.watch(authControllerProvider).valueOrNull;
//     if (currentUser == null) return const AsyncValue.data(null);

//     return AsyncValue.data(currentUser);
//   }

//   Future<void> updateProfile({
//     required String name,
//     required String email,
//     required String phone,
//     required String address,
//     File? profileImage,
//     File? backgroundImage,
//   }) async {
//     state = const AsyncValue.loading();

//     try {
//       final currentUser = state.valueOrNull;
//       if (currentUser == null) throw Exception('No user found');

//       // Validate and potentially compress images
//       File? processedProfileImage;
//       File? processedBackgroundImage;

//       if (profileImage != null) {
//         final validation = await ImageUtils.validateImage(profileImage);
//         if (!validation.isValid) {
//           throw Exception(validation.error);
//         }
//         processedProfileImage = await ImageUtils.compressImage(profileImage);
//         if (processedProfileImage == null) {
//           throw Exception('Failed to process profile image');
//         }
//       }

//       if (backgroundImage != null) {
//         final validation = await ImageUtils.validateImage(backgroundImage);
//         if (!validation.isValid) {
//           throw Exception(validation.error);
//         }
//         processedBackgroundImage =
//             await ImageUtils.compressImage(backgroundImage);
//         if (processedBackgroundImage == null) {
//           throw Exception('Failed to process background image');
//         }
//       }

//       final storage = ref.read(appUserStorageServiceProvider.notifier);

//       // Upload processed images with retry
//       String? profileImageUrl;
//       String? backgroundImageUrl;

//       if (processedProfileImage != null) {
//         profileImageUrl = await retryOperation(
//           operation: () => storage.uploadProfileImage(
//             currentUser.id,
//             processedProfileImage!,
//           ),
//           maxAttempts: 3,
//           initialDelay: const Duration(seconds: 2),
//           retryIf: (error) {
//             // Only retry on specific errors
//             return error.toString().contains('network') ||
//                 error.toString().contains('timeout');
//           },
//         );
//       }

//       if (processedBackgroundImage != null) {
//         backgroundImageUrl = await retryOperation(
//           operation: () => storage.uploadProfileBackground(
//             currentUser.id,
//             processedBackgroundImage!,
//           ),
//           maxAttempts: 3,
//           initialDelay: const Duration(seconds: 2),
//           retryIf: (error) {
//             // Only retry on specific errors
//             return error.toString().contains('network') ||
//                 error.toString().contains('timeout');
//           },
//         );
//       }

//       // Update user data
//       final updatedUser = currentUser.copyWith(
//         name: name,
//         email: email,
//         phoneNumber: phone,
//         address: address,
//         profileImageUrl: profileImageUrl ?? currentUser.profileImageUrl,
//         profileBackgroundUrl:
//             backgroundImageUrl ?? currentUser.profileBackgroundUrl,
//         lastUpdatedAt: DateTime.now(),
//       );

//       await storage.updateUser(updatedUser);
//       state = AsyncValue.data(updatedUser);

//       // Cleanup temp files
//       await ImageUtils.cleanupTempFiles();
//     } catch (e, st) {
//       state = AsyncValue.error(e, st);
//     }
//   }
// }

// lib/features/profile/controllers/profile_controller.dart
import 'dart:io';
import 'package:auth_riverpod/src/features/auth/data/app_user_storage_service.dart';
import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/util/image_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<AppUser?> build() {
    // Watch the auth state to keep profile in sync
    return ref.watch(authControllerProvider).valueOrNull;
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
    File? profileImage,
    File? backgroundImage,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Get current user
      final currentUser = state.valueOrNull;
      if (currentUser == null) {
        throw Exception('Please sign in to update profile');
      }

      // Validate and potentially compress images
      File? processedProfileImage;
      File? processedBackgroundImage;

      if (profileImage != null) {
        final validation = await ImageUtils.validateImage(profileImage);
        if (!validation.isValid) {
          throw Exception(validation.error);
        }
        processedProfileImage = await ImageUtils.compressImage(profileImage);
        if (processedProfileImage == null) {
          throw Exception('Failed to process profile image');
        }
      }

      if (backgroundImage != null) {
        final validation = await ImageUtils.validateImage(backgroundImage);
        if (!validation.isValid) {
          throw Exception(validation.error);
        }
        processedBackgroundImage =
            await ImageUtils.compressImage(backgroundImage);
        if (processedBackgroundImage == null) {
          throw Exception('Failed to process background image');
        }
      }

      final storage = ref.read(appUserStorageServiceProvider.notifier);

      // Upload processed images
      String? profileImageUrl;
      String? backgroundImageUrl;

      if (processedProfileImage != null) {
        profileImageUrl = await storage.uploadProfileImage(
          currentUser.id,
          processedProfileImage,
        );
      }

      if (processedBackgroundImage != null) {
        backgroundImageUrl = await storage.uploadProfileBackground(
          currentUser.id,
          processedBackgroundImage,
        );
      }

      // Update user data
      final updatedUser = currentUser.copyWith(
        name: name,
        email: email,
        phoneNumber: phone,
        address: address,
        profileImageUrl: profileImageUrl ?? currentUser.profileImageUrl,
        profileBackgroundUrl:
            backgroundImageUrl ?? currentUser.profileBackgroundUrl,
        lastUpdatedAt: DateTime.now(),
      );

      await storage.updateUser(updatedUser);

      // Update the state with new user data
      state = AsyncValue.data(updatedUser);

      // Cleanup temp files
      await ImageUtils.cleanupTempFiles();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Add method to refresh user data
  Future<void> refreshProfile() async {
    state = const AsyncValue.loading();
    try {
      final currentUser = state.valueOrNull;
      if (currentUser == null) {
        throw Exception('No user found');
      }

      final storage = ref.read(appUserStorageServiceProvider.notifier);
      final updatedUser = await storage.getUser(currentUser.id);

      if (updatedUser == null) {
        throw Exception('Failed to fetch user data');
      }

      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Add method to delete profile image
  Future<void> deleteProfileImage() async {
    state = const AsyncValue.loading();
    try {
      final currentUser = state.valueOrNull;
      if (currentUser == null) {
        throw Exception('No user found');
      }

      final storage = ref.read(appUserStorageServiceProvider.notifier);
      await storage.deleteProfileImage(currentUser.id);

      // Refresh user data
      await refreshProfile();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Add method to delete background image
  Future<void> deleteProfileBackground() async {
    state = const AsyncValue.loading();
    try {
      final currentUser = state.valueOrNull;
      if (currentUser == null) {
        throw Exception('No user found');
      }

      final storage = ref.read(appUserStorageServiceProvider.notifier);
      await storage.deleteProfileBackground(currentUser.id);

      // Refresh user data
      await refreshProfile();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
