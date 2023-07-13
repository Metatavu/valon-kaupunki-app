// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'coordinates': instance.coordinates,
    };

Coordinates _$CoordinatesFromJson(Map<String, dynamic> json) => Coordinates(
      (json['lat'] as num).toDouble(),
      (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$CoordinatesToJson(Coordinates instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };
