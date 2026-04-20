import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as pv;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Views/Root/root_controller.dart';
import 'Utility/Basics/app_navigator.dart';
import 'Utility/Basics/app_providers.dart';
import 'Utility/Basics/handle_ssl_certificate.dart';
import 'Utility/internet_connection/connection_handler.dart';
import 'Utility/internet_connection/no_internet_connection.dart';

import 'Views/Basic_Modules/SplashScreen.dart';
import 'l10n/app_localizations.dart';
import 'material_theme/material_theme.dart';
import 'material_theme/theme_controller.dart';
import 'material_theme/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }

  await GetStorage.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android
      statusBarBrightness: Brightness.light, // iOS
    ),
  );

  runApp(
    rp.ProviderScope(
      child: pv.ChangeNotifierProvider(
        create: (_) => ThemeController(),
        child: MyApp(),
      ),
    ),
  );
}

final appProviders = [...basicProviders, ...walletProviders, ...spotProviders];

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  RootController languageController = RootController();

  @override
  void dispose() {
    // TODO: implement dispose
    languageController.resetLanguage();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    languageController.resetLanguage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.light().textTheme;
    TextTheme textTheme = createTextTheme(
      context,
      GoogleFonts.outfitTextTheme(baseTextTheme),
    );
    MaterialTheme theme = MaterialTheme(textTheme);
    const overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // ANDROID: white icons
      statusBarBrightness: Brightness.dark, // iOS: white icons
    );

    return pv.MultiProvider(
      providers: appProviders,
      child: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return pv.Consumer<RootController>(
            builder: (context, value, child) {
              return MaterialApp(
                navigatorKey: AppNavigator.navigatorKey,
                theme: theme.light(),
                darkTheme: theme.dark(),
                themeMode: context.watch<ThemeController>().themeMode,
                debugShowCheckedModeBanner: false,
                title: 'Zayro',
                home: const SplashScreen(),
                supportedLocales: const [Locale("zh"), Locale("en")],
                locale: value.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routes: {'/login': (context) => const SplashScreen()},
                builder: (context, child) {
                  return ConnectivityGate(
                    overlayStyle: overlay,
                    offlineOverlay: const OfflineOverlay(),
                    child: child!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
