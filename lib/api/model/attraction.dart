import "package:json_annotation/json_annotation.dart";
import "package:valon_kaupunki_app/api/model/location.dart";
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";

part "attraction.g.dart";

@JsonSerializable()
class Attraction {
  Attraction(
    this.title,
    this.category,
    this.subTitle,
    this.description,
    this.artist,
    this.link,
    this.address,
    this.location,
    this.imageData,
    this.soundData,
  );

  factory Attraction.fromJson(Map<String, dynamic> json) =>
      _$AttractionFromJson(json);

  final String title;
  final String category;
  final String subTitle;
  final String? description;
  final String? artist;
  final String? link;
  final String? address;
  final Location location;
  @JsonKey(name: "image")
  final ImageData imageData;
  @JsonKey(name: "sound")
  final SoundData soundData;

  StrapiImage? get image => imageData.data;
  StrapiSound? get sound => soundData.data;
}
