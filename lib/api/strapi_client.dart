import "dart:convert";
import "dart:ui";

import "package:valon_kaupunki_app/api/model/strapi_resp.dart";
import "package:http/http.dart" as http;
import "package:valon_kaupunki_app/unique_device_info.dart";

enum StrapiContentType {
  attraction,
  benefit,
  partner,
  benefitUser,
  favouriteAttraction,
  favouritePartner;

  String path() => switch (this) {
        attraction => "attractions",
        benefit => "benefits",
        partner => "partners",
        benefitUser => "benefit-users",
        favouriteAttraction => "favourite-users",
        favouritePartner => "favourite-partners",
      };

  dynamic fromJson<StrapiContentType>(String jsonData) {
    final json = jsonDecode(jsonData);

    return switch (this) {
      attraction => StrapiAttractionResponse.fromJson(json),
      benefit => StrapiBenefitResponse.fromJson(json),
      partner => StrapiPartnerResponse.fromJson(json),
      benefitUser => StrapiBenefitUserResponse.fromJson(json),
      favouriteAttraction => StrapiFavouriteUserResponse.fromJson(json),
      favouritePartner => StrapiFavouritePartnerResponse.fromJson(json),
    };
  }
}

class StrapiClient {
  static const String _accessToken =
      String.fromEnvironment("STRAPI_ACCESS_TOKEN");
  static const String _strapiUrl = String.fromEnvironment("STRAPI_URL");
  static const String _strapiBasePath =
      String.fromEnvironment("STRAPI_BASE_PATH");

  static StrapiClient? _instance;
  static String? _deviceId;

  StrapiClient._();

  factory StrapiClient.instance() {
    _instance ??= StrapiClient._();
    return _instance!;
  }

  Future<T> _getContentType<T>(StrapiContentType contentType,
      [Map<String, String>? queryParams]) async {
    final resp = await http.get(
      Uri(
        scheme: "https",
        host: _strapiUrl,
        pathSegments: [_strapiBasePath, contentType.path()],
        queryParameters: queryParams,
      ),
      headers: {
        "Authorization": "Bearer $_accessToken",
      },
    );

    if (resp.statusCode != 200) {
      throw ApiException(
        "failed to retrieve ${contentType.path()} list: ${resp.statusCode} - ${resp.body}",
      );
    }

    return contentType.fromJson(resp.body);
  }

  Future<StrapiAttractionResponse> listAttractions({Locale? locale}) async {
    var queryParams = {"populate": "image,sound"};

    if (locale != null) {
      queryParams["locale"] = locale.languageCode;
    }

    return _getContentType<StrapiAttractionResponse>(
      StrapiContentType.attraction,
      queryParams,
    );
  }

  Future<List<StrapiFavouriteUser>> listFavouriteAttractionsForUser() async {
    _deviceId ??= await getUniqueDeviceId();

    final response = await _getContentType<StrapiFavouriteUserResponse>(
      StrapiContentType.favouriteAttraction,
      {
        "populate": "*",
        "filters[deviceIdentifier][\$eq]": _deviceId!,
      },
    );

    return response.data.toList();
  }

  Future<StrapiBenefitResponse> listBenefits() async =>
      _getContentType<StrapiBenefitResponse>(
        StrapiContentType.benefit,
        {
          "populate": "benefit,benefit.image,partner.image",
        },
      );

  Future<List<StrapiBenefit>> listUsedBenefitsForDevice() async {
    _deviceId ??= await getUniqueDeviceId();

    final response = await _getContentType<StrapiBenefitUserResponse>(
      StrapiContentType.benefitUser,
      {"populate": "benefit", "filters[deviceIdentifier][\$eq]": _deviceId!},
    );

    return response.data
        .map((usedBenefit) => usedBenefit.benefitUser.benefit.data)
        .toList();
  }

  Future<StrapiPartnerResponse> listPartners({Locale? locale}) async {
    var queryParams = {"populate": "image,benefits"};

    if (locale != null) {
      queryParams["locale"] = locale.languageCode;
    }

    return _getContentType<StrapiPartnerResponse>(
      StrapiContentType.partner,
      queryParams,
    );
  }

  Future<List<StrapiFavouritePartner>> listFavouritePartnersForUser() async {
    _deviceId ??= await getUniqueDeviceId();

    final resp = await _getContentType<StrapiFavouritePartnerResponse>(
      StrapiContentType.favouritePartner,
      {
        "populate": "*",
        "filters[deviceIdentifier][\$eq]": _deviceId!,
      },
    );

    return resp.data.toList();
  }

  Future<bool> claimBenefit(int benefitId) async {
    _deviceId ??= await getUniqueDeviceId();
    final usedBenefits = await listUsedBenefitsForDevice();

    if (usedBenefits.map((benefit) => benefit.id).contains(benefitId)) {
      return false;
    }

    final resp = await http.post(
      Uri(
        scheme: "https",
        host: _strapiUrl,
        pathSegments: [_strapiBasePath, StrapiContentType.benefitUser.path()],
      ),
      body: jsonEncode({
        "data": {
          "deviceIdentifier": _deviceId!,
          "benefit": benefitId,
        },
      }),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    if (resp.statusCode != 200) {
      throw ApiException(
        "failed to add benefit user: ${resp.statusCode} - ${resp.body}",
      );
    }

    return true;
  }

  Future<StrapiFavouriteUser> addFavouriteAttraction(
    int attractionId,
  ) async {
    _deviceId ??= await getUniqueDeviceId();

    final resp = await http.post(
      Uri(
        scheme: "https",
        host: _strapiUrl,
        pathSegments: [
          _strapiBasePath,
          StrapiContentType.favouriteAttraction.path()
        ],
        queryParameters: {
          "populate": "*",
        },
      ),
      body: jsonEncode({
        "data": {
          "deviceIdentifier": _deviceId!,
          "attraction": attractionId,
        },
      }),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    if (resp.statusCode != 200) {
      throw ApiException(
        "failed to add favourite attraction: ${resp.statusCode} - ${resp.body}",
      );
    }

    return StrapiCreateFavouriteUserResponse.fromJson(jsonDecode(resp.body))
        .data;
  }

  Future<void> removeFavouriteAttraction(
    StrapiFavouriteUser favouriteAttraction,
  ) async {
    final resp = await http.delete(
      Uri(
        scheme: "https",
        host: _strapiUrl,
        pathSegments: [
          _strapiBasePath,
          StrapiContentType.favouriteAttraction.path(),
          favouriteAttraction.id.toString()
        ],
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    if (resp.statusCode != 200) {
      throw ApiException(
        "failed to remove favourite attraction: ${resp.statusCode} - ${resp.body}",
      );
    }
  }

  Future<StrapiFavouritePartner> addFavouritePartner(
    int partnerId,
  ) async {
    _deviceId ??= await getUniqueDeviceId();

    final resp = await http.post(
      Uri(
        scheme: "https",
        host: _strapiUrl,
        pathSegments: [
          _strapiBasePath,
          StrapiContentType.favouritePartner.path()
        ],
        queryParameters: {
          "populate": "*",
        },
      ),
      body: jsonEncode({
        "data": {
          "deviceIdentifier": _deviceId!,
          "partner": partnerId,
        },
      }),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    if (resp.statusCode != 200) {
      throw ApiException(
        "failed to add favourite partner: ${resp.statusCode} - ${resp.body}",
      );
    }

    return StrapiCreateFavouritePartnerResponse.fromJson(jsonDecode(resp.body))
        .data;
  }

  Future<void> removeFavouritePartner(
    StrapiFavouritePartner favouritePartner,
  ) async {
    final resp = await http.delete(
      Uri(
        scheme: "https",
        host: _strapiUrl,
        pathSegments: [
          _strapiBasePath,
          StrapiContentType.favouritePartner.path(),
          favouritePartner.id.toString(),
        ],
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    if (resp.statusCode != 200) {
      throw ApiException(
        "failed to remove favourite partner: ${resp.statusCode} - ${resp.body}",
      );
    }
  }
}

class ApiException implements Exception {
  final String msg;
  const ApiException(this.msg);

  @override
  String toString() => "ApiException[$msg]";
}
