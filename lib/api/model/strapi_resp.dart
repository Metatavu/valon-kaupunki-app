// Has some of the common properties of all successful responses.
import "package:json_annotation/json_annotation.dart";
import "package:valon_kaupunki_app/api/model/attraction.dart";
import "package:valon_kaupunki_app/api/model/benefit.dart";
import "package:valon_kaupunki_app/api/model/image.dart";
import "package:valon_kaupunki_app/api/model/partner.dart";

part "strapi_resp.g.dart";

@JsonSerializable()
class ImageData {
  final StrapiImage? data;

  const ImageData(this.data);

  factory ImageData.fromJson(Map<String, dynamic> json) =>
      _$ImageDataFromJson(json);
}

@JsonSerializable()
class PartnerData {
  final StrapiPartner? data;

  const PartnerData(this.data);

  factory PartnerData.fromJson(Map<String, dynamic> json) =>
      _$PartnerDataFromJson(json);
}

@JsonSerializable()
class StrapiAttraction {
  @JsonKey(name: "attributes")
  Attraction attraction;
  int id;

  StrapiAttraction(this.attraction, this.id);

  factory StrapiAttraction.fromJson(Map<String, dynamic> json) =>
      _$StrapiAttractionFromJson(json);
}

@JsonSerializable()
class StrapiAttractionResponse {
  final List<StrapiAttraction> data;
  final StrapiResponseMeta meta;

  const StrapiAttractionResponse(this.data, this.meta);

  factory StrapiAttractionResponse.fromJson(Map<String, dynamic> json) =>
      _$StrapiAttractionResponseFromJson(json);
}

@JsonSerializable()
class StrapiBenefit {
  @JsonKey(name: "attributes")
  final Benefit benefit;
  final int id;

  const StrapiBenefit(this.benefit, this.id);

  factory StrapiBenefit.fromJson(Map<String, dynamic> json) =>
      _$StrapiBenefitFromJson(json);
}

@JsonSerializable()
class StrapiBenefitResponse {
  final List<StrapiBenefit> data;
  final StrapiResponseMeta? meta;

  const StrapiBenefitResponse(this.data, this.meta);

  factory StrapiBenefitResponse.fromJson(Map<String, dynamic> json) =>
      _$StrapiBenefitResponseFromJson(json);
}

@JsonSerializable()
class StrapiPartner {
  @JsonKey(name: "attributes")
  final Partner partner;
  final int id;

  const StrapiPartner(this.partner, this.id);

  factory StrapiPartner.fromJson(Map<String, dynamic> json) =>
      _$StrapiPartnerFromJson(json);
}

@JsonSerializable()
class StrapiPartnerResponse {
  final List<StrapiPartner> data;
  final StrapiResponseMeta meta;

  const StrapiPartnerResponse(this.data, this.meta);

  factory StrapiPartnerResponse.fromJson(Map<String, dynamic> json) =>
      _$StrapiPartnerResponseFromJson(json);
}

@JsonSerializable()
class StrapiImage {
  @JsonKey(name: "attributes")
  final Image image;
  final int id;

  StrapiImage(this.image, this.id);

  factory StrapiImage.fromJson(Map<String, dynamic> json) =>
      _$StrapiImageFromJson(json);
}

@JsonSerializable()
class StrapiImageResponse {
  final StrapiImage data;

  const StrapiImageResponse(this.data);

  factory StrapiImageResponse.fromJson(Map<String, dynamic> json) =>
      _$StrapiImageResponseFromJson(json);
}

// The meta object in the response.
// I would implement this directly as flattened values in the response object,
// but dart's json_serialization *chose* not to support this.
@JsonSerializable()
class StrapiResponseMeta {
  int get page => pagination.page;
  int get pageSize => pagination.pageSize;
  int get pageCount => pagination.pageCount;
  int get total => pagination.total;
  Pagination pagination;

  StrapiResponseMeta(this.pagination);

  factory StrapiResponseMeta.fromJson(Map<String, dynamic> json) =>
      _$StrapiResponseMetaFromJson(json);
}

// The inner pagination object of the response meta.
@JsonSerializable()
class Pagination {
  final int page;
  final int pageSize;
  final int pageCount;
  final int total;

  Pagination(this.page, this.pageSize, this.pageCount, this.total);

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
}
