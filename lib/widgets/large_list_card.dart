import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:valon_kaupunki_app/api/api_categories.dart";
import "package:valon_kaupunki_app/api/model/partner.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";

class LargeListCard extends StatelessWidget {
  final String _imageUrl;
  final String _couponText;
  final String _couponBenefit;
  final DateTime _couponValidTo;
  final Partner _partner;

  const LargeListCard(
      {required String imageUrl,
      required String couponText,
      required String couponBenefit,
      required DateTime validTo,
      required Partner partner,
      Key? key})
      : _imageUrl = imageUrl,
        _couponText = couponText,
        _couponBenefit = couponBenefit,
        _couponValidTo = validTo,
        _partner = partner,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

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
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Image.network(
                    _imageUrl,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.benefitCoupon,
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
                        loc.validUntil(_couponValidTo),
                        style:
                            theme.textTheme.bodySmall!.copyWith(fontSize: 12.0),
                      ),
                      SizedBox(
                        height: 60.0,
                        child: Row(
                          children: [
                            SvgPicture.asset(Assets.restaurantPartnerAssetIcon),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, top: 8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getPartnerCategoryLabel(
                                        _partner.category, loc),
                                    style: theme.textTheme.bodyMedium!
                                        .copyWith(fontSize: 14.0),
                                  ),
                                  Text(
                                    _partner.name,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white,
                                    opticalSize: 24.0,
                                  ),
                                  Text(
                                    "200m",
                                    style: theme.textTheme.bodySmall,
                                  )
                                ],
                              ),
                            )
                          ],
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
                    onPressed: () {},
                    style: theme.outlinedButtonTheme.style,
                    child: Text(
                      loc.readMore,
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
