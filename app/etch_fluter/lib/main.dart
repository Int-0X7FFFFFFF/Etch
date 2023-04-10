import 'package:etch_fluter/devices.dart';
import 'package:etch_fluter/nav.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'connect_page.dart';
import 'common.dart';
import 'draw/draw_preview.dart';

void main(List<String> args) async {
  try {
    if (Platform.isAndroid) {
      WidgetsFlutterBinding.ensureInitialized();
      final overlayStye = _makeSystemOverlayStyle();
      SystemChrome.setSystemUIOverlayStyle(overlayStye);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    }
    // ignore: empty_catches
  } catch (e) {}

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: ColorSeed()),
      ChangeNotifierProvider.value(value: Load()),
      ChangeNotifierProvider.value(value: API()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final routes = {
    '/': (context, {arguments}) => const ConnectPage(),
    '/dev': (context, {arguments}) => const DevicesPage(),
    '/home': (context, {arguments}) => const HomePage(),
    '/prview': (context, {arguments}) => const PrviewPage(),
  };

  Future<dynamic> highRefreshRate() async {
    // HighRefreshRat
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      /// e.code =>
      /// noAPI - No API support. Only Marshmallow and above.
      /// noActivity - Activity is not available. Probably app is in background
      // ignore: avoid_print
      print(e.toString());
    }
    return 'OK';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: highRefreshRate(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return MaterialApp(
            title: 'etch control panel',
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed:
                  Provider.of<ColorSeed>(context).getColor, // M3 Baseline
            ),
            darkTheme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Provider.of<ColorSeed>(context).getColor,
                brightness: Brightness.dark // M3 Baseline
                ),
            routes: routes,
            initialRoute: '/',
          );
        } else {
          return const MaterialApp();
        }
      },
    );
  }
}

SystemUiOverlayStyle _makeSystemOverlayStyle() {
  return const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  );
}

class ColorSeed extends ChangeNotifier {
  var colorSeed = const Color(0xff6750a4);

  void setColor(targetColor) {
    colorSeed = targetColor;
    notifyListeners();
  }

  Color get getColor => colorSeed;
}
