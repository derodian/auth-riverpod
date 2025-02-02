// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return _AppUser.fromJson(json);
}

/// @nodoc
mixin _$AppUser {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get profileBackgroundUrl => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  bool get isEmailVerified => throw _privateConstructorUsedError;
  bool get isAdminApproved => throw _privateConstructorUsedError;
  bool get isAdmin => throw _privateConstructorUsedError;
  AppAuthProvider get provider => throw _privateConstructorUsedError;
  List<String> get linkedProviders => throw _privateConstructorUsedError;
  Map<String, dynamic>? get providerData => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get lastLoginAt => throw _privateConstructorUsedError;
  @DateTimeConverter()
  DateTime get lastUpdatedAt => throw _privateConstructorUsedError;

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppUserCopyWith<AppUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) then) =
      _$AppUserCopyWithImpl<$Res, AppUser>;
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      String? phoneNumber,
      String? profileImageUrl,
      String? profileBackgroundUrl,
      String? address,
      bool isEmailVerified,
      bool isAdminApproved,
      bool isAdmin,
      AppAuthProvider provider,
      List<String> linkedProviders,
      Map<String, dynamic>? providerData,
      @DateTimeConverter() DateTime createdAt,
      @DateTimeConverter() DateTime lastLoginAt,
      @DateTimeConverter() DateTime lastUpdatedAt});
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res, $Val extends AppUser>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? phoneNumber = freezed,
    Object? profileImageUrl = freezed,
    Object? profileBackgroundUrl = freezed,
    Object? address = freezed,
    Object? isEmailVerified = null,
    Object? isAdminApproved = null,
    Object? isAdmin = null,
    Object? provider = null,
    Object? linkedProviders = null,
    Object? providerData = freezed,
    Object? createdAt = null,
    Object? lastLoginAt = null,
    Object? lastUpdatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      profileBackgroundUrl: freezed == profileBackgroundUrl
          ? _value.profileBackgroundUrl
          : profileBackgroundUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      isEmailVerified: null == isEmailVerified
          ? _value.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isAdminApproved: null == isAdminApproved
          ? _value.isAdminApproved
          : isAdminApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      isAdmin: null == isAdmin
          ? _value.isAdmin
          : isAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as AppAuthProvider,
      linkedProviders: null == linkedProviders
          ? _value.linkedProviders
          : linkedProviders // ignore: cast_nullable_to_non_nullable
              as List<String>,
      providerData: freezed == providerData
          ? _value.providerData
          : providerData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastLoginAt: null == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdatedAt: null == lastUpdatedAt
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppUserImplCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$$AppUserImplCopyWith(
          _$AppUserImpl value, $Res Function(_$AppUserImpl) then) =
      __$$AppUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      String? phoneNumber,
      String? profileImageUrl,
      String? profileBackgroundUrl,
      String? address,
      bool isEmailVerified,
      bool isAdminApproved,
      bool isAdmin,
      AppAuthProvider provider,
      List<String> linkedProviders,
      Map<String, dynamic>? providerData,
      @DateTimeConverter() DateTime createdAt,
      @DateTimeConverter() DateTime lastLoginAt,
      @DateTimeConverter() DateTime lastUpdatedAt});
}

/// @nodoc
class __$$AppUserImplCopyWithImpl<$Res>
    extends _$AppUserCopyWithImpl<$Res, _$AppUserImpl>
    implements _$$AppUserImplCopyWith<$Res> {
  __$$AppUserImplCopyWithImpl(
      _$AppUserImpl _value, $Res Function(_$AppUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? phoneNumber = freezed,
    Object? profileImageUrl = freezed,
    Object? profileBackgroundUrl = freezed,
    Object? address = freezed,
    Object? isEmailVerified = null,
    Object? isAdminApproved = null,
    Object? isAdmin = null,
    Object? provider = null,
    Object? linkedProviders = null,
    Object? providerData = freezed,
    Object? createdAt = null,
    Object? lastLoginAt = null,
    Object? lastUpdatedAt = null,
  }) {
    return _then(_$AppUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageUrl: freezed == profileImageUrl
          ? _value.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      profileBackgroundUrl: freezed == profileBackgroundUrl
          ? _value.profileBackgroundUrl
          : profileBackgroundUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      isEmailVerified: null == isEmailVerified
          ? _value.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isAdminApproved: null == isAdminApproved
          ? _value.isAdminApproved
          : isAdminApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      isAdmin: null == isAdmin
          ? _value.isAdmin
          : isAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as AppAuthProvider,
      linkedProviders: null == linkedProviders
          ? _value._linkedProviders
          : linkedProviders // ignore: cast_nullable_to_non_nullable
              as List<String>,
      providerData: freezed == providerData
          ? _value._providerData
          : providerData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastLoginAt: null == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdatedAt: null == lastUpdatedAt
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppUserImpl extends _AppUser {
  const _$AppUserImpl(
      {required this.id,
      required this.email,
      required this.name,
      this.phoneNumber,
      this.profileImageUrl,
      this.profileBackgroundUrl,
      this.address,
      this.isEmailVerified = false,
      this.isAdminApproved = false,
      this.isAdmin = false,
      this.provider = AppAuthProvider.email,
      final List<String> linkedProviders = const [],
      final Map<String, dynamic>? providerData,
      @DateTimeConverter() required this.createdAt,
      @DateTimeConverter() required this.lastLoginAt,
      @DateTimeConverter() required this.lastUpdatedAt})
      : _linkedProviders = linkedProviders,
        _providerData = providerData,
        super._();

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String name;
  @override
  final String? phoneNumber;
  @override
  final String? profileImageUrl;
  @override
  final String? profileBackgroundUrl;
  @override
  final String? address;
  @override
  @JsonKey()
  final bool isEmailVerified;
  @override
  @JsonKey()
  final bool isAdminApproved;
  @override
  @JsonKey()
  final bool isAdmin;
  @override
  @JsonKey()
  final AppAuthProvider provider;
  final List<String> _linkedProviders;
  @override
  @JsonKey()
  List<String> get linkedProviders {
    if (_linkedProviders is EqualUnmodifiableListView) return _linkedProviders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_linkedProviders);
  }

  final Map<String, dynamic>? _providerData;
  @override
  Map<String, dynamic>? get providerData {
    final value = _providerData;
    if (value == null) return null;
    if (_providerData is EqualUnmodifiableMapView) return _providerData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @DateTimeConverter()
  final DateTime createdAt;
  @override
  @DateTimeConverter()
  final DateTime lastLoginAt;
  @override
  @DateTimeConverter()
  final DateTime lastUpdatedAt;

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, name: $name, phoneNumber: $phoneNumber, profileImageUrl: $profileImageUrl, profileBackgroundUrl: $profileBackgroundUrl, address: $address, isEmailVerified: $isEmailVerified, isAdminApproved: $isAdminApproved, isAdmin: $isAdmin, provider: $provider, linkedProviders: $linkedProviders, providerData: $providerData, createdAt: $createdAt, lastLoginAt: $lastLoginAt, lastUpdatedAt: $lastUpdatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.profileBackgroundUrl, profileBackgroundUrl) ||
                other.profileBackgroundUrl == profileBackgroundUrl) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.isAdminApproved, isAdminApproved) ||
                other.isAdminApproved == isAdminApproved) &&
            (identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            const DeepCollectionEquality()
                .equals(other._linkedProviders, _linkedProviders) &&
            const DeepCollectionEquality()
                .equals(other._providerData, _providerData) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.lastUpdatedAt, lastUpdatedAt) ||
                other.lastUpdatedAt == lastUpdatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      name,
      phoneNumber,
      profileImageUrl,
      profileBackgroundUrl,
      address,
      isEmailVerified,
      isAdminApproved,
      isAdmin,
      provider,
      const DeepCollectionEquality().hash(_linkedProviders),
      const DeepCollectionEquality().hash(_providerData),
      createdAt,
      lastLoginAt,
      lastUpdatedAt);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      __$$AppUserImplCopyWithImpl<_$AppUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserImplToJson(
      this,
    );
  }
}

abstract class _AppUser extends AppUser {
  const factory _AppUser(
          {required final String id,
          required final String email,
          required final String name,
          final String? phoneNumber,
          final String? profileImageUrl,
          final String? profileBackgroundUrl,
          final String? address,
          final bool isEmailVerified,
          final bool isAdminApproved,
          final bool isAdmin,
          final AppAuthProvider provider,
          final List<String> linkedProviders,
          final Map<String, dynamic>? providerData,
          @DateTimeConverter() required final DateTime createdAt,
          @DateTimeConverter() required final DateTime lastLoginAt,
          @DateTimeConverter() required final DateTime lastUpdatedAt}) =
      _$AppUserImpl;
  const _AppUser._() : super._();

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get name;
  @override
  String? get phoneNumber;
  @override
  String? get profileImageUrl;
  @override
  String? get profileBackgroundUrl;
  @override
  String? get address;
  @override
  bool get isEmailVerified;
  @override
  bool get isAdminApproved;
  @override
  bool get isAdmin;
  @override
  AppAuthProvider get provider;
  @override
  List<String> get linkedProviders;
  @override
  Map<String, dynamic>? get providerData;
  @override
  @DateTimeConverter()
  DateTime get createdAt;
  @override
  @DateTimeConverter()
  DateTime get lastLoginAt;
  @override
  @DateTimeConverter()
  DateTime get lastUpdatedAt;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
