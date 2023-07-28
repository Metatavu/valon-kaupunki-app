import "package:json_annotation/json_annotation.dart";
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";

part "benefit_user.g.dart";

@JsonSerializable()
class BenefitUser {
  final String deviceIdentifier;
  final BenefitUserData benefit;

  const BenefitUser(this.deviceIdentifier, this.benefit);

  factory BenefitUser.fromJson(Map<String, dynamic> json) =>
      _$BenefitUserFromJson(json);
}

@JsonSerializable()
class BenefitUserData {
  final StrapiBenefit data;

  const BenefitUserData(this.data);

  factory BenefitUserData.fromJson(Map<String, dynamic> json) =>
      _$BenefitUserDataFromJson(json);
}
