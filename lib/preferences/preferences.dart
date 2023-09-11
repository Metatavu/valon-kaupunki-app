import "dart:convert";
import "dart:ui";

import "package:shared_preferences/shared_preferences.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class Preferences {
  // So that the dart code completer does not suggest constructing the object
  Preferences._();

  static SharedPreferences? _sharedPrefs;
  static Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  static const String _keyPrefix = "fi.metatavu.valon-kaupunki-app";
  static const String _keySelectedLocale = "$_keyPrefix.selected-locale";
  static const String _keyAppLaunchedOnce = "$_keyPrefix.app-launched-once";
  static const String _keyShowPermanentAttractionsMap =
      "$_keyPrefix.map.show-permanent-attractions";
  static const String _keyShowEventLightArtPiecesMap =
      "$_keyPrefix.map.show-event-light-art-pieces";
  static const String _keyShowRestaurantsAndCafesMap =
      "$_keyPrefix.map.show-restaurants-and-cafes";
  static const String _keyShowShoppingMap = "$_keyPrefix.map.show-shopping";
  static const String _keyShowSupplementaryShowsMap =
      "$_keyPrefix.map.show-supplementary-shows";
  static const String _keyShowJyvasParkkiMap =
      "$_keyPrefix.map.show-jyvas-parkki";
  static const String _keySorting = "$_keyPrefix.filter.sorting";
  static const String _keyAudioCacheMapping = "$_keyPrefix.audio-cache-mapping";

  static Locale? get selectedLocale {
    final locale = _sharedPrefs!.getString(_keySelectedLocale);
    return locale == null ? null : Locale(locale);
  }

  static Future<void> setSelectedLocale(Locale locale) async =>
      _sharedPrefs!.setString(
        _keySelectedLocale,
        locale.languageCode,
      );

  static bool get appLaunchedOnce =>
      _sharedPrefs!.getBool(_keyAppLaunchedOnce) ?? false;

  static Future<void> setAppLaunchedOnce(bool appLaunchedOnce) =>
      _sharedPrefs!.setBool(
        _keyAppLaunchedOnce,
        appLaunchedOnce,
      );

  static bool get showPermanentAttractions =>
      _sharedPrefs!.getBool(_keyShowPermanentAttractionsMap) ?? true;

  static Future<void> setShowPermanentAttractions(
          bool showPermanentAttractions) =>
      _sharedPrefs!
          .setBool(_keyShowPermanentAttractionsMap, showPermanentAttractions);

  static bool get showEventLightArtPieces =>
      _sharedPrefs!.getBool(_keyShowEventLightArtPiecesMap) ?? true;

  static Future<void> setShowEventAttractions(
    bool showEventLightArtPieces,
  ) =>
      _sharedPrefs!.setBool(
        _keyShowEventLightArtPiecesMap,
        showEventLightArtPieces,
      );

  static bool get showRestaurantsAndCafes =>
      _sharedPrefs!.getBool(_keyShowRestaurantsAndCafesMap) ?? true;

  static Future<void> setShowRestaurantsAndCafes(
    bool showRestaurantsAndCafes,
  ) =>
      _sharedPrefs!.setBool(
        _keyShowRestaurantsAndCafesMap,
        showRestaurantsAndCafes,
      );

  static bool get showShopping =>
      _sharedPrefs!.getBool(_keyShowShoppingMap) ?? true;

  static Future<void> setShowShopping(bool showShops) =>
      _sharedPrefs!.setBool(_keyShowShoppingMap, showShops);

  static bool get showSupplementaryShows =>
      _sharedPrefs!.getBool(_keyShowSupplementaryShowsMap) ?? true;

  static Future<void> setShowSupplementaryShows(
    bool showSupplementaryShows,
  ) =>
      _sharedPrefs!.setBool(
        _keyShowSupplementaryShowsMap,
        showSupplementaryShows,
      );

  static bool get showJyvasParkki =>
      _sharedPrefs!.getBool(_keyShowJyvasParkkiMap) ?? true;

  static Future<void> setShowJyvasParkki(bool showJyvasParkki) =>
      _sharedPrefs!.setBool(_keyShowJyvasParkkiMap, showJyvasParkki);

  static Sorting get sorting =>
      Sorting.parse(_sharedPrefs!.getString(_keySorting) ?? "alphabetical") ??
      Sorting.alphabetical;

  static Future<void> setSorting(Sorting sorting) =>
      _sharedPrefs!.setString(_keySorting, sorting.prefValue);

  static Map<String, String> get audioCacheMapping =>
      (jsonDecode(_sharedPrefs!.getString(_keyAudioCacheMapping) ?? "{}")
              as Map<String, dynamic>)
          .cast();

  static Future<void> setAudioCacheMapping(Map<String, String> mapping) =>
      _sharedPrefs!.setString(_keyAudioCacheMapping, jsonEncode(mapping));
}

enum Sorting {
  alphabetical,
  distance;

  static Sorting? parse(String value) {
    return switch (value) {
      "alphabetical" => alphabetical,
      "distance" => distance,
      _ => null,
    };
  }

  String get prefValue => this == alphabetical ? "alphabetical" : "distance";
  String getDisplayValue(AppLocalizations localizations) {
    return switch (this) {
      alphabetical => localizations.sortingAlphabetical,
      distance => localizations.sortingClosest,
    };
  }
}
