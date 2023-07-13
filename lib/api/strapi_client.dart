import "dart:convert";

import "package:valon_kaupunki_app/api/model/strapi_resp.dart";
import "package:http/http.dart" as http;

enum StrapiContentType {
  attraction,
  benefit;

  String path() => switch (this) {
        attraction => "attractions",
        benefit => "benefits",
      };

  dynamic fromJson(String jsonData) {
    final json = jsonDecode(jsonData);

    return switch (this) {
      attraction => StrapiAttractionResponse.fromJson(json),
      benefit => StrapiBenefitResponse.fromJson(json),
    };
  }
}

class StrapiClient {
  static const String _accessToken =
      String.fromEnvironment("STRAPI_ACCESS_TOKEN");
  static const String _strapiUrl = String.fromEnvironment("STRAPI_URL");
  static const String _strapiBase = String.fromEnvironment("STRAPI_BASE_PATH");

  static StrapiClient? _instance;

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
      _getContentType<StrapiBenefitResponse>(
          StrapiContentType.benefit, {"populate": "image,partner"});
}

class ApiException implements Exception {
  final String msg;
  const ApiException(this.msg);
}
