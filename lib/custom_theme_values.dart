import "package:flutter/material.dart";

class CustomThemeValues {
  static TextStyle? _linkTheme;
  static Color appOrange = const Color.fromARGB(0xFF, 0xFF, 0xC7, 0x00);

  static TextStyle linkTheme(ThemeData theme) {
    _linkTheme ??= theme.textTheme.bodySmall!.copyWith(
      decoration: TextDecoration.underline,
      color: Colors.blue,
      decorationColor: Colors.blue,
    );

    return _linkTheme!;
  }
}
