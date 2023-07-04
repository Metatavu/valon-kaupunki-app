import "dart:math";

import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:url_launcher/url_launcher.dart";
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
    final loc = AppLocalizations.of(context)!;

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
                          loc.welcomeToValonKaupunki,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.w900,
                            fontSize: 20.0,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: "Mulish",
                                fontWeight: FontWeight.w400,
                                fontSize: 16.0,
                                color: Colors.white,
                                height: 1.25,
                                decoration: TextDecoration.none,
                              ),
                              children: [
                                TextSpan(text: loc.introductionTextPart1),
                                TextSpan(
                                  text: loc.introductionTextLink,
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchWebsite(
                                          "https://valonkaupunki.jyvaskyla.fi/");
                                    },
                                ),
                                const TextSpan(text: ".\n\n"),
                                TextSpan(text: loc.introductionTextPart2),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 24.0, bottom: 24.0),
                          child: OutlinedButton(
                            onPressed: () => {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                width: 1.0,
                                color: Color.fromARGB(0xFF, 0xFF, 0xC7, 0x00),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
                              loc.enterButtonText,
                              style: const TextStyle(
                                color: Color.fromARGB(0xFF, 0xFF, 0xC7, 0x00),
                                height: 1.25,
                                decoration: TextDecoration.none,
                              ),
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
