import "dart:developer";
import "dart:ui";
import "package:collection/collection.dart";

import "package:dropdown_button2/dropdown_button2.dart";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:flutter_map_animations/flutter_map_animations.dart";
import "package:flutter_map_location_marker/flutter_map_location_marker.dart";
import "package:flutter_map_tile_caching/flutter_map_tile_caching.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:latlong2/latlong.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:permission_handler/permission_handler.dart";
import "package:valon_kaupunki_app/api/api_categories.dart";
import "package:valon_kaupunki_app/api/model/benefit.dart";
import "package:valon_kaupunki_app/api/model/strapi_resp.dart";
import "package:valon_kaupunki_app/api/strapi_client.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:valon_kaupunki_app/location_utils.dart";
import "package:valon_kaupunki_app/main.dart";
import "package:valon_kaupunki_app/preferences/preferences.dart";
import "package:valon_kaupunki_app/screens/welcome_screen.dart";
import "package:valon_kaupunki_app/widgets/attractions_filter.dart";
import "package:valon_kaupunki_app/widgets/partner_info_overlay.dart";
import "package:valon_kaupunki_app/widgets/partners_filter.dart";
import "package:valon_kaupunki_app/widgets/attraction_info_overlay.dart";
import "package:valon_kaupunki_app/widgets/coupon_overlay.dart";
import "package:valon_kaupunki_app/widgets/map_filter_button_list.dart";
import "package:valon_kaupunki_app/widgets/large_list_card.dart";
import "package:valon_kaupunki_app/widgets/listing.dart";
import "package:valon_kaupunki_app/widgets/small_list_card.dart";

enum MarkerBaseType {
  attraction,
  partner;
}

class _MarkerData {
  final int id;
  final LatLng point;
  final MarkerBaseType type;
  final String category;

  const _MarkerData(
    this.id,
    this.point,
    this.type,
    this.category,
  );
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
  final List<StrapiAttraction> _strapiAttractions = List.empty(growable: true);
  final Map<int, StrapiFavouriteUser> _strapiFavouriteAttractions = {};
  List<StrapiAttraction> _shownAttractions = List.empty(growable: true);

  final List<StrapiPartner> _strapiPartners = List.empty(growable: true);
  final Map<int, StrapiFavouritePartner> _strapiFavouritePartners = {};
  List<StrapiPartner> _shownPartners = List.empty(growable: true);
  late AppLocalizations _localizations = AppLocalizations.of(context)!;

  late final Stream<LocationMarkerPosition?> _posStream;
  final Set<int> _usedBenefits = {};
  final List<StrapiBenefit> _benefits = List.empty(growable: true);

  LatLng? _currentLocation;
  Widget? _currentOverlay;

  _Section _currentSection = _Section.home;
  String get _title => _currentSection.localizedTitle(_localizations);

  bool _showMenu = false;
  bool _loading = true;
  bool _trackLocation = false;
  late Locale _locale = Localizations.localeOf(context);

  double _compassAngle = 0.0;
  bool _dataFetchFailed = false;

  LatLng? _lastTapTarget;
  double _zoomLevel = 12.0;

  bool _showPermanentAttractions = Preferences.showPermanentAttractions;
  bool _showEventLightArtPieces = Preferences.showEventLightArtPieces;

  bool _showRestaurantsAndCafes = Preferences.showRestaurantsAndCafes;
  bool _showSupplementaryShows = Preferences.showSupplementaryShows;
  bool _showShopping = Preferences.showShopping;
  bool _showJyvasParkki = Preferences.showJyvasParkki;

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
    _fetchData(locale: _locale);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizations = AppLocalizations.of(context)!;
    _locale = Localizations.localeOf(context);
  }

  _initLocationTracking() async {
    var locationPermissionGranted =
        await Permission.location.request().isGranted;

    if (locationPermissionGranted) {
      const dataStreamFactory = LocationMarkerDataStreamFactory();
      _posStream =
          dataStreamFactory.fromGeolocatorPositionStream().asBroadcastStream();
      _posStream.listen((event) => _currentLocation = event?.latLng);
    }

    setState(() => _trackLocation = locationPermissionGranted);
  }

  // Builder functions for the list views
  Widget? _attractionsBuilder(BuildContext context, int index) {
    if (index >= _shownAttractions.length) {
      return null;
    }

    final strapiAttraction = _shownAttractions[index];
    final attraction = strapiAttraction.attraction;
    final favouriteAttraction =
        _strapiFavouriteAttractions.containsKey(strapiAttraction.id)
            ? _strapiFavouriteAttractions[strapiAttraction.id]
            : null;

    return SmallListCard(
      index: index,
      leftIcon: SvgPicture.asset(
        attraction.category == AttractionCategories.permanentAttraction
            ? Assets.attractionsIcon
            : Assets.eventLightArtPieceIcon,
        colorFilter: ColorFilter.mode(
          attraction.category == AttractionCategories.permanentAttraction
              ? CustomThemeValues.appOrange
              : CustomThemeValues.lightArtPieceColor,
          BlendMode.srcIn,
        ),
      ),
      title: getAttractionCategoryLabel(attraction.category, _localizations),
      text: attraction.title,
      secondaryLabel: Text(
        _currentLocation == null
            ? "- m"
            : LocationUtils.formatDistance(
                _currentLocation!,
                attraction.location.toMarkerType(),
              ),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      proceedIcon: const Icon(
        Icons.arrow_forward,
        opticalSize: 24.0,
        color: Colors.white,
      ),
      onTap: () =>
          _showAttractionInfoOverlay(strapiAttraction, favouriteAttraction),
    );
  }

  Widget? _partnersBuilder(BuildContext context, int index) {
    if (index >= _shownPartners.length) {
      return null;
    }

    final strapiPartner = _shownPartners[index];
    final partner = strapiPartner.partner;
    final favouritePartner =
        _strapiFavouritePartners.containsKey(strapiPartner.id)
            ? _strapiFavouritePartners[strapiPartner.id]
            : null;

    return SmallListCard(
      index: index,
      leftIcon: getPartnerCategoryIcon(partner.category),
      title: getPartnerCategoryLabel(partner.category, _localizations),
      text: partner.name,
      secondaryLabel: Text(
        _currentLocation == null
            ? "- m"
            : LocationUtils.formatDistance(
                _currentLocation!,
                partner.location.toMarkerType(),
              ),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      proceedIcon: const Icon(
        Icons.arrow_forward,
        opticalSize: 24.0,
        color: Colors.white,
      ),
      onTap: () => _showPartnerInfoOverlay(strapiPartner, favouritePartner),
    );
  }

  void handleClaimBenefit(Benefit benefit, int index) async {
    final confirmedBenefitUse = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Käytä etu?"),
            content: const Text("Etu on käytettävä kassalla."),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Peruuta"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Käytä"),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmedBenefitUse) {
      try {
        await _client.claimBenefit(_benefits[index].id);
      } on Exception catch (error) {
        log("Failed to claim benefit: $error");

        Fluttertoast.showToast(
          msg: _localizations.cannotUseBenefit(benefit.title),
          toastLength: Toast.LENGTH_SHORT,
        );
      }

      _usedBenefits.add(_benefits[index].id);
    }

    setState(() => _currentOverlay = null);
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
          : () => setState(
                () => _currentOverlay = CouponOverlay(
                  benefit: benefit,
                  currentLocation: _currentLocation,
                  onClose: () => setState(() => _currentOverlay = null),
                  onClaim: () => handleClaimBenefit(benefit, index),
                ),
              ),
      alreadyUsed: alreadyUsed,
    );
  }

  Widget get _filterDropdown {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: SizedBox(
          height: 50,
          child: DropdownButtonFormField2<Sorting>(
            alignment: Alignment.centerLeft,
            isExpanded: true,
            onChanged: (item) async {
              await Preferences.setSorting(item!);
              _updateAttractionsAndPartners(item);
            },
            value: Preferences.sorting,
            decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(style: BorderStyle.none),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(style: BorderStyle.none),
                ),
                prefixIcon: Icon(
                  Icons.filter_list,
                  color: Colors.black,
                )),
            items: Sorting.values.map((item) {
              final text = item.getDisplayValue(_localizations);
              return DropdownMenuItem(
                value: item,
                alignment: Alignment.centerLeft,
                child: Text(text),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget get _childForCurrentSection {
    final filter = switch (_currentSection) {
      _Section.attractions => Column(
          children: [
            _filterDropdown,
            SizedBox(height: 40, child: _attractionsFilter),
          ],
        ),
      _Section.partners => Column(
          children: [
            _filterDropdown,
            SizedBox(height: 40, child: _partnersFilter),
          ],
        ),
      _ => null
    };

    final builder = switch (_currentSection) {
      _Section.attractions => _attractionsBuilder,
      _Section.benefits => _benefitsBuilder,
      _Section.partners => _partnersBuilder,
      _ => throw Exception(
          "Invalid section value to get child: $_currentSection",
        )
    };

    final itemCount = switch (_currentSection) {
      _Section.attractions => _shownAttractions.length,
      _Section.benefits => _benefits.length,
      _Section.partners => _shownPartners.length,
      _ => throw Exception(
          "Invalid section value to get child: $_currentSection",
        )
    };

    final errorMessage =
        _dataFetchFailed ? _localizations.loadingDataFailed : null;

    return Listing(
      filter: filter,
      errorMessage: errorMessage,
      builder: builder,
      itemCount: itemCount,
    );
  }

  static const double _animTargetZoom = 14.0;
  late final AnimatedMapController _animMapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeInOut,
    mapController: _mapController,
  );

  BottomNavigationBarItem _navBarItem(
    String label,
    String asset,
    Color color,
    void Function() clicked,
  ) {
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

  void _sortAttractions(Sorting sorting) {
    _shownAttractions = _shownAttractions
        .where(
          (attraction) =>
              (_showPermanentAttractions &&
                  attraction.attraction.category ==
                      AttractionCategories.permanentAttraction) ||
              (_showEventLightArtPieces &&
                  attraction.attraction.category ==
                      AttractionCategories.eventLightArtPiece),
        )
        .toList();

    _shownAttractions.sort((attraction, another) {
      if (sorting == Sorting.alphabetical) {
        return attraction.attraction.title.compareTo(another.attraction.title);
      } else if (_currentLocation != null) {
        final distanceToFirst = LocationUtils.distanceBetween(
          attraction.attraction.location.toMarkerType(),
          _currentLocation!,
        );
        final distanceToSecond = LocationUtils.distanceBetween(
          another.attraction.location.toMarkerType(),
          _currentLocation!,
        );

        if (distanceToFirst == distanceToSecond) {
          return 0;
        }

        return distanceToFirst < distanceToSecond ? -1 : 1;
      } else {
        return 0;
      }
    });
  }

  void _sortPartners(Sorting sorting) {
    _shownPartners = _shownPartners
        .where((partner) => switch (partner.partner.category) {
              PartnerCategories.restaurantOrCafe => _showRestaurantsAndCafes,
              PartnerCategories.shopping => _showShopping,
              PartnerCategories.supplementaryShow => _showSupplementaryShows,
              PartnerCategories.jyvasParkki => _showJyvasParkki,
              _ => false,
            })
        .toList();

    _shownPartners.sort((partner, another) {
      if (sorting == Sorting.alphabetical) {
        return partner.partner.name.compareTo(another.partner.name);
      } else if (_currentLocation != null) {
        final distanceToFirst = LocationUtils.distanceBetween(
          partner.partner.location.toMarkerType(),
          _currentLocation!,
        );
        final distanceToSecond = LocationUtils.distanceBetween(
          another.partner.location.toMarkerType(),
          _currentLocation!,
        );

        if (distanceToFirst == distanceToSecond) {
          return 0;
        }

        return distanceToFirst < distanceToSecond ? -1 : 1;
      } else {
        return 0;
      }
    });
  }

  void _updateAttractionsAndPartners(Sorting sorting) {
    _shownAttractions.clear();
    _shownPartners.clear();

    _shownAttractions.addAll(_strapiAttractions);
    _shownPartners.addAll(_strapiPartners);

    setState(() {
      _sortAttractions(sorting);
      _sortPartners(sorting);
    });
  }

  void _addMarkers(List<_MarkerData> markers) {
    if (mounted) {
      setState(() {
        _allMarkers.addAll(markers);
        _markers.addAll(_filterMarkers(markers));
      });
    }
  }

  Future<void> _fetchData({Locale? locale}) async {
    setState(() {
      _dataFetchFailed = false;
      _loading = true;
      _markers.clear();
      _allMarkers.clear();
    });

    try {
      final markers = List<_MarkerData>.empty(growable: true);

      final strapiAttractionsResponse = await _client.listAttractions(
        locale: locale,
      );
      _strapiAttractions.clear();
      _strapiAttractions.addAll(strapiAttractionsResponse.data);

      final strapiFavouriteAttractions =
          await _client.listFavouriteAttractionsForUser();
      _strapiFavouriteAttractions.clear();
      _strapiFavouriteAttractions.addEntries(strapiFavouriteAttractions.map(
        (strapiFavouriteAttraction) => MapEntry(
          strapiFavouriteAttraction.favouriteUser.attractionId!,
          strapiFavouriteAttraction,
        ),
      ));

      markers.addAll(
        _strapiAttractions.map((strapiAttraction) {
          final category = strapiAttraction.attraction.category;

          return _MarkerData(
            strapiAttraction.id,
            strapiAttraction.attraction.location.toMarkerType(),
            MarkerBaseType.attraction,
            category,
          );
        }).toList(),
      );

      final strapiPartnersResponse = await _client.listPartners(
        locale: locale,
      );
      _strapiPartners.clear();
      _strapiPartners.addAll(strapiPartnersResponse.data);

      final strapiFavouritePartners =
          await _client.listFavouritePartnersForUser();
      _strapiFavouritePartners.clear();
      _strapiFavouritePartners.addEntries(strapiFavouritePartners.map(
        (strapiFavouritePartner) => MapEntry(
          strapiFavouritePartner.favouritePartner.partnerId!,
          strapiFavouritePartner,
        ),
      ));

      markers.addAll(
        _strapiPartners.map((strapiPartner) {
          final category = strapiPartner.partner.category;

          return _MarkerData(
            strapiPartner.id,
            strapiPartner.partner.location.toMarkerType(),
            MarkerBaseType.partner,
            category,
          );
        }).toList(),
      );

      final usedBenefitsResponse = await _client.listUsedBenefitsForDevice();
      _usedBenefits.clear();
      _usedBenefits.addAll(usedBenefitsResponse.map((e) => e.id));

      final benefitsResponse = await _client.listBenefits();
      _benefits.clear();
      _benefits.addAll(benefitsResponse.data);

      _addMarkers(markers);
    } on Exception catch (error) {
      log("Failed to fetch data: $error");
      await Fluttertoast.showToast(
        msg: _localizations.loadingDataFailed,
        toastLength: Toast.LENGTH_SHORT,
      );

      if (mounted) {
        setState(() => _dataFetchFailed = true);
      }
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  List<_MarkerData> _filterMarkers(List<_MarkerData> markers) {
    final result = List<_MarkerData>.empty(growable: true);

    if (_showPermanentAttractions) {
      result.addAll(
        markers.where((marker) =>
            marker.category == AttractionCategories.permanentAttraction),
      );
    }

    if (_showEventLightArtPieces) {
      result.addAll(
        markers.where((marker) =>
            marker.category == AttractionCategories.eventLightArtPiece),
      );
    }

    if (_showRestaurantsAndCafes) {
      result.addAll(
        markers.where(
            (marker) => marker.category == PartnerCategories.restaurantOrCafe),
      );
    }

    if (_showShopping) {
      result.addAll(
        markers
            .where((marker) => marker.category == PartnerCategories.shopping),
      );
    }

    if (_showSupplementaryShows) {
      result.addAll(
        markers.where(
            (marker) => marker.category == PartnerCategories.supplementaryShow),
      );
    }

    if (_showJyvasParkki) {
      result.addAll(
        markers.where(
            (marker) => marker.category == PartnerCategories.jyvasParkki),
      );
    }

    _updateAttractionsAndPartners(Preferences.sorting);
    return result;
  }

  void _setSection(_Section section) {
    setState(() => _currentSection = section);
  }

  Color _getColorForSection(_Section section) {
    return section == _currentSection
        ? CustomThemeValues.appOrange
        : Colors.white;
  }

  Widget get _filterList {
    return MapFilterButtonList(
      onMarkerFilterUpdate: () =>
          setState(() => _markers = _filterMarkers(_allMarkers)),
      onFilterPermanentAttractions: () async {
        _showPermanentAttractions = !_showPermanentAttractions;
        await Preferences.setShowPermanentAttractions(
            _showPermanentAttractions);
      },
      onFilterEventLightArtPieces: () async {
        _showEventLightArtPieces = !_showEventLightArtPieces;
        await Preferences.setShowEventAttractions(_showEventLightArtPieces);
      },
      onFilterRestaurantsAndCafes: () async {
        _showRestaurantsAndCafes = !_showRestaurantsAndCafes;
        await Preferences.setShowRestaurantsAndCafes(_showRestaurantsAndCafes);
      },
      onFilterShopping: () async {
        _showShopping = !_showShopping;
        await Preferences.setShowShopping(_showShopping);
      },
      onFilterSupplementaryShows: () async {
        _showSupplementaryShows = !_showSupplementaryShows;
        await Preferences.setShowSupplementaryShows(_showSupplementaryShows);
      },
      onFilterJyvasParkki: () async {
        _showJyvasParkki = !_showJyvasParkki;
        await Preferences.setShowJyvasParkki(_showJyvasParkki);
      },
      permanentAttractionsState: _showPermanentAttractions,
      eventLightArtPiecesState: _showEventLightArtPieces,
      restaurantsAndCafesState: _showRestaurantsAndCafes,
      shoppingState: _showShopping,
      supplementaryShowsState: _showSupplementaryShows,
      jyvasParkkiState: _showJyvasParkki,
    );
  }

  Widget get _attractionsFilter {
    return AttractionsFilter(
      permanentAttractionsState: _showPermanentAttractions,
      eventLightArtPiecesState: _showEventLightArtPieces,
      onMarkerFilterUpdate: () =>
          setState(() => _markers = _filterMarkers(_allMarkers)),
      onFilterPermanentAttractions: () async {
        _showPermanentAttractions = !_showPermanentAttractions;
        await Preferences.setShowPermanentAttractions(
            _showPermanentAttractions);
      },
      onFilterEventLightArtPieces: () async {
        _showEventLightArtPieces = !_showEventLightArtPieces;
        await Preferences.setShowEventAttractions(_showEventLightArtPieces);
      },
    );
  }

  Widget get _partnersFilter {
    return PartnersFilter(
      restaurantsOrCafesState: _showRestaurantsAndCafes,
      shoppingState: _showShopping,
      supplementaryShowsState: _showSupplementaryShows,
      jyvasParkkiState: _showJyvasParkki,
      onMarkerFilterUpdate: () =>
          setState(() => _markers = _filterMarkers(_allMarkers)),
      onFilterRestaurantsOrCafes: () async {
        _showRestaurantsAndCafes = !_showRestaurantsAndCafes;
        await Preferences.setShowRestaurantsAndCafes(_showRestaurantsAndCafes);
      },
      onFilterShopping: () async {
        _showShopping = !_showShopping;
        await Preferences.setShowShopping(_showShopping);
      },
      onFilterSupplementaryShows: () async {
        _showSupplementaryShows = !_showSupplementaryShows;
        await Preferences.setShowSupplementaryShows(_showSupplementaryShows);
      },
      onFilterJyvasParkki: () async {
        _showJyvasParkki = !_showJyvasParkki;
        await Preferences.setShowJyvasParkki(_showJyvasParkki);
      },
    );
  }

  void _showAttractionInfoOverlay(
    StrapiAttraction strapiAttraction,
    StrapiFavouriteUser? favouriteAttraction,
  ) {
    final targetInfo = AttractionInfoOverlay(
      strapiAttraction: strapiAttraction,
      currentLocation: _currentLocation,
      showFullScreenButton: true,
      initialFavouriteAttraction: favouriteAttraction,
      onToggleFavourite: (strapiFavouriteAttraction) {
        setState(() {
          final attractionId =
              strapiFavouriteAttraction.favouriteUser.attractionId!;

          if (_strapiFavouriteAttractions.containsKey(attractionId)) {
            _strapiFavouriteAttractions.remove(attractionId);
          } else {
            _strapiFavouriteAttractions.addAll({
              attractionId: strapiFavouriteAttraction,
            });
          }
        });
      },
      onClose: () => setState(() => _currentOverlay = null),
    );

    setState(() => _currentOverlay = targetInfo);
  }

  void _showPartnerInfoOverlay(
    StrapiPartner strapiPartner,
    StrapiFavouritePartner? favouritePartner,
  ) {
    final targetInfo = PartnerInfoOverlay(
      strapiPartner: strapiPartner,
      currentLocation: _currentLocation,
      showFullScreenButton: false,
      initialFavouritePartner: favouritePartner,
      onToggleFavourite: (strapiFavouritePartner) {
        setState(() {
          final partnerId = strapiFavouritePartner.favouritePartner.partnerId!;

          if (_strapiFavouritePartners.containsKey(partnerId)) {
            _strapiFavouritePartners.remove(partnerId);
          } else {
            _strapiFavouritePartners.addAll(
              {partnerId: strapiFavouritePartner},
            );
          }
        });
      },
      onClose: () => setState(() => _currentOverlay = null),
    );

    setState(() => _currentOverlay = targetInfo);
  }

  void _handleMapMarkerTap(_MarkerData markerData) async {
    if (_mapController.center != markerData.point) {
      await _animMapController.animateTo(
        dest: markerData.point,
        zoom: _animTargetZoom,
      );

      _lastTapTarget = markerData.point;
    }

    final foundAttraction = _strapiAttractions.firstWhereOrNull(
      (attraction) =>
          markerData.type == MarkerBaseType.attraction &&
          markerData.id == attraction.id,
    );

    if (foundAttraction != null) {
      final favouriteAttraction =
          _strapiFavouriteAttractions.containsKey(foundAttraction.id)
              ? _strapiFavouriteAttractions[foundAttraction.id]
              : null;

      _showAttractionInfoOverlay(foundAttraction, favouriteAttraction);
      return;
    }

    final foundPartner = _strapiPartners.firstWhereOrNull(
      (partner) =>
          markerData.type == MarkerBaseType.partner &&
          markerData.id == partner.id,
    );

    if (foundPartner != null) {
      final favouritePartner =
          _strapiFavouritePartners.containsKey(foundPartner.id)
              ? _strapiFavouritePartners[foundPartner.id]
              : null;
      _showPartnerInfoOverlay(foundPartner, favouritePartner);
    }
  }

  void _handleMapEvent(MapEvent event) {
    final mapRotationMultiplier =
        _mapController.rotation == 360.0 ? 0.0 : _mapController.rotation;

    setState(() {
      _compassAngle = (pi / 180) * mapRotationMultiplier;
      _zoomLevel = _mapController.zoom;
    });
  }

  SvgPicture _resolveMarkerIcon(_MarkerData markerData) {
    final asset = switch (markerData.type) {
      MarkerBaseType.attraction =>
        _strapiFavouriteAttractions.containsKey(markerData.id)
            ? getAttractionFavouriteMarkerAsset(markerData.category)
            : getAttractionMarkerAsset(markerData.category),
      MarkerBaseType.partner =>
        _strapiFavouritePartners.containsKey(markerData.id)
            ? getPartnerFavouriteMarkerAsset(markerData.category)
            : getPartnerMarkerAsset(markerData.category),
    };

    return SvgPicture.asset(asset);
  }

  List<Widget> _buildMapContent() {
    final instance = FMTC.instance(
      const String.fromEnvironment("FMTC_STORE_NAME"),
    );
    final provider = instance.getTileProvider();

    return [
      FlutterMap(
        mapController: _animMapController.mapController,
        options: MapOptions(
          center: _lastTapTarget ?? const LatLng(62.24147, 25.72088),
          zoom: _zoomLevel,
          maxZoom: 18,
          minZoom: 9,
          onMapEvent: _handleMapEvent,
        ),
        children: [
          TileLayer(
            tileProvider: provider,
            backgroundColor: Colors.black,
            urlTemplate: const String.fromEnvironment("MAP_TILE_URL_TEMPLATE"),
            userAgentPackageName: "fi.metatavu.valon-kaupunki-app",
          ),
          if (_trackLocation)
            CurrentLocationLayer(
              headingStream: const Stream.empty(),
              positionStream: _posStream,
            ),
          MarkerLayer(
            rotate: true,
            markers: _markers
                .map(
                  (data) => Marker(
                    point: data.point,
                    height: 80,
                    width: 80,
                    builder: (context) => GestureDetector(
                      child: _resolveMarkerIcon(data),
                      onTap: () => _handleMapMarkerTap(data),
                    ),
                  ),
                )
                .toList(growable: false),
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
              child: _filterList,
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
                    if (_trackLocation && _currentLocation != null)
                      IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color:
                              _mapController.bounds!.contains(_currentLocation!)
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
                      ),
                  ],
                ),
              ),
            ),
      if (_showMenu) _renderMenu(),
    ];
  }

  Widget _renderMenu() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: GestureDetector(
          onTap: () => setState(() => _showMenu = false),
          child: Container(
            constraints: const BoxConstraints.expand(),
            child: Container(
              color: Colors.transparent.withAlpha(0x7F),
              padding: const EdgeInsets.only(top: 90, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: SvgPicture.asset(Assets.homeIcon),
                    title: Text(
                      _localizations.homeButtonText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => setState(() {
                      _currentSection = _Section.home;
                      _showMenu = false;
                    }),
                  ),
                  ListTile(
                    leading: SvgPicture.asset(Assets.attractionsIcon),
                    title: Text(
                      _localizations.attractionsButtonText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => setState(() {
                      _currentSection = _Section.attractions;
                      _showMenu = false;
                    }),
                  ),
                  ListTile(
                    leading: SvgPicture.asset(Assets.benefitsIcon),
                    title: Text(
                      _localizations.benefitsButtonText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => setState(() {
                      _currentSection = _Section.benefits;
                      _showMenu = false;
                    }),
                  ),
                  ListTile(
                    leading: SvgPicture.asset(Assets.partnersIcon),
                    title: Text(
                      _localizations.partnersButtonText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => setState(() {
                      _currentSection = _Section.partners;
                      _showMenu = false;
                    }),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      opticalSize: 24,
                      color: Colors.white,
                    ),
                    title: Text(
                      _localizations.showWelcomePage,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton(
                    emptySelectionAllowed: false,
                    multiSelectionEnabled: false,
                    selectedIcon: const Icon(Icons.language_outlined),
                    segments: const [
                      ButtonSegment(value: "fi", label: Text("Suomeksi")),
                      ButtonSegment(value: "en", label: Text("In English"))
                    ],
                    selected: {Localizations.localeOf(context).languageCode},
                    onSelectionChanged: (values) {
                      ValonKaupunkiApp.of(context)!
                          .setLocale(Locale(values.first));
                      _locale = Locale(values.first);
                      _fetchData(locale: Locale(values.first));
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      side: MaterialStateBorderSide.resolveWith(
                        (states) => BorderSide(
                          width: 1.0,
                          color: CustomThemeValues.appOrange,
                        ),
                      ),
                      backgroundColor: MaterialStateColor.resolveWith(
                        (Set<MaterialState> states) =>
                            states.contains(MaterialState.selected)
                                ? CustomThemeValues.appOrange
                                : Colors.transparent,
                      ),
                      foregroundColor: MaterialStateColor.resolveWith(
                        (Set<MaterialState> states) =>
                            states.contains(MaterialState.selected)
                                ? Colors.black
                                : Colors.white,
                      ),
                      shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderBottomNavigation() {
    return ClipRect(
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
            _navBarItem(
              _localizations.homeButtonText,
              Assets.homeIcon,
              _getColorForSection(_Section.home),
              () => _setSection(_Section.home),
            ),
            _navBarItem(
              _localizations.attractionsButtonText,
              Assets.attractionsIcon,
              _getColorForSection(_Section.attractions),
              () => _setSection(_Section.attractions),
            ),
            _navBarItem(
              _localizations.benefitsButtonText,
              Assets.benefitsIcon,
              _getColorForSection(_Section.benefits),
              () => _setSection(_Section.benefits),
            ),
            _navBarItem(
              _localizations.partnersButtonText,
              Assets.partnersIcon,
              _getColorForSection(_Section.partners),
              () => _setSection(_Section.partners),
            ),
          ],
        ),
      ),
    );
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(_showMenu ? Icons.close : Icons.menu),
            iconSize: 24.0,
            color: Colors.white,
            onPressed: () => setState(() => _showMenu = !_showMenu),
          ),
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
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(children: _buildMapContent()),
      bottomNavigationBar: _renderBottomNavigation(),
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentOverlay != null) {
      setState(() => _currentOverlay = null);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: RefreshIndicator(
        backgroundColor: const Color.fromARGB(0x7F, 0x1B, 0x26, 0x37),
        color: Colors.white,
        onRefresh: () => _fetchData(locale: _locale),
        child: Stack(
          children: [
            _buildMainContent(),
            if (_currentOverlay != null) _currentOverlay!,
            if (_loading)
              Container(
                color: Colors.transparent.withAlpha(0x7F),
                child: Center(
                  child: CircularProgressIndicator(
                    color: CustomThemeValues.appOrange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
