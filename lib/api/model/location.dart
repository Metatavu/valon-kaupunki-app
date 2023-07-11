import "package:json_annotation/json_annotation.dart";
import "package:latlong2/latlong.dart";

part "location.g.dart";

@JsonSerializable()
class Location {
  final Coordinates coordinates;

  double get lat => coordinates.lat;
  double get lng => coordinates.lng;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Location(this.coordinates);

  LatLng toMarkerType() => LatLng(lat, lng);
}

@JsonSerializable()
class Coordinates {
  final double lat;
  final double lng;

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);

  Coordinates(this.lat, this.lng);
}
