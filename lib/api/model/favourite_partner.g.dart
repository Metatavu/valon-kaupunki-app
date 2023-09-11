// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavouritePartner _$FavouritePartnerFromJson(Map<String, dynamic> json) =>
    FavouritePartner(
      json['deviceIdentifier'] as String,
      json['partner'] == null
          ? null
          : FavouritePartnerData.fromJson(
              json['partner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FavouritePartnerToJson(FavouritePartner instance) =>
    <String, dynamic>{
      'deviceIdentifier': instance.deviceIdentifier,
      'partner': instance.partner,
    };

FavouritePartnerData _$FavouritePartnerDataFromJson(
        Map<String, dynamic> json) =>
    FavouritePartnerData(
      OnlyId.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FavouritePartnerDataToJson(
        FavouritePartnerData instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
