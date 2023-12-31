// Has some of the common properties of all successful responses.
import "package:json_annotation/json_annotation.dart";
import "package:valon_kaupunki_app/api/model/attraction.dart";
import "package:valon_kaupunki_app/api/model/benefit.dart";
import "package:valon_kaupunki_app/api/model/benefit_user.dart";
import "package:valon_kaupunki_app/api/model/favourite_partner.dart";
import "package:valon_kaupunki_app/api/model/favourite_user.dart";
import "package:valon_kaupunki_app/api/model/image.dart";
import "package:valon_kaupunki_app/api/model/partner.dart";

part "strapi_resp.g.dart";

@JsonSerializable()
class BenefitData {
  final List<StrapiBenefit> data;

  const BenefitData(this.data);

  factory BenefitData.fromJson(Map<String, dynamic> json) =>
      _$BenefitDataFromJson(json);
}

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
class SoundData {
  final StrapiSound? data;

  const SoundData(this.data);

  factory SoundData.fromJson(Map<String, dynamic> json) =>
      _$SoundDataFromJson(json);
}

@JsonSerializable()
class StrapiSound {
  @JsonKey(name: "attributes")
  final Sound sound;
  final int id;

  const StrapiSound(this.sound, this.id);

  factory StrapiSound.fromJson(Map<String, dynamic> json) =>
      _$StrapiSoundFromJson(json);
}

@JsonSerializable()
class Sound {
  final String mime;
  final String url;

  const Sound(this.mime, this.url);

  factory Sound.fromJson(Map<String, dynamic> json) => _$SoundFromJson(json);
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
class OnlyId {
  final int id;

  const OnlyId(this.id);

  factory OnlyId.fromJson(Map<String, dynamic> json) => _$OnlyIdFromJson(json);
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

@JsonSerializable()
class StrapiBenefitUser {
  @JsonKey(name: "attributes")
  final BenefitUser benefitUser;
  final int id;

  const StrapiBenefitUser(this.benefitUser, this.id);

  factory StrapiBenefitUser.fromJson(Map<String, dynamic> json) =>
      _$StrapiBenefitUserFromJson(json);
}

@JsonSerializable()
class StrapiBenefitUserResponse {
  final List<StrapiBenefitUser> data;
  final StrapiResponseMeta? meta;

  const StrapiBenefitUserResponse(this.data, this.meta);

  factory StrapiBenefitUserResponse.fromJson(Map<String, dynamic> json) =>
      _$StrapiBenefitUserResponseFromJson(json);
}

@JsonSerializable()
class StrapiFavouriteUser {
  @JsonKey(name: "attributes")
  final FavouriteUser favouriteUser;
  final int id;

  const StrapiFavouriteUser(this.favouriteUser, this.id);

  factory StrapiFavouriteUser.fromJson(Map<String, dynamic> json) =>
      _$StrapiFavouriteUserFromJson(json);
}

@JsonSerializable()
class StrapiFavouriteUserResponse {
  final List<StrapiFavouriteUser> data;
  final StrapiResponseMeta? meta;

  const StrapiFavouriteUserResponse(this.data, this.meta);

  factory StrapiFavouriteUserResponse.fromJson(Map<String, dynamic> json) =>
      _$StrapiFavouriteUserResponseFromJson(json);
}

@JsonSerializable()
class StrapiCreateFavouriteUserResponse {
  final StrapiFavouriteUser data;

  const StrapiCreateFavouriteUserResponse(this.data);

  factory StrapiCreateFavouriteUserResponse.fromJson(
          Map<String, dynamic> json) =>
      _$StrapiCreateFavouriteUserResponseFromJson(json);
}

@JsonSerializable()
class StrapiFavouritePartner {
  @JsonKey(name: "attributes")
  final FavouritePartner favouritePartner;
  final int id;

  const StrapiFavouritePartner(this.favouritePartner, this.id);

  factory StrapiFavouritePartner.fromJson(Map<String, dynamic> json) =>
      _$StrapiFavouritePartnerFromJson(json);
}

@JsonSerializable()
class StrapiFavouritePartnerResponse {
  final List<StrapiFavouritePartner> data;
  final StrapiResponseMeta? meta;

  const StrapiFavouritePartnerResponse(this.data, this.meta);

  factory StrapiFavouritePartnerResponse.fromJson(Map<String, dynamic> json) =>
      _$StrapiFavouritePartnerResponseFromJson(json);
}

@JsonSerializable()
class StrapiCreateFavouritePartnerResponse {
  final StrapiFavouritePartner data;

  const StrapiCreateFavouritePartnerResponse(this.data);

  factory StrapiCreateFavouritePartnerResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$StrapiCreateFavouritePartnerResponseFromJson(json);
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
