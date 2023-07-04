import "package:flutter/material.dart";

class WelcomeSlideUpAnimation extends AnimatedWidget {
  const WelcomeSlideUpAnimation(
      {super.key, required Animation<Offset> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<Offset>;

    return SlideTransition(
      position: animation,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 80,
          width: 80,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color.fromARGB(0xFF, 0xFF, 0xC7, 0x00),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }
}
