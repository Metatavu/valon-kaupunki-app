// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavouriteUser _$FavouriteUserFromJson(Map<String, dynamic> json) =>
    FavouriteUser(
      json['deviceIdentifier'] as String,
      FavouriteUserData.fromJson(json['attraction'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FavouriteUserToJson(FavouriteUser instance) =>
    <String, dynamic>{
      'deviceIdentifier': instance.deviceIdentifier,
      'attraction': instance.attraction,
    };

FavouriteUserData _$FavouriteUserDataFromJson(Map<String, dynamic> json) =>
    FavouriteUserData(
      OnlyId.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FavouriteUserDataToJson(FavouriteUserData instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
