// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BenefitUser _$BenefitUserFromJson(Map<String, dynamic> json) => BenefitUser(
      json['deviceIdentifier'] as String,
      BenefitUserData.fromJson(json['benefit'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BenefitUserToJson(BenefitUser instance) =>
    <String, dynamic>{
      'deviceIdentifier': instance.deviceIdentifier,
      'benefit': instance.benefit,
    };

BenefitUserData _$BenefitUserDataFromJson(Map<String, dynamic> json) =>
    BenefitUserData(
      StrapiBenefit.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BenefitUserDataToJson(BenefitUserData instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
