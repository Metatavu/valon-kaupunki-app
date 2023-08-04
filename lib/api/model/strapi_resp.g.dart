// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strapi_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageData _$ImageDataFromJson(Map<String, dynamic> json) => ImageData(
      json['data'] == null
          ? null
          : StrapiImage.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ImageDataToJson(ImageData instance) => <String, dynamic>{
      'data': instance.data,
    };

PartnerData _$PartnerDataFromJson(Map<String, dynamic> json) => PartnerData(
      json['data'] == null
          ? null
          : StrapiPartner.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PartnerDataToJson(PartnerData instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

SoundData _$SoundDataFromJson(Map<String, dynamic> json) => SoundData(
      json['data'] == null
          ? null
          : StrapiSound.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SoundDataToJson(SoundData instance) => <String, dynamic>{
      'data': instance.data,
    };

StrapiSound _$StrapiSoundFromJson(Map<String, dynamic> json) => StrapiSound(
      Sound.fromJson(json['attributes'] as Map<String, dynamic>),
      json['id'] as int,
    );

Map<String, dynamic> _$StrapiSoundToJson(StrapiSound instance) =>
    <String, dynamic>{
      'attributes': instance.sound,
      'id': instance.id,
    };

Sound _$SoundFromJson(Map<String, dynamic> json) => Sound(
      json['mime'] as String,
      json['url'] as String,
    );

Map<String, dynamic> _$SoundToJson(Sound instance) => <String, dynamic>{
      'mime': instance.mime,
      'url': instance.url,
    };

StrapiAttraction _$StrapiAttractionFromJson(Map<String, dynamic> json) =>
    StrapiAttraction(
      Attraction.fromJson(json['attributes'] as Map<String, dynamic>),
      json['id'] as int,
    );

Map<String, dynamic> _$StrapiAttractionToJson(StrapiAttraction instance) =>
    <String, dynamic>{
      'attributes': instance.attraction,
      'id': instance.id,
    };

OnlyId _$OnlyIdFromJson(Map<String, dynamic> json) => OnlyId(
      json['id'] as int,
    );

Map<String, dynamic> _$OnlyIdToJson(OnlyId instance) => <String, dynamic>{
      'id': instance.id,
    };

StrapiAttractionResponse _$StrapiAttractionResponseFromJson(
        Map<String, dynamic> json) =>
    StrapiAttractionResponse(
      (json['data'] as List<dynamic>)
          .map((e) => StrapiAttraction.fromJson(e as Map<String, dynamic>))
          .toList(),
      StrapiResponseMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StrapiAttractionResponseToJson(
        StrapiAttractionResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
    };

StrapiBenefit _$StrapiBenefitFromJson(Map<String, dynamic> json) =>
    StrapiBenefit(
      Benefit.fromJson(json['attributes'] as Map<String, dynamic>),
      json['id'] as int,
    );

Map<String, dynamic> _$StrapiBenefitToJson(StrapiBenefit instance) =>
    <String, dynamic>{
      'attributes': instance.benefit,
      'id': instance.id,
    };

StrapiBenefitResponse _$StrapiBenefitResponseFromJson(
        Map<String, dynamic> json) =>
    StrapiBenefitResponse(
      (json['data'] as List<dynamic>)
          .map((e) => StrapiBenefit.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['meta'] == null
          ? null
          : StrapiResponseMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StrapiBenefitResponseToJson(
        StrapiBenefitResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
    };

StrapiPartner _$StrapiPartnerFromJson(Map<String, dynamic> json) =>
    StrapiPartner(
      Partner.fromJson(json['attributes'] as Map<String, dynamic>),
      json['id'] as int,
    );

Map<String, dynamic> _$StrapiPartnerToJson(StrapiPartner instance) =>
    <String, dynamic>{
      'attributes': instance.partner,
      'id': instance.id,
    };

StrapiPartnerResponse _$StrapiPartnerResponseFromJson(
        Map<String, dynamic> json) =>
    StrapiPartnerResponse(
      (json['data'] as List<dynamic>)
          .map((e) => StrapiPartner.fromJson(e as Map<String, dynamic>))
          .toList(),
      StrapiResponseMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StrapiPartnerResponseToJson(
        StrapiPartnerResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
    };

StrapiImage _$StrapiImageFromJson(Map<String, dynamic> json) => StrapiImage(
      Image.fromJson(json['attributes'] as Map<String, dynamic>),
      json['id'] as int,
    );

Map<String, dynamic> _$StrapiImageToJson(StrapiImage instance) =>
    <String, dynamic>{
      'attributes': instance.image,
      'id': instance.id,
    };

StrapiImageResponse _$StrapiImageResponseFromJson(Map<String, dynamic> json) =>
    StrapiImageResponse(
      StrapiImage.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StrapiImageResponseToJson(
        StrapiImageResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

StrapiBenefitUser _$StrapiBenefitUserFromJson(Map<String, dynamic> json) =>
    StrapiBenefitUser(
      BenefitUser.fromJson(json['attributes'] as Map<String, dynamic>),
      json['id'] as int,
    );

Map<String, dynamic> _$StrapiBenefitUserToJson(StrapiBenefitUser instance) =>
    <String, dynamic>{
      'attributes': instance.benefitUser,
      'id': instance.id,
    };

StrapiBenefitUserResponse _$StrapiBenefitUserResponseFromJson(
        Map<String, dynamic> json) =>
    StrapiBenefitUserResponse(
      (json['data'] as List<dynamic>)
          .map((e) => StrapiBenefitUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['meta'] == null
          ? null
          : StrapiResponseMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StrapiBenefitUserResponseToJson(
        StrapiBenefitUserResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
    };

StrapiFavouriteUser _$StrapiFavouriteUserFromJson(Map<String, dynamic> json) =>
    StrapiFavouriteUser(
      FavouriteUser.fromJson(json['attributes'] as Map<String, dynamic>),
      json['id'] as int,
    );

Map<String, dynamic> _$StrapiFavouriteUserToJson(
        StrapiFavouriteUser instance) =>
    <String, dynamic>{
      'attributes': instance.favouriteUser,
      'id': instance.id,
    };

StrapiFavouriteUserResponse _$StrapiFavouriteUserResponseFromJson(
        Map<String, dynamic> json) =>
    StrapiFavouriteUserResponse(
      (json['data'] as List<dynamic>)
          .map((e) => StrapiFavouriteUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['meta'] == null
          ? null
          : StrapiResponseMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StrapiFavouriteUserResponseToJson(
        StrapiFavouriteUserResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
    };

StrapiResponseMeta _$StrapiResponseMetaFromJson(Map<String, dynamic> json) =>
    StrapiResponseMeta(
      Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StrapiResponseMetaToJson(StrapiResponseMeta instance) =>
    <String, dynamic>{
      'pagination': instance.pagination,
    };

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
      json['page'] as int,
      json['pageSize'] as int,
      json['pageCount'] as int,
      json['total'] as int,
    );

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'pageCount': instance.pageCount,
      'total': instance.total,
    };
