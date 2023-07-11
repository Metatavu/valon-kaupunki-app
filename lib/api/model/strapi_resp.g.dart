// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strapi_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

StrapiImage _$StrapiImageFromJson(Map<String, dynamic> json) => StrapiImage(
      Image.fromJson(json['attributes'] as Map<String, dynamic>),
      json['id'] as int,
    );

Map<String, dynamic> _$StrapiImageToJson(StrapiImage instance) =>
    <String, dynamic>{
      'attributes': instance.image,
      'id': instance.id,
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
