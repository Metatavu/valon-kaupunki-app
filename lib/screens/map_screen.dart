import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:flutter_map_animations/flutter_map_animations.dart";
import "package:flutter_map_tile_caching/flutter_map_tile_caching.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:latlong2/latlong.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:valon_kaupunki_app/api/model/attraction.dart";
import "package:valon_kaupunki_app/api/strapi_client.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/widgets/listing.dart";

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

  String localizedTitle(AppLocalizations loc) {
    return switch (this) {
      home => loc.appName,
      attractions => loc.attractionsButtonText,
      benefits => loc.benefitsButtonText,
      partners => loc.partnersButtonText,
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
  late final AppLocalizations _loc = AppLocalizations.of(context)!;

  _Section _currentSection = _Section.home;
  String get _title => _currentSection.localizedTitle(_loc);

  // Builder functions for the list views
  Widget? _attractionsBuilder(BuildContext context, int index) {
    if (index >= _attractions.length) {
      return null;
    }

    final attraction = _attractions[index];
    final theme = Theme.of(context);

    return SizedBox(
      height: 60.0,
      child: Padding(
        padding: EdgeInsets.only(top: index == 0 ? 0.0 : 4.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black38,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SvgPicture.asset(Assets.attractionsIconAsset),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCategoryLabel(attraction.category),
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      attraction.title,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.arrow_forward,
                  opticalSize: 24.0,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget get _childForCurrentSection => Listing(
        builder: switch (_currentSection) {
          _Section.attractions => _attractionsBuilder,
          //_Section.benefits => _benefitsBuilder,
          //_Section.partners => _partnersBuilder,
          _ => throw Exception(
              "invalid section value to get child: $_currentSection"),
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

  String _getAttractionMarkerAsset(String category) {
    return {
          "static": Assets.permanentAttractionAsset,
          "event": Assets.eventAttractionAsset
        }[category] ??
        "";
  }

  String _getPartnerMarkerAsset(String category) {
    return {
          "restaurant": Assets.restaurantPartnerAsset,
          "cafe": Assets.cafePartnerAsset,
          "bar": Assets.barPartnerAsset,
          "shop": Assets.shopPartnerAsset,
          "other": Assets.genericPartnerAsset,
        }[category] ??
        "";
  }

  String _getCategoryLabel(String category) {
    return {
      "static": _loc.permanentAttractionText,
      "event": _loc.eventAttractionText,
    }[category]!;
  }

  void _fetchMarkers() async {
    final attractionResp = await _client.getAttractions();
    final markers = List<_MarkerData>.empty(growable: true);

    markers.addAll(attractionResp.data
        .map((e) => _MarkerData(e.attraction.location.toMarkerType(),
            _getAttractionMarkerAsset(e.attraction.category)))
        .toList());

    _attractions.addAll(attractionResp.data.map((e) => e.attraction));

    final partnerResp = await _client.getPartners();
    markers.addAll(partnerResp.data
        .map((e) => _MarkerData(e.partner.location.toMarkerType(),
            _getPartnerMarkerAsset(e.partner.category)))
        .toList());

    _addMarkers(markers);
  }

  void _setSection(_Section section) {
    setState(() {
      _currentSection = section;
    });
  }

  Color _getColorForSection(_Section section) {
    return section == _currentSection ? Colors.orange : Colors.white;
  }

  @override
  void initState() {
    super.initState();
    _fetchMarkers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instance =
        FMTC.instance(const String.fromEnvironment("FMTC_STORE_NAME"));
    final provider = instance.getTileProvider();

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
            selectedItemColor: Colors.orange,
            unselectedLabelStyle: const TextStyle(color: Colors.white),
            selectedLabelStyle: const TextStyle(color: Colors.orange),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent.withAlpha(0x7F),
            currentIndex: _currentSection.index,
            items: [
              _navBarItem(_loc.homeButtonText, Assets.homeIconAsset,
                  _getColorForSection(_Section.home), () {
                _setSection(_Section.home);
              }),
              _navBarItem(
                  _loc.attractionsButtonText,
                  Assets.attractionsIconAsset,
                  _getColorForSection(_Section.attractions), () {
                _setSection(_Section.attractions);
              }),
              _navBarItem(_loc.benefitsButtonText, Assets.benefitsIconAsset,
                  _getColorForSection(_Section.benefits), () {
                _setSection(_Section.benefits);
              }),
              _navBarItem(_loc.partnersButtonText, Assets.partnersIconAsset,
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
        children: [
          FlutterMap(
            mapController: _animMapController.mapController,
            options: MapOptions(
              center: const LatLng(62.24147, 25.72088),
              zoom: 12,
              maxZoom: 18,
              minZoom: 9,
            ),
            children: [
              TileLayer(
                tileProvider: provider,
                backgroundColor: Colors.black,
                urlTemplate:
                    const String.fromEnvironment("MAP_TILE_URL_TEMPLATE"),
                userAgentPackageName: "fi.metatavu.valon-kaupunki-app",
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
                          onTap: () => {
                            if (_mapController.center != data.point)
                              _animMapController.animateTo(
                                dest: data.point,
                                zoom: _animTargetZoom,
                              )
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
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
