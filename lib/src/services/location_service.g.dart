// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$locationServiceHash() => r'656c951c27c11890bb58727952ecb6cde8a2100e';

/// See also [locationService].
@ProviderFor(locationService)
final locationServiceProvider = Provider<LocationService>.internal(
  locationService,
  name: r'locationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationServiceRef = ProviderRef<LocationService>;
String _$distanceToAddressHash() => r'781e0f2c10e797f71f67ebf7030fd0173edee482';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [distanceToAddress].
@ProviderFor(distanceToAddress)
const distanceToAddressProvider = DistanceToAddressFamily();

/// See also [distanceToAddress].
class DistanceToAddressFamily extends Family<AsyncValue<double?>> {
  /// See also [distanceToAddress].
  const DistanceToAddressFamily();

  /// See also [distanceToAddress].
  DistanceToAddressProvider call(
    String address,
  ) {
    return DistanceToAddressProvider(
      address,
    );
  }

  @override
  DistanceToAddressProvider getProviderOverride(
    covariant DistanceToAddressProvider provider,
  ) {
    return call(
      provider.address,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'distanceToAddressProvider';
}

/// See also [distanceToAddress].
class DistanceToAddressProvider extends AutoDisposeFutureProvider<double?> {
  /// See also [distanceToAddress].
  DistanceToAddressProvider(
    String address,
  ) : this._internal(
          (ref) => distanceToAddress(
            ref as DistanceToAddressRef,
            address,
          ),
          from: distanceToAddressProvider,
          name: r'distanceToAddressProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$distanceToAddressHash,
          dependencies: DistanceToAddressFamily._dependencies,
          allTransitiveDependencies:
              DistanceToAddressFamily._allTransitiveDependencies,
          address: address,
        );

  DistanceToAddressProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.address,
  }) : super.internal();

  final String address;

  @override
  Override overrideWith(
    FutureOr<double?> Function(DistanceToAddressRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DistanceToAddressProvider._internal(
        (ref) => create(ref as DistanceToAddressRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        address: address,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<double?> createElement() {
    return _DistanceToAddressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DistanceToAddressProvider && other.address == address;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, address.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DistanceToAddressRef on AutoDisposeFutureProviderRef<double?> {
  /// The parameter `address` of this provider.
  String get address;
}

class _DistanceToAddressProviderElement
    extends AutoDisposeFutureProviderElement<double?>
    with DistanceToAddressRef {
  _DistanceToAddressProviderElement(super.provider);

  @override
  String get address => (origin as DistanceToAddressProvider).address;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
