import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/launcher_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Make system navigation and status bars edge-to-edge transparent
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(
    const ProviderScope(
      child: OnePlusIOS27ThemeApp(),
    ),
  );
}

class OnePlusIOS27ThemeApp extends StatelessWidget {
  const OnePlusIOS27ThemeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnePlus iOS27 Launcher',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
      home: const LauncherHomeScreen(),
    );
  }
}
