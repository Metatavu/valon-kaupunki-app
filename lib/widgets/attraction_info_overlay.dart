import "dart:ui";
import "package:flutter/material.dart";

class AttractionInfoOverlay extends StatelessWidget {
  const AttractionInfoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        // Important empty container; flutter won't render the blur otherwise.
        child: SizedBox.expand(
          child: Container(
            color: Colors.transparent,
            child: Container(),
          ),
        ),
      ),
    );
  }
}
