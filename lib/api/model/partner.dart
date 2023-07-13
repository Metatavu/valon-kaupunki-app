import "package:json_annotation/json_annotation.dart";
import "package:valon_kaupunki_app/api/model/location.dart";
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";

part "partner.g.dart";

@JsonSerializable()
class Partner {
  final String name;
  final String category;
  final StrapiImageResponse image;
  final Location location;
  final StrapiBenefitResponse benefits;

  final String? description;
  final String? link;
  final String? address;

  Partner(this.name, this.category, this.image, this.location, this.benefits,
      this.description, this.link, this.address);

  factory Partner.fromJson(Map<String, dynamic> json) =>
      _$PartnerFromJson(json);
}
