import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:flutter_map_animations/flutter_map_animations.dart";
import "package:flutter_map_location_marker/flutter_map_location_marker.dart";
import "package:flutter_map_tile_caching/flutter_map_tile_caching.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:latlong2/latlong.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:valon_kaupunki_app/api/api_categories.dart";
import "package:valon_kaupunki_app/api/model/attraction.dart";
import "package:valon_kaupunki_app/api/model/benefit.dart";
import "package:valon_kaupunki_app/api/model/partner.dart";
import "package:valon_kaupunki_app/api/strapi_client.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:valon_kaupunki_app/widgets/attraction_info_overlay.dart";
import "package:valon_kaupunki_app/widgets/large_list_card.dart";
import "package:valon_kaupunki_app/widgets/listing.dart";
import "package:valon_kaupunki_app/widgets/small_list_card.dart";

class _MarkerData {
  final LatLng point;
  final String asset;

  const _MarkerData(this.point, this.asset);
}

enum _Section {
  home,
  attractions,
  benefits,
  partners;

  String localizedTitle(AppLocalizations localizations) {
    return switch (this) {
      home => localizations.appName,
      attractions => localizations.attractionsButtonText,
      benefits => localizations.benefitsButtonText,
      partners => localizations.partnersButtonText,
    };
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final List<_MarkerData> _markers = List.empty(growable: true);

  final StrapiClient _client = StrapiClient.instance();
  final List<Attraction> _attractions = List.empty(growable: true);

  final List<Partner> _partners = List.empty(growable: true);
  late final AppLocalizations _localizations = AppLocalizations.of(context)!;

  late final Stream<LocationMarkerPosition?> _posStream;
  final List<Benefit> _benefits = List.empty(growable: true);

  LatLng? _currentLocation;
  AttractionInfoOverlay? _currentAttractionInfo;

  _Section _currentSection = _Section.home;
  String get _title => _currentSection.localizedTitle(_localizations);

  double _compassAngle = 0.0;
  bool _dataFetchFailed = false;

  LatLng? _lastTapTarget;
  double _zoomLevel = 12.0;

  // Builder functions for the list views
  Widget? _attractionsBuilder(BuildContext context, int index) {
    if (index >= _attractions.length) {
      return null;
    }

    final attraction = _attractions[index];
    return SmallListCard(
      index: index,
      leftIcon: SvgPicture.asset(
        Assets.attractionsIconAsset,
        colorFilter: ColorFilter.mode(
          attraction.category == "static"
              ? CustomThemeValues.appOrange
              : Colors.white,
          BlendMode.srcIn,
        ),
      ),
      title: getAttractionCategoryLabel(attraction.category, _localizations),
      text: attraction.title,
      proceedIcon: IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.arrow_forward,
          opticalSize: 24.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget? _partnersBuilder(BuildContext context, int index) {
    if (index >= _partners.length) {
      return null;
    }

    final partner = _partners[index];
    return SmallListCard(
      index: index,
      leftIcon: getPartnerCategoryIcon(partner.category),
      title: getPartnerCategoryLabel(partner.category, _localizations),
      text: partner.name,
      proceedIcon: IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.arrow_forward,
          opticalSize: 24.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget? _benefitsBuilder(BuildContext context, int index) {
    if (index >= _benefits.length) {
      return null;
    }

    final benefit = _benefits[index];
    return LargeListCard(
      imageUrl: benefit.image!.image.url,
      couponText: benefit.title,
      couponBenefit: benefit.benefitText,
      validTo: benefit.validTo!,
      partner: benefit.partner!.data!.partner,
      currentLocation: _currentLocation,
    );
  }

  Widget get _childForCurrentSection => Listing(
        builder: _dataFetchFailed
            ? (context, index) {
                if (index == 0) {
                  return Center(
                    child: Text(
                      _localizations.loadingDataFailed,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }

                return null;
              }
            : switch (_currentSection) {
                _Section.attractions => _attractionsBuilder,
                _Section.benefits => _benefitsBuilder,
                _Section.partners => _partnersBuilder,
                _ => throw Exception(
                    "Invalid section value to get child: $_currentSection"),
              },
      );

  static const double _animTargetZoom = 14.0;
  late final AnimatedMapController _animMapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeInOut,
    mapController: _mapController,
  );

  BottomNavigationBarItem _navBarItem(
      String label, String asset, Color color, void Function() clicked) {
    return BottomNavigationBarItem(
      label: label,
      icon: IconButton(
        icon: SvgPicture.asset(
          asset,
          colorFilter: ColorFilter.mode(
            color,
            BlendMode.srcIn,
          ),
        ),
        onPressed: clicked,
      ),
    );
  }

  void _addMarkers(List<_MarkerData> markers) {
    setState(() {
      _markers.addAll(markers);
    });
  }

  void _fetchData() async {
    setState(() {
      _dataFetchFailed = false;
    });

    try {
      final attractionResp = await _client.getAttractions();
      final markers = List<_MarkerData>.empty(growable: true);

      markers.addAll(attractionResp.data
          .map((e) => _MarkerData(e.attraction.location.toMarkerType(),
              getAttractionMarkerAsset(e.attraction.category)))
          .toList());

      _attractions.clear();
      _attractions.addAll(attractionResp.data.map((e) => e.attraction));

      final partnerResp = await _client.getPartners();
      markers.addAll(partnerResp.data
          .map((e) => _MarkerData(e.partner.location.toMarkerType(),
              getPartnerMarkerAsset(e.partner.category)))
          .toList());

      _partners.clear();
      _partners.addAll(partnerResp.data.map((e) => e.partner));

      final benefitsResp = await _client.getBenefits();
      _benefits.clear();
      _benefits.addAll(benefitsResp.data.map((e) => e.benefit));

      _markers.clear();
      _addMarkers(markers);
    } on Exception {
      await Fluttertoast.showToast(
        msg: _localizations.loadingDataFailed,
        toastLength: Toast.LENGTH_SHORT,
      );

      setState(() {
        _dataFetchFailed = true;
      });
    }
  }

  void _setSection(_Section section) {
    setState(() {
      _currentSection = section;
    });
  }

  Color _getColorForSection(_Section section) {
    return section == _currentSection
        ? CustomThemeValues.appOrange
        : Colors.white;
  }

  @override
  void initState() {
    super.initState();
    _fetchData();

    const dataStreamFactory = LocationMarkerDataStreamFactory();
    _posStream =
        dataStreamFactory.fromGeolocatorPositionStream().asBroadcastStream();
    _posStream.listen((event) {
      _currentLocation = event?.latLng;
    });
  }

  List<Widget> _buildMapContent() {
    final instance =
        FMTC.instance(const String.fromEnvironment("FMTC_STORE_NAME"));
    final provider = instance.getTileProvider();

    return [
      FlutterMap(
        mapController: _animMapController.mapController,
        options: MapOptions(
          center: _lastTapTarget ?? const LatLng(62.24147, 25.72088),
          zoom: _zoomLevel,
          maxZoom: 18,
          minZoom: 9,
          onMapEvent: (_) {
            _zoomLevel = _mapController.zoom;
            setState(() {
              _compassAngle = (pi / 180) *
                  (_mapController.rotation == 360.0
                      ? 0.0
                      : _mapController.rotation);
            });
          },
        ),
        children: [
          TileLayer(
            tileProvider: provider,
            backgroundColor: Colors.black,
            urlTemplate: const String.fromEnvironment("MAP_TILE_URL_TEMPLATE"),
            userAgentPackageName: "fi.metatavu.valon-kaupunki-app",
          ),
          CurrentLocationLayer(
            headingStream: const Stream.empty(),
            positionStream: _posStream,
          ),
          MarkerLayer(
            markers: _markers
                .map(
                  (data) => Marker(
                    point: data.point,
                    height: 80,
                    width: 80,
                    builder: (context) => GestureDetector(
                      child: SvgPicture.asset(data.asset),
                      onTap: () async {
                        if (_mapController.center != data.point) {
                          await _animMapController.animateTo(
                            dest: data.point,
                            zoom: _animTargetZoom,
                          );

                          _lastTapTarget = data.point;
                        }

                        if (_attractions.any((attraction) =>
                            attraction.location.toMarkerType() == data.point)) {
                          final attractionInfo = AttractionInfoOverlay(
                            attraction: _attractions
                                .where((attraction) =>
                                    attraction.location.toMarkerType() ==
                                    data.point)
                                .first,
                            currentLocation: _currentLocation,
                            onClose: () {
                              setState(() {
                                _currentAttractionInfo = null;
                              });
                            },
                          );

                          setState(() {
                            _currentAttractionInfo = attractionInfo;
                          });
                        }
                      },
                    ),
                  ),
                )
                .toList(growable: false),
            rotate: true,
          ),
        ],
      ),
      _currentSection != _Section.home
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                // Important empty container; flutter won't render the blur otherwise.
                child: Container(
                  color: Colors.transparent,
                  child: _childForCurrentSection,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 94.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () => _animMapController.animatedRotateTo(
                        0.0,
                        curve: Curves.easeInOut,
                      ),
                      iconSize: 36.0,
                      icon: Transform.rotate(
                        angle: _compassAngle - (pi / 4),
                        child: Icon(
                          Icons.explore,
                          color: _compassAngle == 0.0
                              ? Colors.white
                              : CustomThemeValues.appOrange,
                        ),
                      ),
                    ),
                    _currentLocation != null
                        ? IconButton(
                            icon: Icon(
                              Icons.location_on,
                              color: _mapController.bounds!
                                      .contains(_currentLocation!)
                                  ? Colors.white
                                  : CustomThemeValues.appOrange,
                            ),
                            iconSize: 36.0,
                            onPressed: () {
                              if (_currentLocation != null) {
                                _animMapController.animateTo(
                                  dest: _currentLocation,
                                  zoom: _animTargetZoom,
                                );
                              }
                            },
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
    ];
  }

  Widget _buildMainContent() {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60.0,
        backgroundColor: Colors.transparent.withAlpha(0x7F),
        centerTitle: true,
        title: Text(
          _title,
          style: theme.textTheme.bodyMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          iconSize: 24.0,
          color: Colors.white,
          onPressed: () => {},
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            // Important empty container; flutter won't render the blur otherwise.
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: BottomNavigationBar(
            enableFeedback: false,
            unselectedItemColor: Colors.white,
            selectedItemColor: CustomThemeValues.appOrange,
            unselectedLabelStyle: const TextStyle(color: Colors.white),
            selectedLabelStyle: TextStyle(color: CustomThemeValues.appOrange),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent.withAlpha(0x7F),
            currentIndex: _currentSection.index,
            items: [
              _navBarItem(_localizations.homeButtonText, Assets.homeIconAsset,
                  _getColorForSection(_Section.home), () {
                _setSection(_Section.home);
              }),
              _navBarItem(
                  _localizations.attractionsButtonText,
                  Assets.attractionsIconAsset,
                  _getColorForSection(_Section.attractions), () {
                _setSection(_Section.attractions);
              }),
              _navBarItem(
                  _localizations.benefitsButtonText,
                  Assets.benefitsIconAsset,
                  _getColorForSection(_Section.benefits), () {
                _setSection(_Section.benefits);
              }),
              _navBarItem(
                  _localizations.partnersButtonText,
                  Assets.partnersIconAsset,
                  _getColorForSection(_Section.partners), () {
                _setSection(_Section.partners);
              }),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: _buildMapContent(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: const Color.fromARGB(0x7F, 0x1B, 0x26, 0x37),
      color: Colors.white,
      onRefresh: () async {
        _fetchData();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: _currentAttractionInfo == null
          ? _buildMainContent()
          : Stack(
              children: [
                _buildMainContent(),
                _currentAttractionInfo!,
              ],
            ),
    );
  }
}
