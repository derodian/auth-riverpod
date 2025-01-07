import 'dart:io';

import 'package:auth_riverpod/src/features/account/presentation/profile_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_profile_form.g.dart';

@riverpod
class EditProfileForm extends _$EditProfileForm {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> submit({
    required String name,
    required String email,
    required String phone,
    required String address,
    File? profileImage,
    File? backgroundImage,
  }) async {
    state = const AsyncValue.loading();

    try {
      await ref.read(profileControllerProvider.notifier).updateProfile(
            name: name,
            email: email,
            phone: phone,
            address: address,
            profileImage: profileImage,
            backgroundImage: backgroundImage,
          );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
