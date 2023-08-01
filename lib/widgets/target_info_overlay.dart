import "dart:ui";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:latlong2/latlong.dart";
import "package:valon_kaupunki_app/api/model/location.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/location_utils.dart";
import "package:valon_kaupunki_app/widgets/height_constrained_image.dart";
import "package:valon_kaupunki_app/widgets/property_info.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class TargetInfoOverlay extends StatefulWidget {
  final LatLng? currentLocation;
  final void Function() onClose;
  final bool showFullscreenButton;
  final String title;
  final String? imageUrl;
  final String subTitle;
  final String? description;
  final String? address;
  final String category;
  final Location location;
  final String? artist;

  const TargetInfoOverlay({
    super.key,
    required this.currentLocation,
    required this.onClose,
    required this.showFullscreenButton,
    required this.title,
    required this.imageUrl,
    required this.subTitle,
    required this.description,
    required this.address,
    required this.category,
    required this.location,
    required this.artist,
  });

  @override
  State<TargetInfoOverlay> createState() => _TargetInfoOverlayState();
}

class _TargetInfoOverlayState extends State<TargetInfoOverlay> {
  bool _showFullscreenImage = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    if (widget.imageUrl != null && _showFullscreenImage) {
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
            color: Colors.black,
            child: Image.network(widget.imageUrl!),
          ),
        ),
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: SizedBox.expand(
          child: Container(
            color: Colors.black38,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
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
                    widget.title,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                actions: [
                  if (widget.showFullscreenButton)
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
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    if (widget.imageUrl != null)
                      HeightConstrainedImage.network(
                        height: 200,
                        radius: 00,
                        url: widget.imageUrl!,
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.subTitle,
                              textAlign: TextAlign.left,
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (widget.description != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  widget.description!,
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
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
                      title: localizations.category,
                      text: widget.category,
                      trailing: null,
                    ),
                    if (widget.address != null)
                      PropertyInfo(
                        leading: SvgPicture.asset(
                          Assets.homeIconAsset,
                          width: 24.0,
                          height: 24.0,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                        title: localizations.address,
                        text: widget.address!,
                        trailing: null,
                      ),
                    PropertyInfo(
                      leading: SvgPicture.asset(
                        Assets.locationIconAsset,
                        width: 24.0,
                        height: 24.0,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
                      title: localizations.distanceToTarget,
                      text: widget.currentLocation == null
                          ? "- m"
                          : LocationUtils.formatDistance(
                              widget.location.toMarkerType(),
                              widget.currentLocation!,
                            ),
                      trailing: null,
                    ),
                    if (widget.artist != null)
                      PropertyInfo(
                        leading: SvgPicture.asset(
                          Assets.designerIconAsset,
                          width: 24.0,
                          height: 24.0,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                        title: localizations.designer,
                        text: widget.artist!,
                        trailing: null,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
