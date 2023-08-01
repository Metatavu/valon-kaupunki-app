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

class TargetInfoOverlay extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

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
                  onPressed: onClose,
                ),
                title: Center(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                actions: [
                  if (showFullscreenButton)
                    IconButton(
                      icon: const Icon(
                        Icons.open_in_full,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    if (imageUrl != null)
                      HeightConstrainedImage.network(
                        height: 200,
                        radius: 00,
                        url: imageUrl!,
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subTitle,
                              textAlign: TextAlign.left,
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (description != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  description!,
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
                      text: category,
                      trailing: null,
                    ),
                    if (address != null)
                      PropertyInfo(
                        leading: SvgPicture.asset(
                          Assets.homeIconAsset,
                          width: 24.0,
                          height: 24.0,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                        title: localizations.address,
                        text: address!,
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
                      text: currentLocation == null
                          ? "- m"
                          : LocationUtils.formatDistance(
                              location.toMarkerType(),
                              currentLocation!,
                            ),
                      trailing: null,
                    ),
                    if (artist != null)
                      PropertyInfo(
                        leading: SvgPicture.asset(
                          Assets.designerIconAsset,
                          width: 24.0,
                          height: 24.0,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                        title: localizations.designer,
                        text: artist!,
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
