import "package:json_annotation/json_annotation.dart";

part "benefit.g.dart";

@JsonSerializable()
class Benefit {
  final String title;
  final String benefitText;
  final DateTime? validFrom;
  final DateTime? validTo;

  const Benefit(this.title, this.benefitText, this.validFrom, this.validTo);

  factory Benefit.fromJson(Map<String, dynamic> json) =>
      _$BenefitFromJson(json);
}
