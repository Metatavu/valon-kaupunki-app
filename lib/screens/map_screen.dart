import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:latlong2/latlong.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:valon_kaupunki_app/assets.dart";

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _markers = List.empty(growable: true);

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
            unselectedItemColor: Colors.white,
            selectedItemColor: Colors.orange,
            unselectedLabelStyle: const TextStyle(color: Colors.white),
            selectedLabelStyle: const TextStyle(color: Colors.orange),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent.withAlpha(0x7F),
            items: [
              _navBarItem(loc.homeButtonText, Assets.homeIconAsset,
                  Colors.orange, () {}),
              _navBarItem(loc.exhibitsButtonText, Assets.exhibitsIconAsset,
                  Colors.white, () {}),
              _navBarItem(loc.benefitsButtonText, Assets.benefitsIconAsset,
                  Colors.white, () {}),
              _navBarItem(loc.partnersButtonText, Assets.partnersIconAsset,
                  Colors.white, () {}),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: const LatLng(62.24147, 25.72088),
          zoom: 12,
          maxZoom: 18,
          minZoom: 9,
        ),
        children: [
          TileLayer(
            urlTemplate: const String.fromEnvironment("MAP_TILE_URL_TEMPLATE"),
            userAgentPackageName: "fi.metatavu.valon-kaupunki-app",
          ),
          MarkerLayer(
            markers: _markers
                .map(
                  (ll) => Marker(
                    point: ll,
                    height: 80,
                    width: 80,
                    builder: (context) =>
                        // has to be set accordingly when markers are fetched from API
                        SvgPicture.asset("assets/kiintea-suosikki.svg"),
                  ),
                )
                .toList(growable: false),
            rotate: true,
          ),
        ],
      ),
    );
  }
}
