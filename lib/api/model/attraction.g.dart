// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attraction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attraction _$AttractionFromJson(Map<String, dynamic> json) => Attraction(
      json['title'] as String,
      json['category'] as String,
      json['description'] as String?,
      json['artist'] as String?,
      json['link'] as String?,
      json['address'] as String?,
      Location.fromJson(json['location'] as Map<String, dynamic>),
      ImageData.fromJson(json['image'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AttractionToJson(Attraction instance) =>
    <String, dynamic>{
      'title': instance.title,
      'category': instance.category,
      'description': instance.description,
      'artist': instance.artist,
      'link': instance.link,
      'address': instance.address,
      'location': instance.location,
      'image': instance.data,
    };

ImageData _$ImageDataFromJson(Map<String, dynamic> json) => ImageData(
      StrapiImage.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ImageDataToJson(ImageData instance) => <String, dynamic>{
      'data': instance.data,
    };
