import "package:flutter/material.dart";

class CustomThemeValues {
  static TextStyle? _linkTheme;

  static TextStyle linkTheme(ThemeData theme) {
    _linkTheme ??= theme.textTheme.bodySmall!.copyWith(
      decoration: TextDecoration.underline,
      color: Colors.blue,
      decorationColor: Colors.blue,
    );

    return _linkTheme!;
  }
}
