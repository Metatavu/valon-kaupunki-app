import "package:flutter_svg/flutter_svg.dart";
import "package:valon_kaupunki_app/assets.dart";

import "package:flutter_gen/gen_l10n/app_localizations.dart";

class AttractionCategories {
  AttractionCategories._();
  static const String permanentAttraction = "permanent-attraction";
  static const String eventLightArtPiece = "event-light-art-piece";
}

class PartnerCategories {
  PartnerCategories._();
  static const String restaurantOrCafe = "restaurant-or-cafe";
  static const String shopping = "shop";
  static const String supplementaryShow = "supplementary-show";
  static const String jyvasParkki = "jyvas-parkki";
}

String getAttractionMarkerAsset(String category) {
  return {
    AttractionCategories.permanentAttraction: Assets.permanentAttractionMarker,
    AttractionCategories.eventLightArtPiece: Assets.eventLightArtPieceMarker
  }[category]!;
}

String getAttractionFavouriteMarkerAsset(String category) {
  return {
    AttractionCategories.permanentAttraction:
        Assets.permanentAttractionFavouriteMarker,
    AttractionCategories.eventLightArtPiece:
        Assets.eventLightArtPieceFavouriteMarker
  }[category]!;
}

String getPartnerMarkerAsset(String category) {
  return {
    PartnerCategories.restaurantOrCafe: Assets.restaurantOrCafeMarker,
    PartnerCategories.shopping: Assets.shoppingMarker,
    PartnerCategories.supplementaryShow: Assets.supplementaryShowMarker,
    PartnerCategories.jyvasParkki: Assets.jyvasParkkiMarker,
  }[category]!;
}

String getPartnerFavouriteMarkerAsset(String category) {
  return {
    PartnerCategories.restaurantOrCafe: Assets.restaurantOrCafeFavouriteMarker,
    PartnerCategories.shopping: Assets.shoppingFavouriteMarker,
    PartnerCategories.supplementaryShow:
        Assets.supplementaryShowFavouriteMarker,
    PartnerCategories.jyvasParkki: Assets.jyvasParkkiFavouriteMarker,
  }[category]!;
}

SvgPicture getPartnerCategoryIcon(String category) {
  return SvgPicture.asset(
    {
      PartnerCategories.restaurantOrCafe: Assets.restaurantOrCafeIcon,
      PartnerCategories.shopping: Assets.shoppingIcon,
      PartnerCategories.supplementaryShow: Assets.supplementaryShowIcon,
      PartnerCategories.jyvasParkki: Assets.jyvasParkkiIcon,
    }[category]!,
  );
}

String getAttractionCategoryLabel(
  String category,
  AppLocalizations localizations,
) {
  return {
    AttractionCategories.permanentAttraction:
        localizations.permanentAttractionsText,
    AttractionCategories.eventLightArtPiece:
        localizations.eventLightArtPiecesText,
  }[category]!;
}

String getPartnerCategoryLabel(
  String category,
  AppLocalizations localizations,
) {
  return {
    PartnerCategories.restaurantOrCafe: localizations.restaurantsOrCafesText,
    PartnerCategories.shopping: localizations.shoppingText,
    PartnerCategories.supplementaryShow: localizations.supplementaryShowsText,
    PartnerCategories.jyvasParkki: localizations.jyvasParkkiText,
  }[category]!;
}
