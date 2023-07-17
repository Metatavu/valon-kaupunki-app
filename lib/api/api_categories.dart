import "package:flutter_svg/flutter_svg.dart";
import "package:valon_kaupunki_app/assets.dart";

import "package:flutter_gen/gen_l10n/app_localizations.dart";

String getAttractionMarkerAsset(String category) {
  return {
        "static": Assets.permanentAttractionAsset,
        "event": Assets.eventAttractionAsset
      }[category] ??
      "";
}

String getPartnerMarkerAsset(String category) {
  return {
        "restaurant": Assets.restaurantPartnerAsset,
        "cafe": Assets.cafePartnerAsset,
        "bar": Assets.barPartnerAsset,
        "shop": Assets.shopPartnerAsset,
        "other": Assets.genericPartnerAsset,
      }[category] ??
      "";
}

SvgPicture getPartnerCategoryIcon(String category) {
  return SvgPicture.asset(
    {
      "restaurant": Assets.restaurantPartnerAssetIcon,
      "cafe": Assets.cafePartnerAssetIcon,
      "bar": Assets.barPartnerAssetIcon,
      "shop": Assets.shopPartnerAssetIcon,
      "other": Assets.genericPartnerAssetIcon,
    }[category]!,
  );
}

String getAttractionCategoryLabel(String category, AppLocalizations loc) {
  return {
    "static": loc.permanentAttractionText,
    "event": loc.eventAttractionText,
  }[category]!;
}

String getPartnerCategoryLabel(String category, AppLocalizations loc) {
  return {
    "restaurant": loc.restaurantText,
    "cafe": loc.cafeText,
    "bar": loc.barText,
    "shop": loc.shopText,
    "other": loc.otherText,
  }[category]!;
}