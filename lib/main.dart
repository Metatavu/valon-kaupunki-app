import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_map_tile_caching/flutter_map_tile_caching.dart";
import "package:valon_kaupunki_app/preferences/preferences.dart";
import "package:valon_kaupunki_app/screens/map_screen.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:valon_kaupunki_app/screens/welcome_screen.dart";
import "package:devicelocale/devicelocale.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMapTileCaching.initialise();
  final instance = FMTC.instance(
    const String.fromEnvironment("FMTC_STORE_NAME"),
  );
  await instance.manage.createAsync();

  final mySystemTheme = SystemUiOverlayStyle.light.copyWith(
    systemNavigationBarColor: Colors.black,
  );
  SystemChrome.setSystemUIOverlayStyle(mySystemTheme);

  await Preferences.init();

  // Locale
  var locale = Preferences.selectedLocale;
  if (locale == null) {
    final deviceLocales = await Devicelocale.preferredLanguages;

    locale = switch (deviceLocales?.first) {
      Locale(languageCode: "fi") => const Locale("fi"),
      null => const Locale("fi"),
      _ => const Locale("en")
    };

    await Preferences.setSelectedLocale(locale);
  }

  // App launched once
  final appLaunchedOnce = Preferences.appLaunchedOnce;
  if (!appLaunchedOnce) {
    await Preferences.setAppLaunchedOnce(true);
  }

  runApp(ValonKaupunkiApp(
    appLaunchedOnce: Preferences.appLaunchedOnce,
    initialLocale: locale,
  ));
}

class ValonKaupunkiApp extends StatefulWidget {
  final bool appLaunchedOnce;
  final Locale initialLocale;

  const ValonKaupunkiApp({
    required this.appLaunchedOnce,
    required this.initialLocale,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => ValonKaupunkiAppState();

  static ValonKaupunkiAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<ValonKaupunkiAppState>();
}

class ValonKaupunkiAppState extends State<ValonKaupunkiApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void setLocale(Locale locale) async {
    setState(() => _locale = locale);
    await Preferences.setSelectedLocale(locale);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      title: "Valon kaupunki",
      theme: ThemeData(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
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
      home: widget.appLaunchedOnce ? const MapScreen() : const WelcomeScreen(),
    );
  }
}
