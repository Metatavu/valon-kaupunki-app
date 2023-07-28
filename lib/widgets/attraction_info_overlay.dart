import "dart:ui";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:latlong2/latlong.dart";
import "package:valon_kaupunki_app/api/api_categories.dart";
import "package:valon_kaupunki_app/api/model/attraction.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/location_utils.dart";
import "package:valon_kaupunki_app/widgets/height_constrained_image.dart";
import "package:valon_kaupunki_app/widgets/property_info.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class AttractionInfoOverlay extends StatefulWidget {
  final Attraction attraction;
  final LatLng? currentLocation;
  final void Function() onClose;

  const AttractionInfoOverlay({
    super.key,
    required this.attraction,
    required this.currentLocation,
    required this.onClose,
  });

  @override
  State<AttractionInfoOverlay> createState() => _AttractionInfoOverlayState();
}

class _AttractionInfoOverlayState extends State<AttractionInfoOverlay> {
  bool _showFullscreenImage = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    if (widget.attraction.image != null && _showFullscreenImage) {
      return WillPopScope(
        onWillPop: () async {
          final retval = !_showFullscreenImage;
          setState(() {
            _showFullscreenImage = false;
          });

          return retval;
        },
        child: SizedBox.expand(
          child: Container(
            color: Colors.black54,
            child: Image.network(widget.attraction.image!.image.url),
          ),
        ),
      );
    } else {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: SizedBox.expand(
            child: Container(
              color: Colors.black38,
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.black,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: widget.onClose,
                    ),
                    title: Center(
                      child: Text(
                        widget.attraction.title,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.open_in_full,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(() {
                          _showFullscreenImage = true;
                        }),
                      ),
                    ],
                  ),
                  if (widget.attraction.image != null)
                    HeightConstrainedImage.network(
                      height: 200,
                      radius: 00,
                      url: widget.attraction.image!.image.url,
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.attraction.subTitle,
                            textAlign: TextAlign.left,
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (widget.attraction.description != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                widget.attraction.description!,
                                textAlign: TextAlign.left,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  PropertyInfo(
                    leading: SvgPicture.asset(
                      Assets.attractionsIconAsset,
                      width: 24.0,
                      height: 24.0,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    title: localizations.category,
                    text: getAttractionCategoryLabel(
                        widget.attraction.category, localizations),
                    trailing: null,
                  ),
                  if (widget.attraction.address != null)
                    PropertyInfo(
                      leading: SvgPicture.asset(
                        Assets.homeIconAsset,
                        width: 24.0,
                        height: 24.0,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
                      title: localizations.address,
                      text: widget.attraction.address!,
                      trailing: null,
                    ),
                  PropertyInfo(
                    leading: SvgPicture.asset(
                      Assets.locationIconAsset,
                      width: 24.0,
                      height: 24.0,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    title: localizations.distanceToTarget,
                    text: widget.currentLocation == null
                        ? "- m"
                        : LocationUtils.formatDistance(
                            widget.attraction.location.toMarkerType(),
                            widget.currentLocation!,
                          ),
                    trailing: null,
                  ),
                  if (widget.attraction.artist != null)
                    PropertyInfo(
                      leading: SvgPicture.asset(
                        Assets.designerIconAsset,
                        width: 24.0,
                        height: 24.0,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
                      title: localizations.designer,
                      text: widget.attraction.artist!,
                      trailing: null,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
