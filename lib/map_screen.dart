import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_route_observer.dart';
import 'audio_service.dart';
import 'game_settings.dart';
import 'level_five.dart';
import 'level_four.dart';
import 'level_one.dart';
import 'level_progress.dart';
import 'level_three.dart';
import 'level_two.dart';

// Main widget for the map screen section.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  // Creates the state object for this widget.
  State<MapScreen> createState() => _MapScreenState();
}

// State for the map screen widget.
class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  static const double _mapPixelWidth = 1408;
  static const double _mapPixelHeight = 768;
  // Manual fine-tune for logo position inside the yellow ring.
  // +x moves right, -x moves left, +y moves down, -y moves up.
  static const Map<int, Offset> _logoInnerOffsetByLevel = {
    1: Offset(0, 0),
    2: Offset(0, 0),
    3: Offset(0, 0),
    4: Offset(0, 0),
    5: Offset(0, 0),
  };

  final List<_MapLevelPoint> _levelPoints = [];
  bool _loading = true;
  bool _parseFailed = false;
  bool _openingLevel = false;
  ModalRoute<dynamic>? _route;

  late final AnimationController _pulseController;

  @override
  // Sets up the state when this widget starts.
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadMapPoints();
    AudioService.stopMenuLoop();
  }

  @override
  // Updates state that depends on inherited widgets.
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _route) {
      if (_route != null) {
        appRouteObserver.unsubscribe(this);
      }
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  // Runs when this route becomes visible.
  void didPush() {
    AudioService.stopAllSfx();
    AudioService.playMapLoop();
  }

  @override
  // Runs when the user returns to this route.
  void didPopNext() {
    AudioService.stopAllSfx();
    AudioService.playMapLoop();
    FocusManager.instance.primaryFocus?.unfocus();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  // Runs when another route covers this one.
  void didPushNext() {
    AudioService.stopMapLoop();
  }

  @override
  // Cleans up resources before this widget is removed.
  void dispose() {
    appRouteObserver.unsubscribe(this);
    AudioService.stopMapLoop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  // Refreshes runtime state during hot reload.
  void reassemble() {
    super.reassemble();
    _loadMapPoints();
  }

  // Loads load map points.
  Future<void> _loadMapPoints() async {
    try {
      final xml = await rootBundle.loadString('assets/tiles/map.tmx');
      final points = _extractLevelPoints(xml);
      points.sort((a, b) => a.level.compareTo(b.level));
      if (!mounted) return;
      setState(() {
        _levelPoints
          ..clear()
          ..addAll(points);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _parseFailed = true;
        _loading = false;
      });
    }
  }

  // Handles extract level points.
  List<_MapLevelPoint> _extractLevelPoints(String xml) {
    final results = <_MapLevelPoint>[];
    final levelGroupMatch = RegExp(
      r'<objectgroup[^>]*name="level"[^>]*>([\s\S]*?)</objectgroup>',
      caseSensitive: false,
    ).firstMatch(xml);
    if (levelGroupMatch == null) {
      throw StateError('No object layer named level in map.tmx');
    }

    final levelGroupXml = levelGroupMatch.group(1) ?? '';
    final objectRegex = RegExp(r'<object\b[^>]*>', caseSensitive: false);

    for (final objectMatch in objectRegex.allMatches(levelGroupXml)) {
      final objectTag = objectMatch.group(0) ?? '';
      final level = int.tryParse(_readAttr(objectTag, 'name') ?? '');
      final x = double.tryParse(_readAttr(objectTag, 'x') ?? '');
      final y = double.tryParse(_readAttr(objectTag, 'y') ?? '');
      if (level == null || x == null || y == null || level < 1 || level > 5) {
        continue;
      }
      results.add(_MapLevelPoint(level: level, x: x, y: y));
    }

    if (results.isEmpty) {
      throw StateError('No level points found in map.tmx');
    }

    return results;
  }

  // Reads read attr.
  String? _readAttr(String tag, String attr) {
    final match = RegExp(
      '$attr="([^"]+)"',
      caseSensitive: false,
    ).firstMatch(tag);
    return match?.group(1);
  }

  // Asks the user about ask resume choice.
  Future<bool?> _askResumeChoice(int level) async {
    final checkpoint = LevelProgress.resumePositionForLevel(level);
    if (checkpoint == null) return false;
    final checkpointArea = LevelProgress.checkpointAreaForLevel(level);
    final checkpointTime = LevelProgress.checkpointRelativeTimeForLevel(level);

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191E2A),
          title: Text('Level $level'),
          content: Text(
            'Resume from your last checkpoint or start a new run?\n\nCheckpoint: $checkpointArea\n$checkpointTime',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Start New'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Resume'),
            ),
          ],
        );
      },
    );
  }

  // Opens level.
  Future<void> _openLevel(int level) async {
    if (!LevelProgress.isUnlocked(level) || _openingLevel) return;
    _openingLevel = true;
    final useResume = await _askResumeChoice(level);
    if (useResume == null) {
      _openingLevel = false;
      return;
    }
    LevelProgress.setResumeChoiceForNextLaunch(
      level: level,
      useResumePosition: useResume,
    );
    LevelProgress.setLastPlayedLevel(level);
    final navigator = Navigator.of(context);
    await GameSettings.playUiTapSound();
    if (!mounted) return;
    AudioService.stopMapLoop();

    final Widget scene = switch (level) {
      1 => const LevelOneScene(),
      2 => const LevelTwoScene(),
      3 => const LevelThreeScene(),
      4 => const LevelFourScene(),
      5 => const LevelFiveScene(),
      _ => const LevelOneScene(),
    };

    final nextLevel = await navigator.push<int>(
      MaterialPageRoute(builder: (_) => scene),
    );

    if (!mounted) return;
    if (nextLevel != null && LevelProgress.isUnlocked(nextLevel)) {
      _openingLevel = false;
      await _openLevel(nextLevel);
      return;
    }
    _openingLevel = false;
    FocusManager.instance.primaryFocus?.unfocus();
    if (_route?.isCurrent ?? false) {
      AudioService.playMapLoop();
    }
    setState(() {});
  }

  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121722),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/map.png', fit: BoxFit.fill),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          await GameSettings.playUiTapSound();
                          if (!mounted) return;
                          navigator.pop();
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Text(
                          'MAP  •  Unlocked: ${LevelProgress.highestUnlockedLevel}/5',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: Colors.amber))
          else if (_parseFailed)
            const Center(
              child: Text(
                'Could not load map points from map.tmx',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return Stack(
                      children: [
                        for (final point in _levelPoints)
                          _buildLevelLogo(constraints, point),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  // Builds build level logo.
  Widget _buildLevelLogo(BoxConstraints constraints, _MapLevelPoint point) {
    final sx = constraints.maxWidth / _mapPixelWidth;
    final sy = constraints.maxHeight / _mapPixelHeight;
    final centerX = point.x * sx;
    final centerY = point.y * sy;
    final unlocked = LevelProgress.isUnlocked(point.level);

    final logoSize = (constraints.biggest.shortestSide * 0.28).clamp(
      120.0,
      170.0,
    );
    final halfLogo = logoSize / 2;
    final safePadding = MediaQuery.of(context).padding;
    final minCenterX = halfLogo + 8;
    final maxCenterX = constraints.maxWidth - halfLogo - 8;
    final minCenterY = safePadding.top + 70 + halfLogo;
    final maxCenterY = constraints.maxHeight - halfLogo - 8;
    final clampedCenterX = centerX.clamp(minCenterX, maxCenterX);
    final clampedCenterY = centerY.clamp(minCenterY, maxCenterY);

    final ringSize = logoSize * 0.62;
    final logoInnerSize = ringSize * 0.9;
    final pulse = 0.9 + (_pulseController.value * 0.2);
    final glow = 14.0 + (18.0 * _pulseController.value);
    final scale = unlocked ? pulse : 1.0;
    final innerOffset = _logoInnerOffsetByLevel[point.level] ?? Offset.zero;

    return Positioned(
      left: clampedCenterX - halfLogo,
      top: clampedCenterY - halfLogo,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openLevel(point.level),
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(color: Colors.transparent),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: ringSize,
                  height: ringSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: unlocked ? Colors.amberAccent : Colors.white54,
                      width: unlocked ? 2.5 : 1.8,
                    ),
                    boxShadow: unlocked
                        ? [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.55),
                              blurRadius: glow * 0.7,
                              spreadRadius: 0.6,
                            ),
                            BoxShadow(
                              color: Colors.yellow.withValues(alpha: 0.25),
                              blurRadius: glow * 0.45,
                              spreadRadius: 0.2,
                            ),
                          ]
                        : const [],
                  ),
                ),
                Opacity(
                  opacity: unlocked
                      ? (0.8 + (0.2 * _pulseController.value))
                      : 0.45,
                  child: Transform.translate(
                    offset: innerOffset,
                    child: SizedBox(
                      width: logoInnerSize,
                      height: logoInnerSize,
                      child: Image.asset(
                        'assets/images/level${point.level}.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                if (!unlocked)
                  const Icon(Icons.lock, color: Colors.white, size: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Class for the map level point feature.
class _MapLevelPoint {
  _MapLevelPoint({required this.level, required this.x, required this.y});

  final int level;
  final double x;
  final double y;
}
