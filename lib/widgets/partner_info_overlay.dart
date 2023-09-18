import "dart:developer";
import "dart:ui";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:latlong2/latlong.dart";
import "package:url_launcher/url_launcher.dart";
import "package:valon_kaupunki_app/api/model/location.dart";
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:valon_kaupunki_app/location_utils.dart";
import "package:valon_kaupunki_app/widgets/height_constrained_image.dart";
import "package:valon_kaupunki_app/widgets/property_info.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

import "../api/api_categories.dart";
import "../api/strapi_client.dart";

class PartnerInfoOverlay extends StatefulWidget {
  final StrapiPartner strapiPartner;
  final LatLng? currentLocation;
  final bool showFullScreenButton;
  final StrapiFavouritePartner? initialFavouritePartner;
  final void Function(StrapiFavouritePartner strapiFavouritePartner)
      onToggleFavourite;
  final void Function() onClose;

  const PartnerInfoOverlay({
    super.key,
    required this.strapiPartner,
    required this.onClose,
    required this.currentLocation,
    required this.onToggleFavourite,
    required this.showFullScreenButton,
    this.initialFavouritePartner,
  });

  @override
  State<PartnerInfoOverlay> createState() => _PartnerInfoOverlayState();
}

class _PartnerInfoOverlayState extends State<PartnerInfoOverlay> {
  bool _loading = false;
  bool _showFullScreenImage = false;
  final StrapiClient _apiClient = StrapiClient.instance();
  late AppLocalizations _localizations;
  StrapiFavouritePartner? _favouritePartner;

  String get _name => widget.strapiPartner.partner.name;
  String? get _imageUrl => widget.strapiPartner.partner.image?.image.url;
  String get _subTitle => widget.strapiPartner.partner.name;
  String? get _description => widget.strapiPartner.partner.description;
  String? get _address => widget.strapiPartner.partner.address;
  String get _category => getPartnerCategoryLabel(
        widget.strapiPartner.partner.category,
        _localizations,
      );
  Location get _location => widget.strapiPartner.partner.location;
  String? get _link => widget.strapiPartner.partner.link;

  @override
  void initState() {
    super.initState();
    _favouritePartner = widget.initialFavouritePartner;
  }

  Widget _likeButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: () async {
          try {
            if (_favouritePartner == null) {
              setState(() => _loading = true);

              final favouritePartner =
                  await _apiClient.addFavouritePartner(widget.strapiPartner.id);

              widget.onToggleFavourite(favouritePartner);
              setState(() {
                _loading = false;
                _favouritePartner = favouritePartner;
              });
            } else {
              setState(() => _loading = true);

              await _apiClient.removeFavouritePartner(_favouritePartner!);

              widget.onToggleFavourite(_favouritePartner!);
              setState(() {
                _loading = false;
                _favouritePartner = null;
              });
            }
          } on Exception catch (error) {
            log("Could not add favourite partner: $error");

            Fluttertoast.showToast(
              msg: _localizations.cannotAddFavouritePartner(
                widget.strapiPartner.partner.name,
              ),
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(
            side: BorderSide(color: CustomThemeValues.appOrange),
          ),
          padding: const EdgeInsets.all(8),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black38,
        ),
        child: _loading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 1.5,
              )
            : Icon(
                _favouritePartner != null
                    ? Icons.favorite
                    : Icons.favorite_outline,
                color: Colors.white,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _localizations = AppLocalizations.of(context)!;

    if (_imageUrl != null && _showFullScreenImage) {
      return WillPopScope(
        onWillPop: () async {
          setState(() => _showFullScreenImage = false);
          return false;
        },
        child: GestureDetector(
          onVerticalDragCancel: () =>
              setState(() => _showFullScreenImage = false),
          child: SizedBox.expand(
            child: Container(
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40, left: 4),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () =>
                            setState(() => _showFullScreenImage = false),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Image.network(_imageUrl!),
                  ),
                ],
              ),
            ),
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
                    _name,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                actions: [
                  if (widget.showFullScreenButton)
                    IconButton(
                      icon: const Icon(
                        Icons.open_in_full,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          setState(() => _showFullScreenImage = true),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        _imageUrl != null
                            ? HeightConstrainedImage.network(
                                height: 200,
                                radius: 00,
                                url: _imageUrl!,
                              )
                            : Image.asset(
                                Assets.valonKaupunkiBackground,
                                height: 200,
                                width: Size.infinite.width,
                                fit: BoxFit.cover,
                              ),
                        Positioned.fill(
                          bottom: 8,
                          right: 8,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: _likeButton(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _subTitle,
                              textAlign: TextAlign.left,
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (_description != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _description!,
                                  textAlign: TextAlign.left,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: PropertyInfo(
                        leading: SvgPicture.asset(
                          Assets.attractionsIcon,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: _localizations.category,
                        text: _category,
                        trailing: null,
                      ),
                    ),
                    if (_address != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: PropertyInfo(
                          leading: SvgPicture.asset(
                            Assets.homeIcon,
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          title: _localizations.address,
                          text: _address!,
                          trailing: null,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: PropertyInfo(
                        leading: SvgPicture.asset(
                          Assets.locationIcon,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: _localizations.distanceToTarget,
                        text: widget.currentLocation == null
                            ? "- m"
                            : LocationUtils.formatDistance(
                                _location.toMarkerType(),
                                widget.currentLocation!,
                              ),
                        trailing: null,
                      ),
                    ),
                    if (_link != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: PropertyInfo(
                          leading: const Icon(
                            Icons.link,
                            color: Colors.white,
                          ),
                          title: _localizations.link,
                          text: _link!,
                          trailing: null,
                          onTap: () => launchUrl(
                            Uri.parse(_link!),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
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
