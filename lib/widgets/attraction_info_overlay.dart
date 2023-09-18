import "dart:developer";
import "dart:ui";
import "package:cancellation_token_http/http.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:latlong2/latlong.dart";
import "package:url_launcher/url_launcher.dart";
import "package:valon_kaupunki_app/api/caching_audio_client.dart";
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

class AttractionInfoOverlay extends StatefulWidget {
  final StrapiAttraction strapiAttraction;
  final LatLng? currentLocation;
  final bool showFullScreenButton;
  final StrapiFavouriteUser? initialFavouriteAttraction;
  final void Function(StrapiFavouriteUser) onToggleFavourite;
  final void Function() onClose;

  const AttractionInfoOverlay({
    super.key,
    required this.strapiAttraction,
    required this.onClose,
    required this.currentLocation,
    required this.onToggleFavourite,
    required this.showFullScreenButton,
    this.initialFavouriteAttraction,
  });

  @override
  State<AttractionInfoOverlay> createState() => _AttractionInfoOverlayState();
}

class _AttractionInfoOverlayState extends State<AttractionInfoOverlay> {
  bool _loading = false;
  bool _showFullScreenImage = false;
  bool _downloading = false;
  bool _playing = false;
  bool _paused = false;
  double _playProgress = -1;
  final CancellationToken _cancel = CancellationToken();
  final _audioCacheClient = CachingAudioClient.getInstance();
  final StrapiClient _apiClient = StrapiClient.instance();
  late AppLocalizations _localizations;
  StrapiFavouriteUser? _favouriteAttraction;

  String get _title => widget.strapiAttraction.attraction.title;
  String? get _imageUrl => widget.strapiAttraction.attraction.image?.image.url;
  String get _subTitle => widget.strapiAttraction.attraction.subTitle;
  String? get _description => widget.strapiAttraction.attraction.description;
  String? get _address => widget.strapiAttraction.attraction.address;
  String? get _link => widget.strapiAttraction.attraction.link;
  String get _category => getAttractionCategoryLabel(
        widget.strapiAttraction.attraction.category,
        _localizations,
      );
  Location get _location => widget.strapiAttraction.attraction.location;
  String? get _artist => widget.strapiAttraction.attraction.artist;
  Sound? get _sound => widget.strapiAttraction.attraction.sound?.sound;

  @override
  void initState() {
    super.initState();
    _audioCacheClient.reinitPlayer();
    _favouriteAttraction = widget.initialFavouriteAttraction;
  }

  @override
  void dispose() {
    super.dispose();

    if (_downloading) {
      Fluttertoast.showToast(
        msg: _localizations.downloadInterrupted,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
    _audioCacheClient.player.dispose();
    _cancel.cancel();
  }

  Future<void> _playSound(String url) async {
    _audioCacheClient.play(url, _cancel, (progress, [time]) {
      switch (progress) {
        case PlayingState.downloading:
          setState(() {
            _downloading = true;
          });
        case PlayingState.playing:
          setState(() {
            _downloading = false;
            _playing = true;
            _playProgress = time!;
          });
        case PlayingState.done:
          setState(() {
            _playing = false;
            _playProgress = -1;
          });
        default:
      }
    });
  }

  Widget _soundButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_downloading || _playing)
          SizedBox(
            height: 35,
            width: 35,
            child: _downloading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : CircularProgressIndicator(
                    color: CustomThemeValues.appOrange,
                    value: _playProgress.isFinite ? _playProgress : 0,
                  ),
          ),
        SizedBox(
          height: 40,
          width: 40,
          child: ElevatedButton(
            onPressed: () async {
              if (_playing) {
                setState(() {
                  _paused = !_paused;
                  if (_paused) {
                    _audioCacheClient.player.pause();
                  } else {
                    _audioCacheClient.player.resume();
                  }
                });
              } else {
                if (widget.strapiAttraction.attraction.sound != null) {
                  _playSound(
                      widget.strapiAttraction.attraction.sound!.sound.url);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(
                side: BorderSide(color: CustomThemeValues.appOrange),
              ),
              padding: const EdgeInsets.all(8),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
            ),
            child: Icon(
              _playing
                  ? (_paused ? Icons.play_arrow_outlined : Icons.pause_outlined)
                  : Icons.volume_up_outlined,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _likeButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: _loading
            ? null
            : () async {
                try {
                  if (_favouriteAttraction == null) {
                    setState(() => _loading = true);
                    final favouriteAttraction = await _apiClient
                        .addFavouriteAttraction(widget.strapiAttraction.id);

                    widget.onToggleFavourite(favouriteAttraction);

                    setState(() {
                      _favouriteAttraction = favouriteAttraction;
                      _loading = false;
                    });
                  } else {
                    setState(() => _loading = true);
                    await _apiClient.removeFavouriteAttraction(
                      _favouriteAttraction!,
                    );

                    widget.onToggleFavourite(_favouriteAttraction!);
                    setState(() {
                      _favouriteAttraction = null;
                      _loading = false;
                    });
                  }
                } on Exception catch (error) {
                  log("Could not toggle favourite attraction: $error");

                  Fluttertoast.showToast(
                    msg: _localizations.cannotAddFavouriteAttraction(
                      widget.strapiAttraction.attraction.title,
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
                _favouriteAttraction != null
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
                    _title,
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
                                if (_sound != null) _soundButton(),
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
                    if (_artist != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: PropertyInfo(
                          leading: SvgPicture.asset(
                            Assets.designerIcon,
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          title: _localizations.designer,
                          text: _artist!,
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
