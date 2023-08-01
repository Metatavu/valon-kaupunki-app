import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class FilterButtonList extends StatefulWidget {
  final void Function() onMarkerFilterUpdate;

  final void Function() onFilterPermanentAttractions;
  final void Function() onFilterEventAttractions;
  final void Function() onFilterRestaurants;
  final void Function() onFilterCafes;
  final void Function() onFilterBars;
  final void Function() onFilterShops;
  final void Function() onFilterOthers;

  final bool permanentAttractionsState;
  final bool eventAttractionsState;
  final bool restaurantsState;
  final bool cafesState;
  final bool barsState;
  final bool shopsState;
  final bool othersState;

  const FilterButtonList({
    required this.onMarkerFilterUpdate,
    required this.onFilterPermanentAttractions,
    required this.onFilterEventAttractions,
    required this.onFilterRestaurants,
    required this.onFilterCafes,
    required this.onFilterBars,
    required this.onFilterShops,
    required this.onFilterOthers,
    required this.permanentAttractionsState,
    required this.eventAttractionsState,
    required this.restaurantsState,
    required this.cafesState,
    required this.barsState,
    required this.shopsState,
    required this.othersState,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FilterButtonListState();
}

class _FilterButtonListState extends State<FilterButtonList> {
  late AppLocalizations _localizations;

  Widget _filterButton({
    required String iconAsset,
    required String label,
    required Color color,
    required void Function() onClick,
    required bool state,
    bool noPad = false,
  }) {
    final theme = Theme.of(context);

    var style = theme.outlinedButtonTheme.style!.copyWith(
      padding: const MaterialStatePropertyAll(
        EdgeInsets.only(left: 8.0, right: 8.0),
      ),
      side: MaterialStatePropertyAll(theme.outlinedButtonTheme.style!.side!
          .resolve({})!.copyWith(color: color)),
    );

    var textStyle = theme.outlinedButtonTheme.style!.textStyle!
        .resolve({})!.copyWith(color: color);
    var svgColor = color;

    if (state) {
      style = style.copyWith(
        backgroundColor: MaterialStatePropertyAll(color),
      );

      textStyle = textStyle.copyWith(
        color: Colors.white,
      );

      svgColor = Colors.white;
    }

    return Padding(
      padding: EdgeInsets.only(right: noPad ? 0.0 : 8.0),
      child: OutlinedButton(
        onPressed: () {
          onClick();
          widget.onMarkerFilterUpdate();
        },
        style: style,
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                label,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;

    return ListView(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      children: [
        _filterButton(
          iconAsset: Assets.attractionsIconAsset,
          label: _localizations.permanentAttractionsFilterText,
          color: CustomThemeValues.appOrange,
          onClick: widget.onFilterPermanentAttractions,
          state: widget.permanentAttractionsState,
        ),
        _filterButton(
          iconAsset: Assets.attractionsIconAsset,
          label: _localizations.eventAttractionsFilterText,
          color: CustomThemeValues.eventColor,
          onClick: widget.onFilterEventAttractions,
          state: widget.eventAttractionsState,
        ),
        _filterButton(
          iconAsset: Assets.restaurantPartnerAssetIcon,
          label: _localizations.restaurantsFilterText,
          color: CustomThemeValues.restaurantColor,
          onClick: widget.onFilterRestaurants,
          state: widget.restaurantsState,
        ),
        _filterButton(
          iconAsset: Assets.barPartnerAssetIcon,
          label: _localizations.barsFilterText,
          color: CustomThemeValues.barsColor,
          onClick: widget.onFilterBars,
          state: widget.barsState,
        ),
        _filterButton(
          iconAsset: Assets.cafePartnerAssetIcon,
          label: _localizations.cafesFilterText,
          color: CustomThemeValues.cafeColor,
          onClick: widget.onFilterCafes,
          state: widget.cafesState,
        ),
        _filterButton(
          iconAsset: Assets.shopPartnerAssetIcon,
          label: _localizations.shopsFilterText,
          color: CustomThemeValues.shopsColor,
          onClick: widget.onFilterShops,
          state: widget.shopsState,
        ),
        _filterButton(
          iconAsset: Assets.genericPartnerAssetIcon,
          label: _localizations.othersFilterText,
          color: CustomThemeValues.othersColor,
          noPad: true,
          onClick: widget.onFilterOthers,
          state: widget.othersState,
        ),
      ],
    );
  }
}
