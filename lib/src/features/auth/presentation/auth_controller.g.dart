// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authControllerHash() => r'a87cdf4a216840ecc8c001671886e3d7a80507d1';

/// See also [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AppUser?>.internal(
  AuthController.new,
  name: r'authControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthController = AsyncNotifier<AppUser?>;
String _$deletionStateHash() => r'e8f415fe7518dc8006beff70bf0413aedbac7b57';

/// See also [DeletionState].
@ProviderFor(DeletionState)
final deletionStateProvider =
    AutoDisposeNotifierProvider<DeletionState, bool>.internal(
  DeletionState.new,
  name: r'deletionStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deletionStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeletionState = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
