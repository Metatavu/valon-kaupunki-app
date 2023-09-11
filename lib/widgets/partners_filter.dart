import "package:flutter/material.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:valon_kaupunki_app/widgets/filter_button.dart";

class PartnersFilter extends StatefulWidget {
  final void Function() onFilterRestaurantsOrCafes;
  final void Function() onFilterShopping;
  final void Function() onFilterSupplementaryShows;
  final void Function() onFilterJyvasParkki;
  final void Function() onMarkerFilterUpdate;

  final bool restaurantsOrCafesState;
  final bool shoppingState;
  final bool supplementaryShowsState;
  final bool jyvasParkkiState;

  const PartnersFilter({
    required this.onFilterRestaurantsOrCafes,
    required this.onFilterShopping,
    required this.onFilterSupplementaryShows,
    required this.onFilterJyvasParkki,
    required this.onMarkerFilterUpdate,
    required this.restaurantsOrCafesState,
    required this.shoppingState,
    required this.supplementaryShowsState,
    required this.jyvasParkkiState,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PartnersFilterState();
}

class _PartnersFilterState extends State<PartnersFilter> {
  late AppLocalizations _localizations;

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;

    return ListView(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      children: [
        FilterButton(
          iconAsset: Assets.restaurantOrCafeIcon,
          label: _localizations.restaurantsOrCafesText,
          color: CustomThemeValues.restaurantOrCafeColor,
          state: widget.restaurantsOrCafesState,
          onClick: widget.onFilterRestaurantsOrCafes,
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
          state: widget.jyvasParkkiState,
          onClick: widget.onFilterJyvasParkki,
          onMarkerFilterUpdate: widget.onMarkerFilterUpdate,
        ),
      ],
    );
  }
}
