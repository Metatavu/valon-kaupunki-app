import "package:flutter/material.dart";
import "package:latlong2/latlong.dart";
import "package:valon_kaupunki_app/api/api_categories.dart";
import "package:valon_kaupunki_app/api/model/partner.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:valon_kaupunki_app/location_utils.dart";
import "package:valon_kaupunki_app/widgets/height_constrained_image.dart";
import "package:valon_kaupunki_app/widgets/property_info.dart";

class LargeListCard extends StatelessWidget {
  final String _imageUrl;
  final String _couponText;
  final String _couponBenefit;
  final DateTime _couponValidTo;
  final Partner _partner;
  final LatLng? _currentLocation;
  final void Function() _readMore;

  const LargeListCard({
    required String imageUrl,
    required String couponText,
    required String couponBenefit,
    required DateTime validTo,
    required Partner partner,
    required void Function() readMore,
    LatLng? currentLocation,
    Key? key,
  })  : _imageUrl = imageUrl,
        _couponText = couponText,
        _couponBenefit = couponBenefit,
        _couponValidTo = validTo,
        _partner = partner,
        _currentLocation = currentLocation,
        _readMore = readMore,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: CustomThemeValues.appOrange, width: 0.5),
          color: Colors.black38,
        ),
        child: SizedBox(
          child: Column(
            children: [
              HeightConstrainedImage.network(
                height: 200,
                radius: 5.0,
                url: _imageUrl,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.benefitCoupon,
                        style:
                            theme.textTheme.bodySmall!.copyWith(fontSize: 12.0),
                      ),
                      Text(
                        _couponText,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        _couponBenefit,
                        style: theme.textTheme.bodyMedium!
                            .copyWith(color: CustomThemeValues.appOrange),
                      ),
                      Text(
                        localizations.validUntil(_couponValidTo),
                        style:
                            theme.textTheme.bodySmall!.copyWith(fontSize: 12.0),
                      ),
                      PropertyInfo(
                        leading: getPartnerCategoryIcon(_partner.category),
                        title: getPartnerCategoryLabel(
                            _partner.category, localizations),
                        text: _partner.name,
                        trailing: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                opticalSize: 24.0,
                              ),
                              Text(
                                _currentLocation == null
                                    ? "- m"
                                    : LocationUtils.formatDistance(
                                        _partner.location.toMarkerType(),
                                        _currentLocation!),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: OutlinedButton(
                    onPressed: _readMore,
                    style: theme.outlinedButtonTheme.style,
                    child: Text(
                      localizations.readMore,
                      style: theme.outlinedButtonTheme.style!.textStyle!
                          .resolve({}),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
