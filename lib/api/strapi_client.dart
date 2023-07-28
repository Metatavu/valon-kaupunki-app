import "dart:convert";

import "package:valon_kaupunki_app/api/model/benefit.dart";
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";
import "package:http/http.dart" as http;
import "package:valon_kaupunki_app/unique_device_info.dart";

enum StrapiContentType {
  attraction,
  benefit,
  partner,
  benefitUser;

  String path() => switch (this) {
        attraction => "attractions",
        benefit => "benefits",
        partner => "partners",
        benefitUser => "benefit-users",
      };

  dynamic fromJson(String jsonData) {
    final json = jsonDecode(jsonData);

    return switch (this) {
      attraction => StrapiAttractionResponse.fromJson(json),
      benefit => StrapiBenefitResponse.fromJson(json),
      partner => StrapiPartnerResponse.fromJson(json),
      benefitUser => StrapiBenefitUserResponse.fromJson(json),
    };
  }
}

class StrapiClient {
  static const String _accessToken =
      String.fromEnvironment("STRAPI_ACCESS_TOKEN");
  static const String _strapiUrl = String.fromEnvironment("STRAPI_URL");
  static const String _strapiBase = String.fromEnvironment("STRAPI_BASE_PATH");

  static StrapiClient? _instance;
  static String? _deviceId;

  StrapiClient._();

  factory StrapiClient.instance() {
    _instance ??= StrapiClient._();
    return _instance!;
  }

  Future<T> _getContentType<T>(StrapiContentType ct,
      [Map<String, String>? queryParams]) async {
    final resp = await http.get(
        Uri(
          scheme: "https",
          host: _strapiUrl,
          pathSegments: [_strapiBase, ct.path()],
          queryParameters: queryParams,
        ),
        headers: {"Authorization": "Bearer $_accessToken"});

    if (resp.statusCode != 200) {
      throw ApiException("failed to retrieve ${ct.path()} list");
    }

    return ct.fromJson(resp.body);
  }

  Future<StrapiAttractionResponse> getAttractions() async =>
      _getContentType<StrapiAttractionResponse>(
          StrapiContentType.attraction, {"populate": "image,sound"});

  Future<StrapiBenefitResponse> getBenefits() async =>
      _getContentType<StrapiBenefitResponse>(StrapiContentType.benefit, {
        "populate[1]": Uri.encodeQueryComponent("partner.image"),
        "populate": "image"
      });

  Future<List<StrapiBenefit>> getBenefitsForDevice() async {
    _deviceId ??= await getUniqueDeviceId();
    final resp = await _getContentType<StrapiBenefitUserResponse>(
        StrapiContentType.benefitUser,
        {"populate": "benefit,benefit.image,partner.image"});

    return Future.value(
        resp.data.map((e) => e.benefitUser.benefit.data).toList());
  }

  Future<StrapiPartnerResponse> getPartners() async =>
      _getContentType<StrapiPartnerResponse>(
          StrapiContentType.partner, {"populate": "image,benefits"});

  Future<bool> claimBenefit(int id) async {
    _deviceId ??= await getUniqueDeviceId();
    final unusedBenefits = await getBenefitsForDevice();
    if (!unusedBenefits.map((e) => e.id).contains(id)) {
      return false;
    }

    final resp = await http.post(
      Uri(
        scheme: "https",
        host: _strapiUrl,
        pathSegments: [_strapiBase, StrapiContentType.benefitUser.path()],
      ),
      body: jsonEncode(
        {
          "data": {
            "deviceIdentifier": _deviceId!,
            "benefit": id,
          },
        },
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    if (resp.statusCode != 200) {
      throw ApiException("failed to add benefit user: ${resp.body}");
    }

    return true;
  }
}

class ApiException implements Exception {
  final String msg;
  const ApiException(this.msg);

  @override
  String toString() => "ApiException[$msg]";
}
