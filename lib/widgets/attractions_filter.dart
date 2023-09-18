import "package:flutter/material.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:valon_kaupunki_app/widgets/filter_button.dart";

class AttractionsFilter extends StatefulWidget {
  final void Function() onFilterPermanentAttractions;
  final void Function() onFilterEventLightArtPieces;
  final void Function() onMarkerFilterUpdate;

  final bool permanentAttractionsState;
  final bool eventLightArtPiecesState;

  const AttractionsFilter({
    required this.onFilterPermanentAttractions,
    required this.onFilterEventLightArtPieces,
    required this.permanentAttractionsState,
    required this.eventLightArtPiecesState,
    required this.onMarkerFilterUpdate,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AttractionsFilterState();
}

class _AttractionsFilterState extends State<AttractionsFilter> {
  late AppLocalizations _localizations;

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: FilterButton(
            iconAsset: Assets.attractionsIcon,
            label: _localizations.permanentAttractionsText,
            color: CustomThemeValues.appOrange,
            state: widget.permanentAttractionsState,
            onClick: widget.onFilterPermanentAttractions,
            onMarkerFilterUpdate: widget.onMarkerFilterUpdate,
          ),
        ),
        FilterButton(
          iconAsset: Assets.eventLightArtPieceIcon,
          label: _localizations.eventLightArtPiecesText,
          color: CustomThemeValues.lightArtPieceColor,
          state: widget.eventLightArtPiecesState,
          onClick: widget.onFilterEventLightArtPieces,
          onMarkerFilterUpdate: widget.onMarkerFilterUpdate,
        ),
      ],
    );
  }
}
