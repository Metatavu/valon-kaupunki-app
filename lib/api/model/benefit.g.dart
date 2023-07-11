// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Benefit _$BenefitFromJson(Map<String, dynamic> json) => Benefit(
      json['title'] as String,
      json['benefitText'] as String,
      json['validFrom'] == null
          ? null
          : DateTime.parse(json['validFrom'] as String),
      json['validTo'] == null
          ? null
          : DateTime.parse(json['validTo'] as String),
    );

Map<String, dynamic> _$BenefitToJson(Benefit instance) => <String, dynamic>{
      'title': instance.title,
      'benefitText': instance.benefitText,
      'validFrom': instance.validFrom?.toIso8601String(),
      'validTo': instance.validTo?.toIso8601String(),
    };
