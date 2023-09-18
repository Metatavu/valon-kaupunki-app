import "package:json_annotation/json_annotation.dart";
import "package:valon_kaupunki_app/api/model/location.dart";
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";

part "partner.g.dart";

@JsonSerializable()
class Partner {
  Partner(
    this.name,
    this.category,
    this.location,
    this.description,
    this.link,
    this.address,
    this.imageData,
    this.benefitsData,
  );

  final String name;
  final String category;
  final Location location;

  final String? description;
  final String? link;
  final String? address;
  @JsonKey(name: "image")
  final ImageData? imageData;
  @JsonKey(name: "benefits")
  final BenefitData? benefitsData;

  factory Partner.fromJson(Map<String, dynamic> json) =>
      _$PartnerFromJson(json);

  StrapiImage? get image => imageData?.data;
  List<StrapiBenefit>? get benefits => benefitsData?.data;
}
