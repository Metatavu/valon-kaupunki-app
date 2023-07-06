import "package:flutter/material.dart";
import "package:valon_kaupunki_app/screens/map_screen.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Valon kaupunki",
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: "Mulish",
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
          bodySmall: TextStyle(
            fontFamily: "Mulish",
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
            color: Colors.white,
            height: 1.25,
            decoration: TextDecoration.none,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
              width: 1.0,
              color: Color.fromARGB(0xFF, 0xFF, 0xC7, 0x00),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            textStyle: const TextStyle(
              color: Color.fromARGB(0xFF, 0xFF, 0xC7, 0x00),
              height: 1.25,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MapScreen(),
    );
  }
}
