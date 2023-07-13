// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Image _$ImageFromJson(Map<String, dynamic> json) => Image(
      json['width'] as int,
      json['height'] as int,
      json['url'] as String,
    );

Map<String, dynamic> _$ImageToJson(Image instance) => <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'url': instance.url,
    };
