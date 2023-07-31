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
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";
import "package:valon_kaupunki_app/api/strapi_client.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:valon_kaupunki_app/preferences/preferences.dart";
import "package:valon_kaupunki_app/widgets/attraction_info_overlay.dart";
import "package:valon_kaupunki_app/widgets/coupon_overlay.dart";
import "package:valon_kaupunki_app/widgets/filter_button_list.dart";
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
  final List<_MarkerData> _allMarkers = List.empty(growable: true);
  List<_MarkerData> _markers = List.empty(growable: true);

  final StrapiClient _client = StrapiClient.instance();
  final List<StrapiAttraction> _attractions = List.empty(growable: true);

  final List<StrapiPartner> _partners = List.empty(growable: true);
  late final AppLocalizations _localizations = AppLocalizations.of(context)!;

  late final Stream<LocationMarkerPosition?> _posStream;
  final Set<int> _usedBenefits = {};
  final List<StrapiBenefit> _benefits = List.empty(growable: true);

  LatLng? _currentLocation;
  Widget? _currentOverlay;

  _Section _currentSection = _Section.home;
  String get _title => _currentSection.localizedTitle(_localizations);

  double _compassAngle = 0.0;
  bool _dataFetchFailed = false;

  LatLng? _lastTapTarget;
  double _zoomLevel = 12.0;

  bool _showPermanentAttractions = Preferences.showPermanentAttractions;
  bool _showEventAttractions = Preferences.showEventAttractions;

  bool _showRestaurants = Preferences.showRestaurants;
  bool _showCafes = Preferences.showCafes;

  bool _showBars = Preferences.showBars;
  bool _showShops = Preferences.showShops;

  bool _showOthers = Preferences.showOthers;

  // Builder functions for the list views
  Widget? _attractionsBuilder(BuildContext context, int index) {
    if (index >= _attractions.length) {
      return null;
    }

    final attraction = _attractions[index].attraction;
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

    final partner = _partners[index].partner;
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

    final benefit = _benefits[index].benefit;
    final alreadyUsed = _usedBenefits.contains(_benefits[index].id);
    if (benefit.partner?.data?.partner == null) {
      return null;
    }

    return LargeListCard(
      imageUrl: benefit.image?.image.url,
      couponText: benefit.title,
      couponBenefit: benefit.benefitText,
      validTo: benefit.validTo,
      partner: benefit.partner!.data!.partner,
      currentLocation: _currentLocation,
      readMore: alreadyUsed
          ? null
          : () {
              setState(() {
                _currentOverlay = CouponOverlay(
                  benefit: benefit,
                  currentLocation: _currentLocation,
                  onClose: () => setState(() => _currentOverlay = null),
                  onClaim: () async {
                    if (!await _client.claimBenefit(_benefits[index].id)) {
                      // Ideally, this should never happen. Benefits should be greyed out once used.
                      Fluttertoast.showToast(
                        msg: _localizations.cannotUseBenefit(benefit.title),
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    } else {
                      _usedBenefits.add(_benefits[index].id);
                    }

                    setState(() {
                      _currentOverlay = null;
                    });
                  },
                );
              });
            },
      alreadyUsed: alreadyUsed,
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
      _allMarkers.addAll(markers);
      _markers.addAll(_filterMarkers(markers));
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
      _attractions.addAll(attractionResp.data);

      final partnerResp = await _client.getPartners();
      _partners.clear();
      _partners.addAll(partnerResp.data);

      markers.addAll(_partners
          .map((e) => _MarkerData(e.partner.location.toMarkerType(),
              getPartnerMarkerAsset(e.partner.category)))
          .toList());

      final benefitsResp = await _client.getUsedBenefitsForDevice();
      _usedBenefits.clear();
      _usedBenefits.addAll(benefitsResp.map((e) => e.id));

      final allBenefitsResp = await _client.getBenefits();
      _benefits.clear();
      _benefits.addAll(allBenefitsResp.data);

      _allMarkers.clear();

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

  List<_MarkerData> _filterMarkers(List<_MarkerData> markers) {
    final result = List<_MarkerData>.empty(growable: true);

    if (_showPermanentAttractions) {
      result.addAll(markers
          .where((marker) => marker.asset == Assets.permanentAttractionAsset));
    }

    if (_showEventAttractions) {
      result.addAll(markers
          .where((marker) => marker.asset == Assets.eventAttractionAsset));
    }

    if (_showRestaurants) {
      result.addAll(markers
          .where((marker) => marker.asset == Assets.restaurantPartnerAsset));
    }

    if (_showCafes) {
      result.addAll(
          markers.where((marker) => marker.asset == Assets.cafePartnerAsset));
    }

    if (_showBars) {
      result.addAll(
          markers.where((marker) => marker.asset == Assets.barPartnerAsset));
    }

    if (_showShops) {
      result.addAll(
          markers.where((marker) => marker.asset == Assets.shopPartnerAsset));
    }

    if (_showOthers) {
      result.addAll(markers
          .where((marker) => marker.asset == Assets.genericPartnerAsset));
    }

    return result;
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
                            attraction.attraction.location.toMarkerType() ==
                            data.point)) {
                          final attractionInfo = AttractionInfoOverlay(
                            attraction: _attractions
                                .where((attraction) =>
                                    attraction.attraction.location
                                        .toMarkerType() ==
                                    data.point)
                                .first
                                .attraction,
                            currentLocation: _currentLocation,
                            onClose: () {
                              setState(() {
                                _currentOverlay = null;
                              });
                            },
                          );

                          setState(() {
                            _currentOverlay = attractionInfo;
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
      if (_currentSection == _Section.home)
        Padding(
          padding: const EdgeInsets.only(top: 104.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 40,
              child: FilterButtonList(
                onMarkerFilterUpdate: () => setState(() {
                  _markers = _filterMarkers(_allMarkers);
                }),
                onFilterPermanentAttractions: () async {
                  _showPermanentAttractions = !_showPermanentAttractions;
                  await Preferences.setShowPermanentAttractions(
                      _showPermanentAttractions);
                },
                onFilterEventAttractions: () async {
                  _showEventAttractions = !_showEventAttractions;
                  await Preferences.setShowEventAttractions(
                      _showEventAttractions);
                },
                onFilterRestaurants: () async {
                  _showRestaurants = !_showRestaurants;
                  await Preferences.setShowRestaurants(_showRestaurants);
                },
                onFilterBars: () async {
                  _showBars = !_showBars;
                  await Preferences.setShowBars(_showBars);
                },
                onFilterCafes: () async {
                  _showCafes = !_showCafes;
                  await Preferences.setShowCafes(_showCafes);
                },
                onFilterShops: () async {
                  _showShops = !_showShops;
                  await Preferences.setShowShops(_showShops);
                },
                onFilterOthers: () async {
                  _showOthers = !_showOthers;
                  await Preferences.setShowOthers(_showOthers);
                },
                permanentAttractionsState: _showPermanentAttractions,
                eventAttractionsState: _showEventAttractions,
                restaurantsState: _showRestaurants,
                barsState: _showBars,
                cafesState: _showCafes,
                shopsState: _showShops,
                othersState: _showOthers,
                showAssets: true,
                useColor: true,
              ),
            ),
          ),
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
              padding: const EdgeInsets.only(top: 144.0),
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
      child: _currentOverlay == null
          ? _buildMainContent()
          : Stack(
              children: [
                _buildMainContent(),
                _currentOverlay!,
              ],
            ),
    );
  }
}
