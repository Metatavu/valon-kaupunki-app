import "dart:ui";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:latlong2/latlong.dart";
import "package:url_launcher/url_launcher.dart";
import "package:valon_kaupunki_app/api/api_categories.dart";
import "package:valon_kaupunki_app/api/model/benefit.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:valon_kaupunki_app/location_utils.dart";
import "package:valon_kaupunki_app/widgets/height_constrained_image.dart";
import "package:valon_kaupunki_app/widgets/property_info.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class CouponOverlay extends StatelessWidget {
  final Benefit benefit;
  final LatLng? currentLocation;
  final void Function() onClose;
  final void Function() onClaim;

  const CouponOverlay({
    super.key,
    required this.benefit,
    required this.currentLocation,
    required this.onClose,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final partner = benefit.partner!.data!.partner;

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
                  onPressed: onClose,
                ),
                title: Center(
                  child: Text(
                    benefit.title,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.open_in_full,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Container(
                  color: Colors.black38,
                  child: Column(
                    children: [
                      if (benefit.image != null)
                        HeightConstrainedImage.network(
                          height: 200,
                          radius: 00,
                          url: benefit.image!.image.url,
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.benefitCoupon,
                                textAlign: TextAlign.left,
                                style: theme.textTheme.bodyMedium!
                                    .copyWith(fontSize: 10.0),
                              ),
                              Text(
                                benefit.title,
                                textAlign: TextAlign.left,
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                benefit.benefitText,
                                textAlign: TextAlign.left,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                    color: CustomThemeValues.appOrange),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  benefit.description,
                                  textAlign: TextAlign.left,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (partner.address != null)
                        PropertyInfo(
                          leading: SvgPicture.asset(
                            Assets.homeIcon,
                            width: 24.0,
                            height: 24.0,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
                          ),
                          title: localizations.address,
                          text: partner.address!,
                          trailing: null,
                        ),
                      PropertyInfo(
                        leading: SvgPicture.asset(
                          Assets.locationIcon,
                          width: 24.0,
                          height: 24.0,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                        title: localizations.distanceToTarget,
                        text: currentLocation == null
                            ? "- m"
                            : LocationUtils.formatDistance(
                                benefit.partner!.data!.partner.location
                                    .toMarkerType(),
                                currentLocation!,
                              ),
                        trailing: null,
                      ),
                      PropertyInfo(
                        leading: getPartnerCategoryIcon(partner.category),
                        title: getPartnerCategoryLabel(
                            partner.category, localizations),
                        text: partner.name,
                        trailing: null,
                      ),
                      if (partner.link != null)
                        GestureDetector(
                          onTap: () => launchUrl(
                            Uri.parse(partner.link!),
                            mode: LaunchMode.externalApplication,
                          ),
                          child: PropertyInfo(
                            leading: const Icon(
                              Icons.open_in_new,
                              color: Colors.white,
                            ),
                            title: localizations.readMoreAbout,
                            text: localizations.linkOpensInNewWindow,
                            trailing: null,
                          ),
                        ),
                      IntrinsicWidth(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: theme.outlinedButtonTheme.style,
                                onPressed: onClose,
                                child: Text(
                                  localizations.close,
                                  style: theme.textTheme.bodySmall!,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: OutlinedButton(
                                  style: theme.outlinedButtonTheme.style,
                                  onPressed: onClaim,
                                  child: Text(
                                    localizations.claimBenefit,
                                    style: theme.textTheme.bodySmall!,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
