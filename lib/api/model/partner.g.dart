// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Partner _$PartnerFromJson(Map<String, dynamic> json) => Partner(
      json['name'] as String,
      json['category'] as String,
      Location.fromJson(json['location'] as Map<String, dynamic>),
      json['description'] as String?,
      json['link'] as String?,
      json['address'] as String?,
      json['image'] == null
          ? null
          : ImageData.fromJson(json['image'] as Map<String, dynamic>),
      json['benefits'] == null
          ? null
          : BenefitData.fromJson(json['benefits'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PartnerToJson(Partner instance) => <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'location': instance.location,
      'description': instance.description,
      'link': instance.link,
      'address': instance.address,
      'image': instance.imageData,
      'benefits': instance.benefitsData,
    };
