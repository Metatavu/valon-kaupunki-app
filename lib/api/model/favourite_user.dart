import "package:json_annotation/json_annotation.dart";
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";

part "favourite_user.g.dart";

@JsonSerializable()
class FavouriteUser {
  final String deviceIdentifier;
  final FavouriteUserData attraction;

  const FavouriteUser(this.deviceIdentifier, this.attraction);

  factory FavouriteUser.fromJson(Map<String, dynamic> json) =>
      _$FavouriteUserFromJson(json);
}

@JsonSerializable()
class FavouriteUserData {
  final OnlyId data;

  const FavouriteUserData(this.data);

  factory FavouriteUserData.fromJson(Map<String, dynamic> json) =>
      _$FavouriteUserDataFromJson(json);
}
