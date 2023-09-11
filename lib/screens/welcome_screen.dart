import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:url_launcher/url_launcher.dart";
import "package:valon_kaupunki_app/assets.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

import "map_screen.dart";

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  Image backgroundImage = Image.asset(
    Assets.valonKaupunkiBackground,
    fit: BoxFit.cover,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(backgroundImage.image, context);
  }

  void _launchWebsite(String url) async => launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

  Widget _renderContent({
    required BuildContext context,
    required AppLocalizations localizations,
    required ThemeData theme,
  }) {
    return Stack(
      children: [
        Positioned.fill(child: backgroundImage),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 120),
              child: Align(
                alignment: Alignment.topCenter,
                child: SvgPicture.asset(
                  Assets.valonKaupunkiLogo,
                  width: 280,
                ),
              ),
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      localizations.welcomeToValonKaupunki,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: theme.textTheme.bodySmall,
                          children: [
                            TextSpan(text: localizations.introductionTextPart1),
                            TextSpan(
                              text: localizations.introductionTextLink,
                              style: CustomThemeValues.linkTheme(theme),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _launchWebsite(
                                      "https://valonkaupunki.jyvaskyla.fi/",
                                    ),
                            ),
                            const TextSpan(text: ".\n\n"),
                            TextSpan(
                              text: localizations.introductionTextPart2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        bottom: 24.0,
                      ),
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(),
                          ),
                        ),
                        style: theme.outlinedButtonTheme.style,
                        child: Text(
                          localizations.enterButtonText,
                          style: theme.outlinedButtonTheme.style!.textStyle!
                              .resolve({}),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          onPressed: () => _launchWebsite(
                            "https://www.facebook.com/jyvaskylacityoflight/",
                          ),
                          icon: SvgPicture.asset(Assets.facebookIcon),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _launchWebsite(
                            "https://www.instagram.com/valonkaupunki/",
                          ),
                          icon: SvgPicture.asset(Assets.instagramIcon),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _launchWebsite(
                            "https://www.linkedin.com/company/valon-kaupunki-city-of-light/",
                          ),
                          icon: SvgPicture.asset(Assets.linkedinIcon),
                        ),
                        const Spacer(),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff000177),
            Color(0xff000000),
          ],
          stops: [0, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _renderContent(
        context: context,
        localizations: localizations,
        theme: theme,
      ),
    );
  }
}
