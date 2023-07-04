import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:valon_kaupunki_app/widgets/welcome_slide_up_animation.dart";

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

  @override
  Widget build(BuildContext context) {
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
              ],
            ),
    );
  }
}
