import "package:flutter/material.dart";
import "package:latlong2/latlong.dart";
import "package:valon_kaupunki_app/api/api_categories.dart";
import "package:valon_kaupunki_app/api/model/partner.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:valon_kaupunki_app/location_utils.dart";
import "package:valon_kaupunki_app/widgets/height_constrained_image.dart";

class LargeListCard extends StatelessWidget {
  final String? _imageUrl;
  final String _couponText;
  final String _couponBenefit;
  final DateTime? _couponValidTo;
  final Partner _partner;
  final LatLng? _currentLocation;
  final void Function()? _readMore;
  final bool alreadyUsed;

  const LargeListCard({
    required String? imageUrl,
    required String couponText,
    required String couponBenefit,
    required DateTime? validTo,
    required Partner partner,
    required void Function()? readMore,
    required this.alreadyUsed,
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
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: CustomThemeValues.appOrange, width: 0.5),
          color: Colors.black38,
        ),
        child: SizedBox(
          child: Column(
            children: [
              if (_imageUrl != null)
                Container(
                  foregroundDecoration: BoxDecoration(
                    color: alreadyUsed ? Colors.grey : Colors.transparent,
                    backgroundBlendMode:
                        alreadyUsed ? BlendMode.saturation : null,
                  ),
                  child: HeightConstrainedImage.network(
                    height: 200,
                    radius: 5,
                    url: _imageUrl!,
                  ),
                ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.benefitCoupon,
                        style:
                            theme.textTheme.bodySmall!.copyWith(fontSize: 12),
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
                      if (_couponValidTo != null)
                        Text(
                          localizations.validUntil(_couponValidTo!),
                          style: theme.textTheme.bodySmall!.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ListTile(
                        leading: getPartnerCategoryIcon(_partner.category),
                        title: Text(
                          getPartnerCategoryLabel(
                            _partner.category,
                            localizations,
                          ),
                          style: theme.textTheme.bodyMedium!
                              .copyWith(fontSize: 14),
                        ),
                        subtitle: Text(
                          _partner.name,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 27, right: 12),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                            opticalSize: 24,
                          ),
                        ),
                        Text(
                          _currentLocation == null
                              ? "- m"
                              : LocationUtils.formatDistance(
                                  _partner.location.toMarkerType(),
                                  _currentLocation!,
                                ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: _readMore,
                      style: _readMore == null
                          ? theme.outlinedButtonTheme.style!.copyWith(
                              backgroundColor:
                                  const MaterialStatePropertyAll(Colors.grey),
                              side: const MaterialStatePropertyAll(
                                BorderSide(style: BorderStyle.none),
                              ),
                            )
                          : theme.outlinedButtonTheme.style,
                      child: Text(
                        _readMore == null
                            ? localizations.claimed
                            : localizations.readMore,
                        style: _readMore == null
                            ? const TextStyle(color: Colors.white)
                            : theme.outlinedButtonTheme.style!.textStyle!
                                .resolve({}),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
