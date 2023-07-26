import "package:json_annotation/json_annotation.dart";
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";

part "benefit.g.dart";

@JsonSerializable()
class Benefit {
  final String title;
  final String benefitText;
  final String description;
  final DateTime? validFrom;
  final DateTime? validTo;
  final PartnerData? partner;
  @JsonKey(name: "image")
  final ImageData? data;

  const Benefit(this.title, this.benefitText, this.description, this.validFrom,
      this.validTo, this.data, this.partner);

  factory Benefit.fromJson(Map<String, dynamic> json) =>
      _$BenefitFromJson(json);

  StrapiImage? get image => data?.data;
}
