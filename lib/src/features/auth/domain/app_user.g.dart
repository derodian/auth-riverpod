// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      profileBackgroundUrl: json['profileBackgroundUrl'] as String?,
      address: json['address'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isAdminApproved: json['isAdminApproved'] as bool? ?? false,
      isAdmin: json['isAdmin'] as bool? ?? false,
      createdAt:
          const DateTimeConverter().fromJson(json['createdAt'] as String),
      lastLoginAt:
          const DateTimeConverter().fromJson(json['lastLoginAt'] as String),
      lastUpdatedAt:
          const DateTimeConverter().fromJson(json['lastUpdatedAt'] as String),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'profileImageUrl': instance.profileImageUrl,
      'profileBackgroundUrl': instance.profileBackgroundUrl,
      'address': instance.address,
      'isEmailVerified': instance.isEmailVerified,
      'isAdminApproved': instance.isAdminApproved,
      'isAdmin': instance.isAdmin,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'lastLoginAt': const DateTimeConverter().toJson(instance.lastLoginAt),
      'lastUpdatedAt': const DateTimeConverter().toJson(instance.lastUpdatedAt),
    };
