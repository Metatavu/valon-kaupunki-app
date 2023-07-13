// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Partner _$PartnerFromJson(Map<String, dynamic> json) => Partner(
      json['name'] as String,
      json['category'] as String,
      StrapiImageResponse.fromJson(json['image'] as Map<String, dynamic>),
      Location.fromJson(json['location'] as Map<String, dynamic>),
      StrapiBenefitResponse.fromJson(json['benefits'] as Map<String, dynamic>),
      json['description'] as String?,
      json['link'] as String?,
      json['address'] as String?,
    );

Map<String, dynamic> _$PartnerToJson(Partner instance) => <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'image': instance.image,
      'location': instance.location,
      'benefits': instance.benefits,
      'description': instance.description,
      'link': instance.link,
      'address': instance.address,
    };
