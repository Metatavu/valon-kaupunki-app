import "dart:ui";
import "package:cancellation_token_http/http.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:latlong2/latlong.dart";
import "package:valon_kaupunki_app/api/caching_audio_client.dart";
import "package:valon_kaupunki_app/api/model/location.dart";
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
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
  final Sound? sound;

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
    required this.sound,
  });

  @override
  State<TargetInfoOverlay> createState() => _TargetInfoOverlayState();
}

class _TargetInfoOverlayState extends State<TargetInfoOverlay> {
  bool _showFullscreenImage = false;
  bool _downloading = false;
  bool _playing = false;
  bool _paused = false;
  double _playProgress = -1.0;
  final CancellationToken _cancel = CancellationToken();
  final _client = CachingAudioClient.getInstance();
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _client.reinitPlayer();
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
    _client.player.dispose();
    _cancel.cancel();
  }

  Future<void> _playSound() async {
    _client.play(widget.sound!.url, _cancel, (progress, [time]) {
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
            _playProgress = -1.0;
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
                    value: _playProgress.isFinite ? _playProgress : 0.0,
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
                    _client.player.pause();
                  } else {
                    _client.player.resume();
                  }
                });
              } else {
                _playSound();
              }
            },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(
                side: BorderSide(color: CustomThemeValues.appOrange),
              ),
              padding: const EdgeInsets.all(8.0),
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
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(
            side: BorderSide(color: CustomThemeValues.appOrange),
          ),
          padding: const EdgeInsets.all(8.0),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black38,
        ),
        child: const Icon(
          Icons.favorite_outline,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _localizations = AppLocalizations.of(context)!;

    if (widget.imageUrl != null && _showFullscreenImage) {
      return WillPopScope(
        onWillPop: () async {
          setState(() {
            _showFullscreenImage = false;
          });

          return false;
        },
        child: GestureDetector(
          onVerticalDragCancel: () => setState(() {
            _showFullscreenImage = false;
          }),
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
                        onPressed: () {
                          setState(() {
                            _showFullscreenImage = false;
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Image.network(widget.imageUrl!),
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
                    Stack(
                      children: [
                        if (widget.imageUrl != null)
                          HeightConstrainedImage.network(
                            height: 200,
                            radius: 00,
                            url: widget.imageUrl!,
                          ),
                        Positioned.fill(
                          bottom: 8.0,
                          right: 8.0,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (widget.sound != null) _soundButton(),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
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
                      title: _localizations.category,
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
                        title: _localizations.address,
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
                      title: _localizations.distanceToTarget,
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
                        title: _localizations.designer,
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
