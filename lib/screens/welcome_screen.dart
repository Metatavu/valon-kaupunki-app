import "dart:math";

import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:url_launcher/url_launcher.dart";
import "package:valon_kaupunki_app/custom_theme_values.dart";
import "package:valon_kaupunki_app/widgets/welcome_slide_up_animation.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WelcomeScreenState();
  }
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool _showAnimation = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    controller.forward();
    controller.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(
            const Duration(milliseconds: 500),
            () => {setState(() => _showAnimation = false)},
          );
        }
      },
    );
  }

  void _launchWebsite(String url) async {
    launchUrl(Uri.parse(url));
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
      child: _showAnimation
          ? WelcomeSlideUpAnimation(
              animation: Tween<Offset>(
                begin: Offset.zero,
                end: Offset.fromDirection(3 * pi / 2, 0.5),
              ).animate(controller),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SvgPicture.asset(
                      "assets/valon_kaupunki.svg",
                      width: 250,
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
                                TextSpan(
                                    text: localizations.introductionTextPart1),
                                TextSpan(
                                  text: localizations.introductionTextLink,
                                  style: CustomThemeValues.linkTheme(theme),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchWebsite(
                                          "https://valonkaupunki.jyvaskyla.fi/");
                                    },
                                ),
                                const TextSpan(text: ".\n\n"),
                                TextSpan(
                                    text: localizations.introductionTextPart2),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 24.0, bottom: 24.0),
                          child: OutlinedButton(
                            onPressed: () => {},
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
                              onPressed: () => {},
                              icon: SvgPicture.asset("assets/facebook.svg"),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => {},
                              icon: SvgPicture.asset("assets/instagram.svg"),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => {},
                              icon: SvgPicture.asset("assets/linkedin.svg"),
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
    );
  }
}
