import "dart:convert";

import "package:valon_kaupunki_app/api/model/benefit.dart";
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";
import "package:http/http.dart" as http;

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

  Future<StrapiResponse<T>> _getContentType<T>(String ctName,
      [Map<String, String>? queryParams]) async {
    final resp = await http.get(
        Uri(
          scheme: "https",
          host: _strapiUrl,
          pathSegments: [_strapiBase, ctName],
          queryParameters: queryParams,
        ),
        headers: {"Authorization": "Bearer $_accessToken"});

    if (resp.statusCode != 200) {
      throw ApiException("failed to retrieve $ctName list");
    }

    return StrapiResponse.fromJson(jsonDecode(resp.body));
  }

  Future<StrapiResponse<StrapiAttraction>> getAttractions() async =>
      _getContentType<StrapiAttraction>(
          "attractions", {"populate": "image,sound"});

  Future<StrapiResponse<StrapiBenefit>> getBenefits() async =>
      _getContentType<StrapiBenefit>("benefits", {"populate": "image,partner"});
}

class ApiException implements Exception {
  final String msg;
  const ApiException(this.msg);
}
