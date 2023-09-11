import "package:flutter/material.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:valon_kaupunki_app/widgets/filter_button.dart";

class MapFilterButtonList extends StatefulWidget {
  final void Function() onMarkerFilterUpdate;

  final void Function() onFilterPermanentAttractions;
  final void Function() onFilterEventLightArtPieces;
  final void Function() onFilterRestaurantsAndCafes;
  final void Function() onFilterShopping;
  final void Function() onFilterSupplementaryShows;
  final void Function() onFilterJyvasParkki;

  final bool permanentAttractionsState;
  final bool eventLightArtPiecesState;
  final bool restaurantsAndCafesState;
  final bool shoppingState;
  final bool supplementaryShowsState;
  final bool jyvasParkkiState;

  const MapFilterButtonList({
    required this.onMarkerFilterUpdate,
    required this.onFilterPermanentAttractions,
    required this.onFilterEventLightArtPieces,
    required this.onFilterRestaurantsAndCafes,
    required this.onFilterShopping,
    required this.onFilterSupplementaryShows,
    required this.onFilterJyvasParkki,
    required this.permanentAttractionsState,
    required this.eventLightArtPiecesState,
    required this.restaurantsAndCafesState,
    required this.shoppingState,
    required this.supplementaryShowsState,
    required this.jyvasParkkiState,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapFilterButtonListState();
}

class _MapFilterButtonListState extends State<MapFilterButtonList> {
  late AppLocalizations _localizations;

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;

    return ListView(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      children: [
        FilterButton(
          iconAsset: Assets.attractionsIcon,
          label: _localizations.permanentAttractionsText,
          color: CustomThemeValues.appOrange,
          state: widget.permanentAttractionsState,
          onClick: widget.onFilterPermanentAttractions,
          onMarkerFilterUpdate: widget.onMarkerFilterUpdate,
        ),
        FilterButton(
          iconAsset: Assets.eventLightArtPieceIcon,
          label: _localizations.eventLightArtPiecesText,
          color: CustomThemeValues.lightArtPieceColor,
          state: widget.eventLightArtPiecesState,
          onClick: widget.onFilterEventLightArtPieces,
          onMarkerFilterUpdate: widget.onMarkerFilterUpdate,
        ),
        FilterButton(
          iconAsset: Assets.restaurantOrCafeIcon,
          label: _localizations.restaurantsOrCafesText,
          color: CustomThemeValues.restaurantOrCafeColor,
          state: widget.restaurantsAndCafesState,
          onClick: widget.onFilterRestaurantsAndCafes,
          onMarkerFilterUpdate: widget.onMarkerFilterUpdate,
        ),
        FilterButton(
          iconAsset: Assets.shoppingIcon,
          label: _localizations.shoppingText,
          color: CustomThemeValues.shoppingColor,
          state: widget.shoppingState,
          onClick: widget.onFilterShopping,
          onMarkerFilterUpdate: widget.onMarkerFilterUpdate,
        ),
        FilterButton(
          iconAsset: Assets.supplementaryShowIcon,
          label: _localizations.supplementaryShowsText,
          color: CustomThemeValues.supplementaryShowColor,
          state: widget.supplementaryShowsState,
          onClick: widget.onFilterSupplementaryShows,
          onMarkerFilterUpdate: widget.onMarkerFilterUpdate,
        ),
        FilterButton(
          iconAsset: Assets.jyvasParkkiIcon,
          label: _localizations.jyvasParkkiText,
          color: CustomThemeValues.jyvasParkkiColor,
          noPad: true,
          state: widget.jyvasParkkiState,
          onClick: widget.onFilterJyvasParkki,
          onMarkerFilterUpdate: widget.onMarkerFilterUpdate,
        ),
      ],
    );
  }
}
