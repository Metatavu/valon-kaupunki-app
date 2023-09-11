import "package:json_annotation/json_annotation.dart";
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";

part "favourite_partner.g.dart";

@JsonSerializable()
class FavouritePartner {
  final String deviceIdentifier;
  final FavouritePartnerData? partner;

  const FavouritePartner(this.deviceIdentifier, this.partner);

  int? get partnerId => partner?.data.id;

  factory FavouritePartner.fromJson(Map<String, dynamic> json) =>
      _$FavouritePartnerFromJson(json);
}

@JsonSerializable()
class FavouritePartnerData {
  final OnlyId data;

  const FavouritePartnerData(this.data);

  factory FavouritePartnerData.fromJson(Map<String, dynamic> json) =>
      _$FavouritePartnerDataFromJson(json);
}
