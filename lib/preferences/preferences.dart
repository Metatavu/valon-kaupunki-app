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
  static const String _keyShowPermanentAttractionsMap =
      "$_keyPrefix.map.show-permanent-attractions";
  static const String _keyShowEventAttractionsMap =
      "$_keyPrefix.map.show-event-attractions";
  static const String _keyShowRestaurantsMap =
      "$_keyPrefix.map.show-restaurants";
  static const String _keyShowBarsMap = "$_keyPrefix.map.show-bars";
  static const String _keyShowShopsMap = "$_keyPrefix.map.show-shops";
  static const String _keyShowCafesMap = "$_keyPrefix.map.show-cafes";
  static const String _keyShowOthersMap = "$_keyPrefix.map.show-others";

  static bool get showPermanentAttractions =>
      _sharedPrefs!.getBool(_keyShowPermanentAttractionsMap) ?? true;
  static Future<void> setShowPermanentAttractions(
          bool showPermanentAttractions) async =>
      _sharedPrefs!
          .setBool(_keyShowPermanentAttractionsMap, showPermanentAttractions);

  static bool get showEventAttractions =>
      _sharedPrefs!.getBool(_keyShowEventAttractionsMap) ?? true;
  static Future<void> setShowEventAttractions(
          bool showEventAttractions) async =>
      await _sharedPrefs!
          .setBool(_keyShowEventAttractionsMap, showEventAttractions);

  static bool get showRestaurants =>
      _sharedPrefs!.getBool(_keyShowRestaurantsMap) ?? true;
  static Future<void> setShowRestaurants(bool showRestaurants) async =>
      await _sharedPrefs!.setBool(_keyShowRestaurantsMap, showRestaurants);

  static bool get showBars => _sharedPrefs!.getBool(_keyShowBarsMap) ?? true;
  static Future<void> setShowBars(bool showBars) async =>
      await _sharedPrefs!.setBool(_keyShowBarsMap, showBars);

  static bool get showShops => _sharedPrefs!.getBool(_keyShowShopsMap) ?? true;
  static Future<void> setShowShops(bool showShops) async =>
      await _sharedPrefs!.setBool(_keyShowShopsMap, showShops);

  static bool get showCafes => _sharedPrefs!.getBool(_keyShowCafesMap) ?? true;
  static Future<void> setShowCafes(bool showCafes) async =>
      await _sharedPrefs!.setBool(_keyShowCafesMap, showCafes);

  static bool get showOthers =>
      _sharedPrefs!.getBool(_keyShowOthersMap) ?? true;
  static Future<void> setShowOthers(bool showOthers) async =>
      await _sharedPrefs!.setBool(_keyShowOthersMap, showOthers);

  static const String _keySorting = "$_keyPrefix.filter.sorting";

  static Sorting get sorting =>
      Sorting.parse(_sharedPrefs!.getString(_keySorting)!) ??
      Sorting.alphabetical;

  static Future<void> setSorting(Sorting sorting) async =>
      await _sharedPrefs!.setString(_keySorting, sorting.prefValue);
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
