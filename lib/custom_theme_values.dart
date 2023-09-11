import "package:flutter/material.dart";

class CustomThemeValues {
  static TextStyle? _linkTheme;
  static Color appOrange = const Color.fromARGB(0xFF, 0xFF, 0xC7, 0x00);
  static Color lightArtPieceColor =
      const Color.fromARGB(0xFF, 0x00, 0xFF, 0xD1);
  static Color restaurantOrCafeColor =
      const Color.fromARGB(0xfF, 0xFD, 0xA2, 0x9B);
  static Color shoppingColor = const Color.fromARGB(0xFF, 0x3E, 0xE9, 0x64);
  static Color supplementaryShowColor =
      const Color.fromARGB(0xFF, 0xD0, 0xD5, 0xDD);
  static Color jyvasParkkiColor = const Color.fromARGB(0xFF, 0xD0, 0xD5, 0xDD);

  static TextStyle linkTheme(ThemeData theme) {
    _linkTheme ??= theme.textTheme.bodySmall!.copyWith(
      decoration: TextDecoration.underline,
      color: Colors.blue,
      decorationColor: Colors.blue,
    );

    return _linkTheme!;
  }
}
