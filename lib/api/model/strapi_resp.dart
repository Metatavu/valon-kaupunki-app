// Has some of the common properties of all successful responses.
import "dart:convert";

import "package:json_annotation/json_annotation.dart";
import "package:valon_kaupunki_app/api/model/attraction.dart";
import "package:valon_kaupunki_app/api/model/benefit.dart";
import "package:valon_kaupunki_app/api/model/image.dart";

part "strapi_resp.g.dart";

// implemented manually because of generics
class StrapiResponse<T> {
  final List<T?> data;
  final StrapiResponseMeta meta;

  StrapiResponse(this.data, this.meta);

  factory StrapiResponse.fromJson(Map<String, dynamic> json) => StrapiResponse(
        ((json["data"]) as List<dynamic>)
            .map((e) => StrapiAttraction.fromJson(e))
            .toList() as List<T?>,
        StrapiResponseMeta.fromJson(json["meta"]),
      );
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
class StrapiBenefit {
  @JsonKey(name: "attributes")
  final Benefit benefit;
  final int id;

  StrapiBenefit(this.benefit, this.id);

  factory StrapiBenefit.fromJson(Map<String, dynamic> json) =>
      _$StrapiBenefitFromJson(json);
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
