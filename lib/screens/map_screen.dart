import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:flutter_map_animations/flutter_map_animations.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:latlong2/latlong.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:valon_kaupunki_app/api/strapi_client.dart";
import "package:valon_kaupunki_app/assets.dart";

class _MarkerData {
  final LatLng point;
  final String asset;

  const _MarkerData(this.point, this.asset);
}

enum _Section {
  home,
  exhibits,
  benefits,
  partners,
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
  _Section _currentSection = _Section.home;

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

  String _getMarkerAsset(String category) {
    return {
          "static": Assets.staticExhibitAsset,
          "event": Assets.eventExhibitAsset
        }[category] ??
        "";
  }

  void _fetchMarkers() async {
    final attractionResp = await _client.getAttractions();
    _addMarkers(attractionResp.data
        .map((e) => _MarkerData(e!.attraction.location.toMarkerType(),
            _getMarkerAsset(e.attraction.category)))
        .toList());
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
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60.0,
        backgroundColor: Colors.transparent.withAlpha(0x7F),
        centerTitle: true,
        title: Text(
          loc.appName,
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
              _navBarItem(loc.homeButtonText, Assets.homeIconAsset,
                  _getColorForSection(_Section.home), () {
                _setSection(_Section.home);
              }),
              _navBarItem(loc.exhibitsButtonText, Assets.exhibitsIconAsset,
                  _getColorForSection(_Section.exhibits), () {
                _setSection(_Section.exhibits);
              }),
              _navBarItem(loc.benefitsButtonText, Assets.benefitsIconAsset,
                  _getColorForSection(_Section.benefits), () {
                _setSection(_Section.benefits);
              }),
              _navBarItem(loc.partnersButtonText, Assets.partnersIconAsset,
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
                          onTap: () => _animMapController.animateTo(
                            dest: data.point,
                            zoom: _animTargetZoom,
                          ),
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
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
