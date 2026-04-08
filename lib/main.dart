import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_gate.dart';
import 'auth_service.dart';
import 'app_route_observer.dart';
import 'audio_service.dart';
import 'game_settings.dart';

// Starts the app and loads saved services.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GameSettings.loadFromDisk();
  await AuthService.initialize();

  // 1. Lock the app into Landscape mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 2. Full-screen settings: Hide status bar AND navigation bar
  // Using immersiveSticky ensures the bars stay hidden and only show
  // as temporary overlays if the user swipes.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Optional: Extra layer of protection for older devices to ensure
  // both top and bottom overlays are removed.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  runApp(const MyGameApp());
}

// Main widget for the my game app section.
class MyGameApp extends StatefulWidget {
  const MyGameApp({super.key});

  @override
  State<MyGameApp> createState() => _MyGameAppState();
}

class _MyGameAppState extends State<MyGameApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      AudioService.stopAllAudio();
    }
  }

  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hammerfall',
      navigatorObservers: [appRouteObserver],
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true, // Modern look for Flutter apps
      ),
      home: const AuthGate(),
    );
  }
}
