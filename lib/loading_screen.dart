import 'package:flutter/material.dart';
import 'package:flame/flame.dart';

import 'image_preload_list.dart';
//import 'level_one.dart';
import 'level_progress.dart';
import 'main_menu.dart';

// Main widget for the loading screen section.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  // Creates the state object for this widget.
  State<LoadingScreen> createState() => _LoadingScreenState();
}

// State for the loading screen widget.
class _LoadingScreenState extends State<LoadingScreen> {
  double _progress = 0.0;
  String _loadingText = "Preparing your adventure...";

  @override
  // Sets up the state when this widget starts.
  void initState() {
    super.initState();
    _startRealLoading();
  }

  // Starts start real loading.
  Future<void> _startRealLoading() async {
    try {
      final imagePaths = kImagePreloadList;

      if (imagePaths.isEmpty) {
        // Fallback if no images are found (prevents division by zero)
        _navigateToGame();
        return;
      }

      int totalItems = imagePaths.length;
      int itemsLoaded = 0;

      // Preload the known game art directly to avoid manifest lookups that can
      // fail on some Android builds.
      for (String path in imagePaths) {
        await Flame.images.load(path);

        itemsLoaded++;
        if (mounted) {
          setState(() {
            _progress = itemsLoaded / totalItems;
            _loadingText = "Loading assets $itemsLoaded / $totalItems";
          });
        }
      }

      // 4. Finalizing
      await LevelProgress.loadForCurrentUser();
      if (mounted) {
        setState(() {
          _progress = 1.0;
          _loadingText = "Ready! Entering the kingdom...";
        });
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToGame();
      }
    } catch (e) {
      debugPrint("Error during loading: $e");
      _navigateToGame(); // Move to game anyway so the app doesn't hang
    }
  }

  // Handles navigate to game.
  void _navigateToGame() {
    // After loading we go to the main menu instead of jumping directly into
    // level one.  The menu will let the player choose which level to play.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainMenu()),
    );
  }

  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final panelWidth = (screenSize.width * 0.55).clamp(280.0, 520.0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/main_menu_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.28)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logoText.png',
                      width: (screenSize.width * 0.44).clamp(220.0, 380.0),
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: panelWidth,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.52),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _loadingText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFE8F8EE),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.35,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2FDB5F),
                                        Color(0xFF0EAF4B),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF3AF06D,
                                        ).withValues(alpha: 0.45),
                                        blurRadius: 8,
                                        spreadRadius: 0.6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
