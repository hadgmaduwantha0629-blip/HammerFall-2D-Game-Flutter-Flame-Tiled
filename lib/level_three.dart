import 'dart:async' as async;
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart' hide Text;
import 'package:flutter/material.dart';
import 'audio_service.dart';
import 'game_settings.dart';
import 'level_progress.dart';
import 'sound_controls_panel.dart';

// Main widget for the level three scene section.
class LevelThreeScene extends StatefulWidget {
  const LevelThreeScene({super.key});

  @override
  // Creates the state object for this widget.
  State<LevelThreeScene> createState() => _LevelThreeSceneState();
}

// State for the level three scene widget.
class _LevelThreeSceneState extends State<LevelThreeScene> {
  late final LevelThreeGame game;
  bool _showDifficultyBanner = true;
  bool _isTransitioning = false;
  async.Timer? _difficultyBannerTimer;

  @override
  // Sets up the state when this widget starts.
  void initState() {
    super.initState();
    game = LevelThreeGame();
    _difficultyBannerTimer = async.Timer(const Duration(seconds: 7), () {
      if (!mounted) return;
      setState(() {
        _showDifficultyBanner = false;
      });
    });
  }

  @override
  // Cleans up resources before this widget is removed.
  void dispose() {
    _difficultyBannerTimer?.cancel();
    AudioService.stopAllSfx();
    game.pauseEngine();
    super.dispose();
  }

  void _pauseGame() {
    AudioService.stopAllSfx();
    game.pauseEngine();
  }

  void _clearTransientOverlays() {
    game.overlays.remove('VictoryMenu');
    game.overlays.remove('DefeatMenu');
    game.overlays.remove('LevelHint');
    game.overlays.remove('SuperPowerHud');
  }

  Future<void> _exitLevel() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _clearTransientOverlays();
    _pauseGame();
    await GameSettings.playUiTapSound();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _restartLevel() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _clearTransientOverlays();
    _pauseGame();
    await GameSettings.playUiTapSound();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LevelThreeScene()),
    );
  }

  Future<void> _goToNextLevel() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _clearTransientOverlays();
    _pauseGame();
    await GameSettings.playUiTapSound();
    if (!mounted) return;
    Navigator.of(context).pop(4);
  }

  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget(
              game: game,
              overlayBuilderMap: {
                'LevelHint': (context, LevelThreeGame game) =>
                    _buildLevelHint(game),
                'SuperPowerHud': (context, LevelThreeGame game) =>
                    _buildSuperPowerHud(game),
                'VictoryMenu': (context, LevelThreeGame game) => Center(
                  child: Container(
                    width: 360,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.yellow, width: 3),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/king_win_bg.png'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Color(0x99101827),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Victory!',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Mission complete. The King escaped through the end door.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFF5F7FF),
                            fontSize: 18,
                            height: 1.35,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: _restartLevel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'REPLAY',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            ElevatedButton(
                              onPressed: _goToNextLevel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'NEXT LEVEL',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                'DefeatMenu': (context, LevelThreeGame game) => Center(
                  child: Container(
                    width: 360,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.yellow, width: 3),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/king_fail_bg.png'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Color(0x99101827),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Play Again',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          game.defeatMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFF5F7FF),
                            fontSize: 18,
                            height: 1.35,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: _restartLevel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'REPLAY',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            ElevatedButton(
                              onPressed: _exitLevel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'BACK',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              },
            ),
          ),
          if (_showDifficultyBanner)
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      'Difficulty: ${GameSettings.difficultyLabel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 40,
            left: 20,
            child: BackButton(
              color: Colors.white,
              onPressed: _exitLevel,
            ),
          ),
          Positioned(top: 40, right: 110, child: _buildPigKillHud(game)),
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTapDown: (_) => _showGameMenu(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: const Icon(Icons.menu, color: Colors.white, size: 28),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 30,
            child: Row(
              children: [
                _btn(
                  Icons.arrow_back,
                  () => game.player.move(-1),
                  () => game.player.move(0),
                ),
                const SizedBox(width: 20),
                _btn(
                  Icons.arrow_forward,
                  () => game.player.move(1),
                  () => game.player.move(0),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            right: 30,
            child: Row(
              children: [
                _btn(
                  Icons.gavel,
                  () => game.player.attack(),
                  null,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 20),
                _btn(
                  Icons.arrow_upward,
                  () => game.player.jump(),
                  null,
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds build level hint.
  Widget _buildLevelHint(LevelThreeGame game) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 42, left: 20),
            child: ValueListenableBuilder<String?>(
              valueListenable: game.levelHint,
              builder: (context, hint, _) {
                if (hint == null || hint.isEmpty) {
                  return const SizedBox.shrink();
                }
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 260),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * -8),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 330),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCCB71C1C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Text(
                      hint,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Builds build pig kill hud.
  Widget _buildPigKillHud(LevelThreeGame game) {
    return IgnorePointer(
      child: ValueListenableBuilder<int>(
        valueListenable: game.pigKillsNotifier,
        builder: (context, kills, _) {
          final progress = (kills / game.requiredPigKills).clamp(0.0, 1.0);
          final fillColor = Color.lerp(
            const Color(0xFFFF00E5),
            const Color(0xFF00FFB3),
            progress,
          )!;
          return Container(
            width: 208,
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
            decoration: BoxDecoration(
              color: const Color(0x99101820),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pig Hunt: $kills/${game.requiredPigKills}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 9,
                    value: progress,
                    backgroundColor: const Color(0x334DFFFF),
                    valueColor: AlwaysStoppedAnimation<Color>(fillColor),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Builds build super power hud.
  Widget _buildSuperPowerHud(LevelThreeGame game) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ValueListenableBuilder<int>(
            valueListenable: game.superPowerSeconds,
            builder: (context, seconds, _) {
              if (seconds <= 0) return const SizedBox.shrink();
              final progress = (seconds / 30).clamp(0.0, 1.0);

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: progress),
                  duration: const Duration(milliseconds: 280),
                  builder: (context, animatedProgress, _) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          const Color(0xFF00695C),
                          const Color(0xFFB71C1C),
                          1 - animatedProgress,
                        )!.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              value: animatedProgress,
                              strokeWidth: 3,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                seconds > 10
                                    ? const Color(0xFF80CBC4)
                                    : const Color(0xFFFF8A80),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'SUPER POWER: ${seconds}s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Builds a control button.
  Widget _btn(
    IconData icon,
    Function() down,
    Function()? up, {
    Color color = Colors.black54,
  }) {
    return GestureDetector(
      onTapDown: (_) => down(),
      onTapUp: (_) => up?.call(),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 35),
      ),
    );
  }

  // Shows show game menu.
  void _showGameMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 330),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellow, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/cease_fire_bg.png'),
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      Color(0x80101827),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Material(
                  color: const Color(0xB31A2133),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 8, bottom: 2),
                              child: Text(
                                'GAME OPTIONS',
                                style: TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  shadows: [
                                    Shadow(color: Colors.black, blurRadius: 10),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Ceasefire protocol is live. Regroup or push the war front.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFE9EEFF),
                                  fontSize: 12,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.replay,
                                color: Colors.orange,
                              ),
                              title: const Text(
                                'Replay Level',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              dense: true,
                              splashColor: Colors.white24,
                              onTap: () {
                                Navigator.pop(context);
                                _restartLevel();
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.restart_alt,
                                color: Colors.amber,
                              ),
                              title: const Text(
                                'Restart Fresh (No Checkpoint)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              dense: true,
                              splashColor: Colors.white24,
                              onTap: () {
                                LevelProgress.clearCheckpointForLevel(3);
                                Navigator.pop(context);
                                _restartLevel();
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.home,
                                color: Colors.blue,
                              ),
                              title: const Text(
                                'Main Menu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              dense: true,
                              splashColor: Colors.white24,
                              onTap: () {
                                Navigator.pop(context);
                                _exitLevel();
                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: SoundControlsPanel(dense: true),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              title: const Text(
                                'Resume Game',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              dense: true,
                              splashColor: Colors.white24,
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Main game logic for the level three game scene.
class LevelThreeGame extends FlameGame with HasCollisionDetection {
  static const double _tileSize = 32.0;
  static const double levelZoom = 1.8;
  static const double cameraFollowMaxSpeed = 1400.0;
  static final Anchor cameraFollowAnchor = Anchor(0.5, 0.82);
  // Tune these to move king up/down globally.
  // Negative value = king appears higher. Positive value = king appears lower.
  static const double kingSpawnYOffset = 11.0;
  static const double kingDoorEntryYOffset = 11.0;
  static const double kingGroundOffset = 11.0;

  late PlayerThree player;
  EndDoorThree? endDoor;
  List<Rect> groundRects = [];
  double mapWidth = 0;
  double mapHeight = 0;
  int pigKills = 0;
  final int requiredPigKills = 15;
  final ValueNotifier<int> pigKillsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> superPowerSeconds = ValueNotifier<int>(0);
  final ValueNotifier<String?> levelHint = ValueNotifier<String?>(null);
  bool endSequenceStarted = false;
  bool gameEnded = false;
  String defeatMessage = '';
  final List<String> _defeatMessages = const [
    'The pigs own this castle today. Grab the hammer and take your crown back.',
    'The royal hammer slipped. Pigs are laughing in the throne room.',
    'No king, no kingdom. Smash the pigs and reclaim the door.',
  ];

  LevelThreeGame()
    : super(
        camera: CameraComponent()
          ..viewfinder.anchor = cameraFollowAnchor
          ..viewfinder.zoom = levelZoom,
      );

  bool get shouldFreezeEnemies =>
      gameEnded || endSequenceStarted || player.isDead || player.isEnteringDoor;

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    camera.viewfinder.zoom = levelZoom;
    Future.delayed(const Duration(milliseconds: 350), () {
      showLevelHint(
        'Get the red hammer drink for super power to kill the giant pig!',
        duration: const Duration(seconds: 6),
      );
    });

    final level = await TiledComponent.load(
      'level_03.tmx',
      Vector2.all(_tileSize),
    );
    world.add(level);

    mapWidth = (level.tileMap.map.width * _tileSize).toDouble();
    mapHeight = (level.tileMap.map.height * _tileSize).toDouble();
    camera.viewfinder.anchor = cameraFollowAnchor;

    final groundLayer = level.tileMap.getLayer<ObjectGroup>('g&w');
    if (groundLayer != null) {
      for (final obj in groundLayer.objects) {
        final objName = obj.name.trim();
        if (objName == 'ground') {
          groundRects.add(Rect.fromLTWH(obj.x, obj.y, obj.width, obj.height));
        }
      }
    }

    final spawns = level.tileMap.getLayer<ObjectGroup>('spawnpoints');
    if (spawns != null) {
      for (final obj in spawns.objects) {
        final objName = obj.name.trim();
        if (objName == 'king') {
          player = PlayerThree(
            position: Vector2(obj.x, obj.y + kingSpawnYOffset),
          );
          world.add(player);
        }
      }

      final useResume = LevelProgress.consumeResumeChoiceForLaunch(level: 3);
      final resume = LevelProgress.resumePositionForLevel(3);
      if (useResume && resume != null) {
        player.position.setValues(resume.x, resume.y);
        showLevelHint('Resumed from your last checkpoint.');
      }
      LevelProgress.setLastPlayedLevel(3);

      final List<Cannon> leftCannons = [];
      final List<Cannon> rightCannons = [];
      for (final obj in spawns.objects) {
        final objName = obj.name.trim().toLowerCase();
        if (objName == 'cannon_left' || objName.startsWith('cannon_left')) {
          final cannon = Cannon(
            position: Vector2(obj.x, obj.y),
            side: CannonSide.left,
          );
          leftCannons.add(cannon);
          world.add(cannon);
        } else if (objName == 'cannon_right' ||
            objName.startsWith('cannon_right')) {
          final cannon = Cannon(
            position: Vector2(obj.x, obj.y),
            side: CannonSide.right,
          );
          rightCannons.add(cannon);
          world.add(cannon);
        }
      }

      for (final obj in spawns.objects) {
        final objName = obj.name.trim().toLowerCase();
        if (objName == 'startdoor') {
          world.add(
            DoorThree(
              position: Vector2(obj.x, obj.y),
              onOpened: () => player.spawnFromDoor(),
            ),
          );
        } else if (objName == 'enddoor') {
          endDoor = EndDoorThree(position: Vector2(obj.x, obj.y));
          world.add(endDoor!);
        } else if (objName == 'box_pig') {
          world.add(BoxPig(position: Vector2(obj.x, obj.y)));
        } else if (objName == 'bombing_pig') {
          world.add(BombingPig(position: Vector2(obj.x, obj.y)));
        } else if (objName == 'giant_pig') {
          world.add(GiantPig(position: Vector2(obj.x, obj.y)));
        } else if (objName == 'super_power') {
          world.add(SuperPowerPickup(position: Vector2(obj.x, obj.y)));
        } else if (objName == 'heart') {
          world.add(HeartPickupThree(position: Vector2(obj.x, obj.y)));
        } else if ((objName == 'cannon_fire_pig_left' ||
                objName.startsWith('cannon_fire_pig_left')) &&
            leftCannons.isNotEmpty) {
          final pigPos = Vector2(obj.x, obj.y);
          final nearest = leftCannons.reduce(
            (a, b) =>
                (a.position - pigPos).length < (b.position - pigPos).length
                ? a
                : b,
          );
          world.add(CannonPig(position: pigPos, cannon: nearest));
        } else if ((objName == 'cannon_fire_pig_right' ||
                objName.startsWith('cannon_fire_pig_right')) &&
            rightCannons.isNotEmpty) {
          final pigPos = Vector2(obj.x, obj.y);
          final nearest = rightCannons.reduce(
            (a, b) =>
                (a.position - pigPos).length < (b.position - pigPos).length
                ? a
                : b,
          );
          world.add(CannonPig(position: pigPos, cannon: nearest));
        }
      }
    }

    camera.follow(player, snap: false, maxSpeed: cameraFollowMaxSpeed);
    camera.setBounds(Rectangle.fromLTWH(0, 0, mapWidth, mapHeight));
    camera.viewfinder.zoom = levelZoom;
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);

    if (gameEnded || endSequenceStarted || endDoor == null) return;
    if (player.isEntering || player.isEnteringDoor) return;
    if (pigKills < requiredPigKills) return;

    final closeToDoorX = (player.position.x - endDoor!.position.x).abs() < 22;
    final closeToDoorY = (player.position.y - endDoor!.position.y).abs() < 30;
    if (closeToDoorX && closeToDoorY) {
      endSequenceStarted = true;
      player.enterDoor(endDoor!);
    }
  }

  // Shows the victory flow for this level.
  void showVictory() {
    if (gameEnded) return;
    gameEnded = true;
    setSuperPowerSeconds(0);
    LevelProgress.markCompleted(3);
    AudioService.playSfx(AudioService.kingDoorOut, volume: 0.95);
    overlays.add('VictoryMenu');
  }

  // Updates progress after a pig is defeated.
  void registerPigKill() {
    if (gameEnded) return;
    pigKills++;
    pigKillsNotifier.value = pigKills;
    AudioService.playSfx(AudioService.deathPop, volume: 0.9);
  }

  // Handles the defeat flow when the king is defeated.
  void onKingDead() {
    if (gameEnded) return;
    gameEnded = true;
    endSequenceStarted = true;
    setSuperPowerSeconds(0);
    AudioService.playSfx(AudioService.deathPop, volume: 0.9);
    AudioService.playSfx(AudioService.fail, volume: 1.0);
    defeatMessage = _defeatMessages[Random().nextInt(_defeatMessages.length)];
    overlays.add('DefeatMenu');
  }

  // Sets super power seconds.
  void setSuperPowerSeconds(int seconds) {
    final clamped = seconds.clamp(0, 30);
    if (superPowerSeconds.value == clamped) return;
    superPowerSeconds.value = clamped;
    if (clamped > 0) {
      if (!overlays.isActive('SuperPowerHud')) {
        overlays.add('SuperPowerHud');
      }
    } else if (overlays.isActive('SuperPowerHud')) {
      overlays.remove('SuperPowerHud');
    }
  }

  // Shows show level hint.
  void showLevelHint(
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    levelHint.value = message;
    if (!overlays.isActive('LevelHint')) {
      overlays.add('LevelHint');
    }
    Future.delayed(duration, () {
      if (levelHint.value == message) {
        levelHint.value = null;
        if (overlays.isActive('LevelHint')) {
          overlays.remove('LevelHint');
        }
      }
    });
  }
}

// Game component for the player three object.
class PlayerThree extends SpriteAnimationComponent
    with HasGameRef<LevelThreeGame>, CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  double moveSpeed = 180;
  double gravity = 1100;
  double jumpForce = 520;
  static const double _normalJumpForce = 520;
  static const double _superJumpForce = 1040;
  static const double _superPowerDuration = 30;
  static final Vector2 _normalSize = Vector2(78, 58);
  static final Vector2 _superSize = Vector2(132, 98);
  bool isGrounded = false;
  bool isAttacking = false;
  bool isEntering = true;
  bool isEnteringDoor = false;
  bool isDead = false;
  bool isTakingHit = false;
  bool hasDealtDamage = false;
  bool isInvulnerable = false;
  bool isSuperPowered = false;
  double superPowerRemaining = 0;
  double invulnerableTimer = 0;
  double _progressSaveTimer = 0;
  int horizontalMovement = 0;
  int facingDirection = 1;
  double health = GameSettings.kingHealthDouble(8);
  final double maxHealth = GameSettings.kingHealthDouble(8);

  late SpriteAnimation idleAnim;
  late SpriteAnimation runAnim;
  late SpriteAnimation attackAnim;
  late SpriteAnimation doorOutAnim;
  late SpriteAnimation doorInAnim;
  late SpriteAnimation hitAnim;
  late SpriteAnimation deadAnim;

  late RectangleHitbox playerHitbox;

  PlayerThree({super.position})
    : super(size: Vector2(78, 58), anchor: Anchor.bottomCenter, priority: 10);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    playerHitbox = RectangleHitbox(
      size: Vector2(24, 40),
      position: Vector2(8, 4),
    );
    add(playerHitbox);

    idleAnim = await _loadKingAnim('01-King Human/Idle (78x58).png', 11);
    runAnim = await _loadKingAnim('01-King Human/Run (78x58).png', 8);
    attackAnim = await _loadKingAnim(
      '01-King Human/Attack (78x58).png',
      3,
      loop: false,
    );
    doorOutAnim = await _loadKingAnim(
      '01-King Human/Door Out (78x58).png',
      8,
      loop: false,
    );
    doorInAnim = await _loadKingAnim(
      '01-King Human/Door In (78x58).png',
      8,
      loop: false,
    );
    hitAnim = await _loadKingAnim(
      '01-King Human/Hit (78x58).png',
      2,
      loop: false,
    );
    deadAnim = await _loadKingAnim(
      '01-King Human/Dead (78x58).png',
      4,
      loop: false,
    );

    animation = doorOutAnim;
    opacity = 0;
  }

  // Loads load king anim.
  Future<SpriteAnimation> _loadKingAnim(
    String path,
    int amount, {
    bool loop = true,
  }) {
    return gameRef.loadSpriteAnimation(
      path,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.1,
        textureSize: Vector2(78, 58),
        loop: loop,
      ),
    );
  }

  // Places the player at the door spawn point.
  void spawnFromDoor() {
    opacity = 1;
    isEntering = true;
    animation = doorOutAnim;
    animationTicker?.reset();
    animationTicker?.onComplete = () {
      isEntering = false;
      animation = idleAnim;
      add(KingHealthBarThree());
    };
  }

  // Moves the player left or right.
  void move(int dir) {
    if (isDead || isEntering || isEnteringDoor) return;
    horizontalMovement = dir;
    if (dir != 0) {
      facingDirection = dir;
      scale.x = dir.toDouble();
    }
  }

  // Makes the player jump.
  void jump() {
    if (isGrounded && !isEntering && !isEnteringDoor && !isDead) {
      velocity.y = -jumpForce;
      isGrounded = false;
      AudioService.playSfx(AudioService.jump, volume: 0.75);
    }
  }

  // Restores some health.
  void heal(double amount) {
    if (isDead) return;
    health = (health + amount).clamp(0, maxHealth);
    AudioService.playSfx(AudioService.pickupCoin, volume: 0.85);
    AudioService.playSfx(AudioService.healthRecharge, volume: 0.95);
  }

  // Starts the attack action.
  void attack() {
    if (isAttacking || isEntering || isEnteringDoor || isDead) return;
    AudioService.playSfx(AudioService.kingAttack, volume: 0.78);
    isAttacking = true;
    isTakingHit = false;
    hasDealtDamage = false;

    if (isSuperPowered) {
      playerHitbox.size = Vector2(78, 64);
      playerHitbox.position = Vector2(27, 14);
    } else {
      playerHitbox.size = Vector2(50, 40);
      playerHitbox.position = Vector2(14, 10);
    }

    _tryDealHammerDamage();

    animation = attackAnim;
    animationTicker?.reset();
    animationTicker?.onComplete = () {
      isAttacking = false;
      hasDealtDamage = false;
      _resetHitbox();
    };
  }

  // Reduces health when this object gets hit.
  void takeDamage({double amount = 1}) {
    if (isDead || isInvulnerable || isEntering) return;
    health -= amount;
    if (health <= 0) {
      isDead = true;
      health = 0;
      deactivateSuperPower();
      isAttacking = false;
      hasDealtDamage = false;
      _resetHitbox();
      horizontalMovement = 0;
      velocity = Vector2.zero();
      animation = deadAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () => gameRef.onKingDead();
      if (animationTicker == null) {
        gameRef.onKingDead();
      }
    } else {
      isAttacking = false;
      hasDealtDamage = false;
      _resetHitbox();
      isInvulnerable = true;
      invulnerableTimer = 0;
      isTakingHit = true;
      animation = hitAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () {
        isTakingHit = false;
        if (!isDead && !isAttacking) animation = idleAnim;
      };
    }
  }

  // Resets reset hitbox.
  void _resetHitbox() {
    if (isSuperPowered) {
      playerHitbox.size = Vector2(42, 62);
      playerHitbox.position = Vector2(45, 16);
    } else {
      playerHitbox.size = Vector2(24, 40);
      playerHitbox.position = Vector2(27, 10);
    }
  }

  // Activates activate super power.
  void activateSuperPower() {
    if (isDead) return;
    isSuperPowered = true;
    superPowerRemaining = _superPowerDuration;
    AudioService.playSfx(AudioService.superPowerRise, volume: 0.9);
    jumpForce = _superJumpForce;
    size = _superSize.clone();
    _resetHitbox();
    gameRef.setSuperPowerSeconds(superPowerRemaining.ceil());
  }

  // Turns off deactivate super power.
  void deactivateSuperPower() {
    if (!isSuperPowered) return;
    isSuperPowered = false;
    superPowerRemaining = 0;
    jumpForce = _normalJumpForce;
    size = _normalSize.clone();
    _resetHitbox();
    gameRef.setSuperPowerSeconds(0);
  }

  // Handles try deal hammer damage.
  void _tryDealHammerDamage() {
    if (hasDealtDamage || !isAttacking) return;

    final facing = facingDirection.toDouble();
    final attackPoint = position + Vector2(facing * 42, -10);
    DamageablePig? target;
    double bestDistance = double.infinity;

    for (final pig in gameRef.children.whereType<DamageablePig>()) {
      if (pig.isDead) continue;
      final dx = pig.position.x - position.x;
      final inFront = facing > 0 ? dx >= -16 : dx <= 16;
      final distanceToAttackPoint = (pig.position - attackPoint).length;
      final inRange = distanceToAttackPoint <= 62;
      if (inFront && inRange && distanceToAttackPoint < bestDistance) {
        bestDistance = distanceToAttackPoint;
        target = pig;
      }
    }

    if (target != null) {
      hasDealtDamage = true;
      if (target is GiantPig && isSuperPowered) {
        target.takeDamage(amount: 2);
      } else {
        target.takeDamage();
      }
      if (target is CannonPig) {
        target.applyHammerKnockback(fromX: position.x);
      } else if (target is! BombingPig && target is! GiantPig) {
        target.position.x += (target.position.x < position.x) ? -15 : 15;
      }
    }
  }

  // Handles enter door.
  Future<void> enterDoor(EndDoorThree door) async {
    if (isDead || isEntering || isEnteringDoor) return;
    isEnteringDoor = true;
    horizontalMovement = 0;
    velocity = Vector2.zero();
    position.setValues(
      door.position.x,
      door.position.y + LevelThreeGame.kingDoorEntryYOffset,
    );
    await door.openAndTakeKing(this);
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    if (isDead) {
      super.update(dt);
      return;
    }

    if (isSuperPowered) {
      superPowerRemaining -= dt;
      if (superPowerRemaining <= 0) {
        deactivateSuperPower();
      } else {
        gameRef.setSuperPowerSeconds(superPowerRemaining.ceil());
      }
    }

    if (!isAttacking && playerHitbox.size.x > 30) {
      _resetHitbox();
    }

    if (isInvulnerable) {
      invulnerableTimer += dt;
      opacity = (invulnerableTimer * 10).toInt() % 2 == 0 ? 0.5 : 1.0;
      if (invulnerableTimer >= 1.0) {
        isInvulnerable = false;
        opacity = 1.0;
      }
    }

    super.update(dt);

    if (isEntering || isEnteringDoor) return;

    _progressSaveTimer += dt;
    if (_progressSaveTimer >= 2.0) {
      _progressSaveTimer = 0;
      LevelProgress.setLastKnownPosition(
        level: 3,
        x: position.x,
        y: position.y,
      );
    }

    if (isAttacking && animation != attackAnim) {
      isAttacking = false;
      hasDealtDamage = false;
      _resetHitbox();
    }

    if (isAttacking && !hasDealtDamage) {
      _tryDealHammerDamage();
    }

    if (!isAttacking && !isTakingHit) {
      animation = (horizontalMovement != 0) ? runAnim : idleAnim;
    }

    double nextX = position.x + (horizontalMovement * moveSpeed * dt);
    nextX = nextX.clamp(39, gameRef.mapWidth - 39);

    velocity.y += gravity * dt;
    double nextY = position.y + (velocity.y * dt);

    isGrounded = false;
    const double hitboxWidth = 24;
    const double hitboxHeight = 40;
    const double hitboxHalfWidth = hitboxWidth / 2;
    final double feetOffset =
        4 + LevelThreeGame.kingGroundOffset; // Move visual stand height.
    const double groundSnapTolerance = 2;

    double? snappedGroundTop;
    final currentFootY = position.y - feetOffset;
    final nextFootY = nextY - feetOffset;

    for (final rect in gameRef.groundRects) {
      final overlapsX =
          nextX + hitboxHalfWidth > rect.left &&
          nextX - hitboxHalfWidth < rect.right;
      if (!overlapsX) continue;

      final crossesTop =
          velocity.y >= 0 &&
          currentFootY <= rect.top + groundSnapTolerance &&
          nextFootY >= rect.top;
      final nearTop =
          velocity.y >= 0 &&
          (nextFootY - rect.top).abs() <= groundSnapTolerance;

      if (crossesTop || nearTop) {
        if (snappedGroundTop == null || rect.top < snappedGroundTop) {
          snappedGroundTop = rect.top;
        }
      }
    }

    if (snappedGroundTop != null) {
      nextY = snappedGroundTop + feetOffset;
      velocity.y = 0;
      isGrounded = true;
    }

    final hitTop = nextY - feetOffset - hitboxHeight + 1;
    final hitBottom = nextY - feetOffset - 1;

    for (final rect in gameRef.groundRects) {
      final overlapsY = hitBottom > rect.top && hitTop < rect.bottom;
      if (!overlapsY) continue;

      if (position.x < rect.left && nextX + hitboxHalfWidth > rect.left) {
        nextX = rect.left - hitboxHalfWidth;
      } else if (position.x > rect.right &&
          nextX - hitboxHalfWidth < rect.right) {
        nextX = rect.right + hitboxHalfWidth;
      }
    }

    position.setValues(nextX, nextY);

    if (!isDead && position.y > gameRef.mapHeight + 120) {
      isDead = true;
      gameRef.onKingDead();
    }
  }
}

// Game component for the door three object.
class DoorThree extends SpriteAnimationComponent
    with HasGameRef<LevelThreeGame> {
  final VoidCallback? onOpened;

  DoorThree({super.position, this.onOpened})
    : super(size: Vector2(46, 56), anchor: Anchor.bottomCenter);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      '11-Door/Opening (46x56).png',
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.1,
        textureSize: Vector2(46, 56),
        loop: false,
      ),
    );
    animationTicker?.onComplete = () {
      animationTicker?.paused = true;
      onOpened?.call();
    };
  }
}

// Game component for the end door three object.
class EndDoorThree extends SpriteAnimationComponent
    with HasGameRef<LevelThreeGame> {
  bool entering = false;
  late SpriteAnimation idleAnim;
  late SpriteAnimation openingAnim;

  EndDoorThree({super.position})
    : super(size: Vector2(46, 56), anchor: Anchor.bottomCenter, priority: 5);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    idleAnim = await _loadDoorAnim('11-Door/Idle.png', 1);
    openingAnim = await _loadDoorAnim(
      '11-Door/Opening (46x56).png',
      5,
      loop: false,
    );
    animation = idleAnim;
  }

  // Loads load door anim.
  Future<SpriteAnimation> _loadDoorAnim(
    String path,
    int amount, {
    bool loop = true,
  }) {
    return gameRef.loadSpriteAnimation(
      path,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.1,
        textureSize: Vector2(46, 56),
        loop: loop,
      ),
    );
  }

  // Opens and take king.
  Future<void> openAndTakeKing(PlayerThree king) async {
    if (entering) return;
    entering = true;

    animation = openingAnim;
    animationTicker?.reset();
    animationTicker?.onComplete = () => animationTicker?.paused = true;
    if (animationTicker != null) {
      await animationTicker!.completed;
    }

    king.animation = king.doorInAnim;
    king.animationTicker?.reset();
    if (king.animationTicker != null) {
      await king.animationTicker!.completed;
    }

    king.removeFromParent();
    gameRef.showVictory();
  }
}

abstract class DamageablePig {
  bool get isDead;
  Vector2 get position;
  // Reduces health when this object gets hit.
  void takeDamage({double amount = 1});
}

// Game component for the super power pickup object.
class SuperPowerPickup extends SpriteComponent
    with HasGameRef<LevelThreeGame>, CollisionCallbacks {
  bool consumed = false;
  double _blinkTimer = 0;

  SuperPowerPickup({super.position})
    : super(size: Vector2(34, 34), anchor: Anchor.bottomCenter, priority: 9);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('super power.png');
    add(RectangleHitbox());
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    if (consumed || gameRef.shouldFreezeEnemies) return;
    _blinkTimer += dt;
    opacity = ((_blinkTimer * 6).toInt() % 2 == 0) ? 1.0 : 0.35;
  }

  @override
  // Handles on collision start.
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (consumed) return;
    if (other is PlayerThree) {
      consumed = true;
      AudioService.playSfx(AudioService.pickupCoin, volume: 0.9);
      other.activateSuperPower();
      removeFromParent();
    }
  }
}

// Game component for the heart pickup three object.
class HeartPickupThree extends SpriteComponent
    with HasGameRef<LevelThreeGame>, CollisionCallbacks {
  bool consumed = false;
  double pulseTimer = 0;
  double blinkTimer = 0;

  HeartPickupThree({super.position})
    : super(size: Vector2(22, 22), anchor: Anchor.bottomCenter, priority: 8);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('heart.png');
    add(CircleHitbox(radius: 10));
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    pulseTimer += dt;
    blinkTimer += dt;
    final pulse = 0.9 + 0.18 * ((sin(pulseTimer * 4) + 1) / 2);
    scale = Vector2.all(pulse);
    opacity = 0.6 + 0.4 * ((sin(blinkTimer * 7) + 1) / 2);
  }

  @override
  // Handles on collision start.
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (consumed) return;
    if (other is PlayerThree) {
      if (other.health >= other.maxHealth) {
        gameRef.showLevelHint('King health is full');
        return;
      }
      consumed = true;
      other.heal(1);
      removeFromParent();
    }
  }
}

// Game component for the box pig object.
class BoxPig extends SpriteAnimationComponent
    with HasGameRef<LevelThreeGame>, CollisionCallbacks
    implements DamageablePig {
  bool triggered = false;
  int health = GameSettings.pigHealthInt(6);
  final int maxHealth = GameSettings.pigHealthInt(6);
  @override
  bool isDead = false;
  late SpriteAnimation deadAnim;
  late SpriteAnimation hitAnim;

  BoxPig({super.position})
    : super(size: Vector2(26, 20), anchor: Anchor.bottomCenter, priority: 10);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    add(RectangleHitbox());
    add(PigHealthBarThree(getHealth: () => health, maxHealth: maxHealth));
    hitAnim = await _loadPigAnim('03-Pig/Hit (34x28).png', 2, loop: false);
    deadAnim = await _loadPigAnim('03-Pig/Dead (34x28).png', 4, loop: false);
    animation = await gameRef.loadSpriteAnimation(
      '06-Pig Hide in the Box/Looking Out (26x20).png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2(26, 20),
      ),
    );
  }

  // Loads load pig anim.
  Future<SpriteAnimation> _loadPigAnim(
    String path,
    int amount, {
    bool loop = true,
  }) {
    return gameRef.loadSpriteAnimation(
      path,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.1,
        textureSize: Vector2(34, 28),
        loop: loop,
      ),
    );
  }

  @override
  // Reduces health when this object gets hit.
  void takeDamage({double amount = 1}) {
    if (isDead) return;
    health -= amount.round().clamp(1, 999);
    if (health <= 0) {
      isDead = true;
      gameRef.registerPigKill();
      _break();
    } else {
      animation = hitAnim;
      animationTicker?.reset();
    }
  }

  @override
  // Handles on collision.
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is PlayerThree &&
        other.isAttacking &&
        !other.hasDealtDamage &&
        !isDead) {
      other.hasDealtDamage = true;
      takeDamage();
      position.x += (position.x < other.position.x) ? -15 : 15;
    }
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    if (gameRef.shouldFreezeEnemies) return;
    if (isDead) return;
    if (!triggered && (gameRef.player.position - position).length < 120) {
      triggered = true;
      _break();
    }
  }

  // Handles break.
  void _break() async {
    if (isDead) {
      animation = deadAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () => removeFromParent();
      if (animationTicker == null) removeFromParent();
      return;
    }

    animation = await gameRef.loadSpriteAnimation(
      '06-Pig Hide in the Box/Jump Anticipation (26x20).png',
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(26, 20),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 300));

    for (int i = 1; i <= 4; i++) {
      gameRef.world.add(
        BoxPiece(
          position: position.clone(),
          index: i,
          velocity: Vector2((Random().nextDouble() - 0.5) * 200, -250),
        ),
      );
    }

    gameRef.world.add(AttackingPig(position: position.clone()));
    removeFromParent();
  }
}

// Game component for the box piece object.
class BoxPiece extends SpriteComponent with HasGameRef<LevelThreeGame> {
  Vector2 velocity;
  final int index;

  BoxPiece({
    required super.position,
    required this.index,
    required this.velocity,
  }) : super(size: Vector2(10, 10), anchor: Anchor.center);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('08-Box/Box Pieces $index.png');
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    velocity.y += 800 * dt;
    position += velocity * dt;
    if (position.y > gameRef.size.y + 500) removeFromParent();
  }
}

// Game component for the attacking pig object.
class AttackingPig extends SpriteAnimationComponent
    with HasGameRef<LevelThreeGame>, CollisionCallbacks
    implements DamageablePig {
  int health = GameSettings.pigHealthInt(6);
  final int maxHealth = GameSettings.pigHealthInt(6);
  @override
  bool isDead = false;
  bool isTakingHit = false;

  late SpriteAnimation deadAnim;
  late SpriteAnimation hitAnim;
  late SpriteAnimation idleAnim;
  late SpriteAnimation runAnim;
  late SpriteAnimation jumpAnim;
  late SpriteAnimation attackAnim;

  double speed = 90;
  double gravity = 1100;
  Vector2 velocity = Vector2(0, -250);

  AttackingPig({super.position})
    : super(size: Vector2(34, 28), anchor: Anchor.bottomCenter, priority: 10);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    add(RectangleHitbox());
    add(PigHealthBarThree(getHealth: () => health, maxHealth: maxHealth));

    hitAnim = await _loadPigAnim('03-Pig/Hit (34x28).png', 2, loop: false);
    deadAnim = await _loadPigAnim('03-Pig/Dead (34x28).png', 4, loop: false);
    idleAnim = await _loadPigAnim('03-Pig/Idle (34x28).png', 11);
    runAnim = await _loadPigAnim('03-Pig/Run (34x28).png', 6);
    jumpAnim = await _loadPigAnim('03-Pig/Jump (34x28).png', 1);
    attackAnim = await _loadPigAnim(
      '03-Pig/Attack (34x28).png',
      5,
      loop: false,
    );
    animation = jumpAnim;
  }

  // Loads load pig anim.
  Future<SpriteAnimation> _loadPigAnim(
    String path,
    int amount, {
    bool loop = true,
  }) {
    return gameRef.loadSpriteAnimation(
      path,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.1,
        textureSize: Vector2(34, 28),
        loop: loop,
      ),
    );
  }

  @override
  // Reduces health when this object gets hit.
  void takeDamage({double amount = 1}) {
    if (isDead) return;
    health -= amount.round().clamp(1, 999);
    if (health <= 0) {
      isDead = true;
      gameRef.registerPigKill();
      animation = deadAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () => removeFromParent();
      if (animationTicker == null) removeFromParent();
    } else {
      isTakingHit = true;
      animation = hitAnim;
      animationTicker?.reset();
      Future.delayed(const Duration(milliseconds: 220), () {
        if (!isDead) {
          isTakingHit = false;
        }
      });
    }
  }

  @override
  // Handles on collision.
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is PlayerThree &&
        other.isAttacking &&
        !other.hasDealtDamage &&
        !isDead) {
      other.hasDealtDamage = true;
      takeDamage();
      position.x += (position.x < other.position.x) ? -6 : 6;
    }
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    if (gameRef.shouldFreezeEnemies) return;
    if (isDead) return;

    final dist = (gameRef.player.position - position).length;
    final dir = gameRef.player.position.x < position.x ? -1.0 : 1.0;
    double moveX = 0;

    if (dist < 45 && animation != attackAnim && !isTakingHit) {
      animation = attackAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () {
        if (!gameRef.shouldFreezeEnemies &&
            !gameRef.player.isDead &&
            (gameRef.player.position - position).length < 50) {
          gameRef.player.takeDamage();
        }
        if (!isDead && !isTakingHit) {
          animation = idleAnim;
        }
      };
    } else if (dist < 180 && animation != attackAnim && !isTakingHit) {
      animation = runAnim;
      moveX = dir * speed;
      scale.x = -dir;
    } else if (dist >= 180 && animation != attackAnim && !isTakingHit) {
      animation = idleAnim;
    }

    velocity.y += gravity * dt;
    double nextX = position.x + (moveX * dt);
    double nextY = position.y + (velocity.y * dt);

    const double halfWidth = 11;
    double? snappedGroundTop;
    for (final rect in gameRef.groundRects) {
      final overlapsX =
          nextX + halfWidth > rect.left && nextX - halfWidth < rect.right;
      if (!overlapsX) continue;

      final wasAboveTop = position.y <= rect.top + 8;
      final crossesTop = nextY >= rect.top;
      final nearTopSeam = (nextY - rect.top).abs() <= 4;

      if (velocity.y >= 0 && ((wasAboveTop && crossesTop) || nearTopSeam)) {
        if (snappedGroundTop == null || rect.top < snappedGroundTop) {
          snappedGroundTop = rect.top;
        }
      }
    }

    if (snappedGroundTop != null) {
      nextY = snappedGroundTop;
      velocity.y = 0;
    }

    final isGrounded = snappedGroundTop != null;
    if (moveX != 0 && isGrounded) {
      final movingRight = moveX > 0;
      const double wallProbe = 11;
      bool wallAhead = false;

      for (final rect in gameRef.groundRects) {
        final withinBodyHeight =
            position.y > rect.top + 2 && position.y - 16 < rect.bottom;
        if (!withinBodyHeight) continue;

        if (movingRight) {
          final crossingLeftWall =
              position.x < rect.left && nextX + wallProbe >= rect.left;
          if (crossingLeftWall) {
            wallAhead = true;
            nextX = rect.left - wallProbe;
            break;
          }
        } else {
          final crossingRightWall =
              position.x > rect.right && nextX - wallProbe <= rect.right;
          if (crossingRightWall) {
            wallAhead = true;
            nextX = rect.right + wallProbe;
            break;
          }
        }
      }

      if (wallAhead) {
        velocity.y = -320;
        animation = jumpAnim;
      }
    }

    position.setValues(nextX, nextY);
  }
}

// States used by the cannon side logic.
enum CannonSide { left, right }

// Game component for the cannon object.
class Cannon extends SpriteAnimationComponent with HasGameRef<LevelThreeGame> {
  final CannonSide side;
  int get facingDirection => side == CannonSide.left ? -1 : 1;

  // Far detection zone (bigger than before).
  double zoneRangeX = 900;
  double zoneRangeY = 260;

  Cannon({super.position, required this.side})
    : super(size: Vector2(44, 28), anchor: Anchor.bottomCenter, priority: 12);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      '10-Cannon/Idle.png',
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2(44, 28),
      ),
    );
    // Cannon sprite faces left by default.
    scale.x = side == CannonSide.right ? -1 : 1;
  }

  // Checks whether is target in zone.
  bool isTargetInZone() {
    final dx = gameRef.player.position.x - position.x;
    final absDx = dx.abs();
    final dy = (gameRef.player.position.y - position.y).abs();
    final inHorizontalSide = side == CannonSide.left ? dx < 0 : dx > 0;
    return inHorizontalSide && absDx <= zoneRangeX && dy <= zoneRangeY;
  }

  // Fires the current projectile.
  Future<void> fire() async {
    if (gameRef.shouldFreezeEnemies) return;
    if (!isTargetInZone()) return;

    animation = await gameRef.loadSpriteAnimation(
      '10-Cannon/Shoot (44x28).png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(44, 28),
        loop: false,
      ),
    );

    final randomXSpeed = 220 + Random().nextDouble() * 90;
    final randomYSpeed = -(150 + Random().nextDouble() * 120);
    final launchOffset = Vector2(facingDirection * 10, -15);
    final launchVelocity = Vector2(
      facingDirection * randomXSpeed,
      randomYSpeed,
    );
    gameRef.world.add(
      CannonBall(position: position + launchOffset, velocity: launchVelocity),
    );

    animationTicker?.onComplete = () async {
      animation = await gameRef.loadSpriteAnimation(
        '10-Cannon/Idle.png',
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 1,
          textureSize: Vector2(44, 28),
        ),
      );
      scale.x = side == CannonSide.right ? -1 : 1;
    };
  }
}

// Game component for the cannon ball object.
class CannonBall extends SpriteAnimationComponent
    with HasGameRef<LevelThreeGame>, CollisionCallbacks {
  Vector2 velocity;
  bool exploding = false;
  double timer = 0;

  CannonBall({required super.position, required this.velocity})
    : super(size: Vector2(44, 28), anchor: Anchor.center);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      '10-Cannon/Cannon Ball.png',
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2(44, 28),
      ),
    );
    add(CircleHitbox(radius: 8));
  }

  @override
  // Handles on collision start.
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (gameRef.shouldFreezeEnemies) return;
    if (other is PlayerThree) {
      other.takeDamage();
      explode();
    }
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    if (gameRef.shouldFreezeEnemies) {
      if (!exploding) {
        removeFromParent();
      }
      return;
    }
    if (exploding) return;

    timer += dt;
    velocity.y += 600 * dt;
    position += velocity * dt;

    if (timer > 0.2) {
      for (final r in gameRef.groundRects) {
        if (r.contains(position.toOffset())) {
          explode();
          break;
        }
      }
    }
  }

  // Handles explode.
  void explode() async {
    if (exploding) return;
    exploding = true;
    velocity = Vector2.zero();
    animation = await gameRef.loadSpriteAnimation(
      '09-Bomb/Boooooom (52x56).png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.08,
        textureSize: Vector2(52, 56),
        loop: false,
      ),
    );
    size = Vector2(52, 56);
    animationTicker?.onComplete = () => removeFromParent();
  }
}

// Game component for the bombing pig object.
class BombingPig extends SpriteAnimationComponent
    with HasGameRef<LevelThreeGame>, CollisionCallbacks
    implements DamageablePig {
  bool throwing = false;
  bool isTakingHit = false;
  int throwSequenceId = 0;
  int health = GameSettings.pigHealthInt(6);
  final int maxHealth = GameSettings.pigHealthInt(6);
  @override
  bool isDead = false;
  late SpriteAnimation deadAnim;
  late SpriteAnimation hitAnim;

  BombingPig({super.position})
    : super(size: Vector2(26, 26), anchor: Anchor.bottomCenter, priority: 10);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    add(RectangleHitbox());
    add(PigHealthBarThree(getHealth: () => health, maxHealth: maxHealth));
    hitAnim = await _loadPigAnim('03-Pig/Hit (34x28).png', 2, loop: false);
    deadAnim = await _loadPigAnim('03-Pig/Dead (34x28).png', 4, loop: false);
    animation = await gameRef.loadSpriteAnimation(
      '05-Pig Thowing a Bomb/Idle (26x26).png',
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.1,
        textureSize: Vector2(26, 26),
      ),
    );
  }

  // Loads load pig anim.
  Future<SpriteAnimation> _loadPigAnim(
    String path,
    int amount, {
    bool loop = true,
  }) {
    return gameRef.loadSpriteAnimation(
      path,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.1,
        textureSize: Vector2(34, 28),
        loop: loop,
      ),
    );
  }

  @override
  // Reduces health when this object gets hit.
  void takeDamage({double amount = 1}) {
    if (isDead) return;
    throwSequenceId++;
    throwing = false;
    health -= amount.round().clamp(1, 999);
    if (health <= 0) {
      isDead = true;
      gameRef.registerPigKill();
      animation = deadAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () => removeFromParent();
      if (animationTicker == null) removeFromParent();
    } else {
      isTakingHit = true;
      animation = hitAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () async {
        if (isDead) return;
        isTakingHit = false;
        animation = await gameRef.loadSpriteAnimation(
          '05-Pig Thowing a Bomb/Idle (26x26).png',
          SpriteAnimationData.sequenced(
            amount: 10,
            stepTime: 0.1,
            textureSize: Vector2(26, 26),
          ),
        );
      };
    }
  }

  @override
  // Handles on collision.
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is PlayerThree &&
        other.isAttacking &&
        !other.hasDealtDamage &&
        !isDead) {
      other.hasDealtDamage = true;
      takeDamage();
    }
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    if (gameRef.shouldFreezeEnemies) return;
    if (isDead) return;
    if (isTakingHit) return;
    if ((gameRef.player.position - position).length < 300 && !throwing) {
      _throwBomb();
    }
    scale.x = gameRef.player.position.x < position.x ? 1 : -1;
  }

  // Handles throw bomb.
  Future<void> _throwBomb() async {
    if (isDead || gameRef.shouldFreezeEnemies || isTakingHit) return;
    throwing = true;
    final mySequence = ++throwSequenceId;

    animation = await gameRef.loadSpriteAnimation(
      '05-Pig Thowing a Bomb/Picking Bomb (26x26).png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(26, 26),
        loop: false,
      ),
    );
    await animationTicker?.completed;
    if (isDead ||
        gameRef.shouldFreezeEnemies ||
        isTakingHit ||
        mySequence != throwSequenceId) {
      throwing = false;
      return;
    }

    animation = await gameRef.loadSpriteAnimation(
      '05-Pig Thowing a Bomb/Throwing Boom (26x26).png',
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.1,
        textureSize: Vector2(26, 26),
        loop: false,
      ),
    );
    final direction = gameRef.player.position.x < position.x ? -1.0 : 1.0;
    gameRef.world.add(
      ThrownBomb(
        position: position + Vector2(direction * 15, -25),
        velocity: Vector2(direction * 220, -280),
      ),
    );
    await animationTicker?.completed;
    if (isDead ||
        gameRef.shouldFreezeEnemies ||
        isTakingHit ||
        mySequence != throwSequenceId) {
      throwing = false;
      return;
    }

    animation = await gameRef.loadSpriteAnimation(
      '05-Pig Thowing a Bomb/Idle (26x26).png',
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.1,
        textureSize: Vector2(26, 26),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mySequence != throwSequenceId ||
        isDead ||
        gameRef.shouldFreezeEnemies ||
        isTakingHit) {
      throwing = false;
      return;
    }
    throwing = false;
  }
}

// Class for the thrown bomb feature.
class ThrownBomb extends CannonBall {
  ThrownBomb({required super.position, required super.velocity});

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      '09-Bomb/Bomb On (52x56).png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(52, 56),
      ),
    );
  }
}

// Game component for the giant pig object.
class GiantPig extends SpriteAnimationComponent
    with HasGameRef<LevelThreeGame>, CollisionCallbacks
    implements DamageablePig {
  double health = GameSettings.pigHealthDouble(10);
  final double maxHealth = GameSettings.pigHealthDouble(10);
  @override
  bool isDead = false;
  bool isTakingHit = false;

  late SpriteAnimation deadAnim;
  late SpriteAnimation hitAnim;
  late SpriteAnimation idleAnim;
  late SpriteAnimation runAnim;
  late SpriteAnimation jumpAnim;
  late SpriteAnimation attackAnim;

  double speed = 72;
  double gravity = 1100;
  Vector2 velocity = Vector2(0, -240);

  GiantPig({super.position})
    : super(size: Vector2(96, 72), anchor: Anchor.bottomCenter, priority: 12);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    add(RectangleHitbox(size: Vector2(36, 52), position: Vector2(30, 16)));
    add(PigHealthBarThree(getHealth: () => health, maxHealth: maxHealth));
    hitAnim = await _loadPigAnim('03-Pig/Hit (34x28).png', 2, loop: false);
    deadAnim = await _loadPigAnim('03-Pig/Dead (34x28).png', 4, loop: false);
    idleAnim = await _loadPigAnim('03-Pig/Idle (34x28).png', 11);
    runAnim = await _loadPigAnim('03-Pig/Run (34x28).png', 6);
    jumpAnim = await _loadPigAnim('03-Pig/Jump (34x28).png', 1);
    attackAnim = await _loadPigAnim(
      '03-Pig/Attack (34x28).png',
      5,
      loop: false,
    );
    animation = jumpAnim;
  }

  // Loads load pig anim.
  Future<SpriteAnimation> _loadPigAnim(
    String path,
    int amount, {
    bool loop = true,
  }) {
    return gameRef.loadSpriteAnimation(
      path,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.1,
        textureSize: Vector2(34, 28),
        loop: loop,
      ),
    );
  }

  @override
  // Reduces health when this object gets hit.
  void takeDamage({double amount = 1}) {
    if (isDead) return;
    health -= amount;
    if (health <= 0) {
      health = 0;
      isDead = true;
      gameRef.registerPigKill();
      animation = deadAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () => removeFromParent();
      if (animationTicker == null) removeFromParent();
    } else {
      isTakingHit = true;
      animation = hitAnim;
      animationTicker?.reset();
      Future.delayed(const Duration(milliseconds: 260), () {
        if (!isDead) {
          isTakingHit = false;
        }
      });
    }
  }

  @override
  // Handles on collision.
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is PlayerThree &&
        other.isAttacking &&
        !other.hasDealtDamage &&
        !isDead) {
      other.hasDealtDamage = true;
      takeDamage(amount: other.isSuperPowered ? 2 : 1);
    }
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    if (gameRef.shouldFreezeEnemies) return;
    if (isDead) return;

    final dist = (gameRef.player.position - position).length;
    final dir = gameRef.player.position.x < position.x ? -1.0 : 1.0;
    double moveX = 0;

    if (dist < 70 && animation != attackAnim && !isTakingHit) {
      animation = attackAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () {
        if (!gameRef.shouldFreezeEnemies &&
            !gameRef.player.isDead &&
            (gameRef.player.position - position).length < 76) {
          gameRef.player.takeDamage(
            amount: gameRef.player.isSuperPowered ? 0.5 : 2,
          );
        }
        if (!isDead && !isTakingHit) {
          animation = idleAnim;
        }
      };
    } else if (dist < 260 && animation != attackAnim && !isTakingHit) {
      animation = runAnim;
      moveX = dir * speed;
      scale.x = -dir;
    } else if (dist >= 260 && animation != attackAnim && !isTakingHit) {
      animation = idleAnim;
    }

    velocity.y += gravity * dt;
    double nextX = position.x + (moveX * dt);
    double nextY = position.y + (velocity.y * dt);

    const double halfWidth = 18;
    double? snappedGroundTop;
    for (final rect in gameRef.groundRects) {
      final overlapsX =
          nextX + halfWidth > rect.left && nextX - halfWidth < rect.right;
      if (!overlapsX) continue;

      final wasAboveTop = position.y <= rect.top + 8;
      final crossesTop = nextY >= rect.top;
      final nearTopSeam = (nextY - rect.top).abs() <= 4;

      if (velocity.y >= 0 && ((wasAboveTop && crossesTop) || nearTopSeam)) {
        if (snappedGroundTop == null || rect.top < snappedGroundTop) {
          snappedGroundTop = rect.top;
        }
      }
    }

    if (snappedGroundTop != null) {
      nextY = snappedGroundTop;
      velocity.y = 0;
    }

    final isGrounded = snappedGroundTop != null;
    if (moveX != 0 && isGrounded) {
      final movingRight = moveX > 0;
      const double wallProbe = 18;
      bool wallAhead = false;

      for (final rect in gameRef.groundRects) {
        final withinBodyHeight =
            position.y > rect.top + 2 && position.y - 26 < rect.bottom;
        if (!withinBodyHeight) continue;

        if (movingRight) {
          final crossingLeftWall =
              position.x < rect.left && nextX + wallProbe >= rect.left;
          if (crossingLeftWall) {
            wallAhead = true;
            nextX = rect.left - wallProbe;
            break;
          }
        } else {
          final crossingRightWall =
              position.x > rect.right && nextX - wallProbe <= rect.right;
          if (crossingRightWall) {
            wallAhead = true;
            nextX = rect.right + wallProbe;
            break;
          }
        }
      }

      if (wallAhead) {
        velocity.y = -360;
        animation = jumpAnim;
      }
    }

    position.setValues(nextX, nextY);
  }
}

// Game component for the cannon pig object.
class CannonPig extends SpriteAnimationComponent
    with HasGameRef<LevelThreeGame>, CollisionCallbacks
    implements DamageablePig {
  final Cannon cannon;
  int health = GameSettings.pigHealthInt(6);
  final int maxHealth = GameSettings.pigHealthInt(6);
  @override
  bool isDead = false;
  bool isTakingHit = false;
  double knockbackVelocityX = 0;
  double knockbackTimer = 0;
  late SpriteAnimation deadAnim;
  late SpriteAnimation hitAnim;

  CannonPig({super.position, required this.cannon})
    : super(size: Vector2(26, 18), anchor: Anchor.bottomCenter, priority: 13);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    _syncFacingWithCannon();
    add(RectangleHitbox());
    add(PigHealthBarThree(getHealth: () => health, maxHealth: maxHealth));
    hitAnim = await _loadPigAnim('03-Pig/Hit (34x28).png', 2, loop: false);
    deadAnim = await _loadPigAnim('03-Pig/Dead (34x28).png', 4, loop: false);
    _loopIgniteAndFire();
  }

  // Handles sync facing with cannon.
  void _syncFacingWithCannon() {
    // Match cannon side permanently: left side faces left, right side faces right.
    scale.x = cannon.side == CannonSide.left ? 1 : -1;
  }

  // Loads load pig anim.
  Future<SpriteAnimation> _loadPigAnim(
    String path,
    int amount, {
    bool loop = true,
  }) {
    return gameRef.loadSpriteAnimation(
      path,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.1,
        textureSize: Vector2(34, 28),
        loop: loop,
      ),
    );
  }

  // Handles loop ignite and fire.
  Future<void> _loopIgniteAndFire() async {
    _syncFacingWithCannon();

    if (isDead || gameRef.shouldFreezeEnemies || isTakingHit) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!isDead && !gameRef.shouldFreezeEnemies) {
        _loopIgniteAndFire();
      }
      return;
    }

    if (!cannon.isTargetInZone()) {
      animation = await gameRef.loadSpriteAnimation(
        '07-Pig With a Match/Match On (26x18).png',
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.2,
          textureSize: Vector2(26, 18),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 350));
      _loopIgniteAndFire();
      return;
    }

    animation = await gameRef.loadSpriteAnimation(
      '07-Pig With a Match/Lighting the Match (26x18).png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: Vector2(26, 18),
        loop: false,
      ),
    );
    await animationTicker?.completed;
    if (isDead || gameRef.shouldFreezeEnemies || isTakingHit) {
      _loopIgniteAndFire();
      return;
    }

    animation = await gameRef.loadSpriteAnimation(
      '07-Pig With a Match/Match On (26x18).png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: Vector2(26, 18),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (isDead || gameRef.shouldFreezeEnemies || isTakingHit) {
      _loopIgniteAndFire();
      return;
    }

    animation = await gameRef.loadSpriteAnimation(
      '07-Pig With a Match/Lighting the Cannon (26x18).png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.1,
        textureSize: Vector2(26, 18),
        loop: false,
      ),
    );
    await animationTicker?.completed;
    if (isDead || gameRef.shouldFreezeEnemies || isTakingHit) {
      _loopIgniteAndFire();
      return;
    }

    await cannon.fire();
    await Future.delayed(const Duration(seconds: 3));
    _loopIgniteAndFire();
  }

  @override
  // Reduces health when this object gets hit.
  void takeDamage({double amount = 1}) {
    if (isDead) return;
    health -= amount.round().clamp(1, 999);
    if (health <= 0) {
      isDead = true;
      gameRef.registerPigKill();
      animation = deadAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () => removeFromParent();
      if (animationTicker == null) removeFromParent();
    } else {
      isTakingHit = true;
      animation = hitAnim;
      animationTicker?.reset();
      Future.delayed(const Duration(milliseconds: 220), () {
        if (!isDead) {
          isTakingHit = false;
        }
      });
    }
  }

  // Applies apply hammer knockback.
  void applyHammerKnockback({required double fromX}) {
    final dir = position.x < fromX ? -1.0 : 1.0;
    knockbackVelocityX = dir * 220;
    knockbackTimer = 0.16;
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);

    if (knockbackTimer > 0 && !isDead) {
      final proposedX = position.x + (knockbackVelocityX * dt);
      position.x = proposedX.clamp(20, gameRef.mapWidth - 20);
      knockbackVelocityX *= 0.86;
      knockbackTimer -= dt;
      if (knockbackTimer <= 0) {
        knockbackVelocityX = 0;
      }
    }
  }

  @override
  // Handles on collision.
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is PlayerThree &&
        other.isAttacking &&
        !other.hasDealtDamage &&
        !isDead) {
      other.hasDealtDamage = true;
      takeDamage();
      applyHammerKnockback(fromX: other.position.x);
    }
  }
}

// Game component for the king health bar three object.
class KingHealthBarThree extends PositionComponent with ParentIsA<PlayerThree> {
  KingHealthBarThree()
    : super(size: Vector2(46, 8), position: Vector2(-23, -64));

  double _blinkTimer = 0;

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    _blinkTimer += dt;
  }

  @override
  // Draws this object on the canvas.
  void render(Canvas canvas) {
    final healthPercentage = (parent.health / parent.maxHealth).clamp(0, 1);
    final bool lowHealth = healthPercentage > 0 && healthPercentage <= 0.35;
    final bool blinkOn = ((_blinkTimer * 6).toInt() % 2 == 0);

    final RRect outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(999),
    );

    if (healthPercentage > 0) {
      final double inset = 1;
      final double innerHeight = size.y - (inset * 2);
      final double fillWidth = (size.x - (inset * 2)) * healthPercentage;
      final Color fillColor = lowHealth
          ? (blinkOn ? const Color(0xFFFF5252) : const Color(0xFFFF8A80))
          : const Color(0xFF4CAF50);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(inset, inset, fillWidth, innerHeight),
          const Radius.circular(999),
        ),
        Paint()..color = fillColor,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(inset, inset, fillWidth, innerHeight * 0.45),
          const Radius.circular(999),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.12),
      );
    }

    canvas.drawRRect(
      outer,
      Paint()
        ..color = lowHealth && blinkOn
            ? Colors.redAccent
            : const Color(0xFF607D8B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }
}

// Game component for the pig health bar three object.
class PigHealthBarThree extends PositionComponent
    with ParentIsA<PositionComponent> {
  final num Function() getHealth;
  final num maxHealth;

  PigHealthBarThree({required this.getHealth, required this.maxHealth})
    : super(size: Vector2(30, 7), position: Vector2(-15, -38));

  double _blinkTimer = 0;

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    _blinkTimer += dt;
  }

  @override
  // Draws this object on the canvas.
  void render(Canvas canvas) {
    final healthPercentage = (getHealth() / maxHealth).toDouble().clamp(0, 1);
    final bool lowHealth = healthPercentage > 0 && healthPercentage <= 0.5;
    final bool blinkOn = ((_blinkTimer * 6).toInt() % 2 == 0);

    final RRect outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(999),
    );

    if (healthPercentage > 0) {
      final double inset = 1;
      final double innerHeight = size.y - (inset * 2);
      final double fillWidth = (size.x - (inset * 2)) * healthPercentage;
      final Color fillColor = lowHealth
          ? (blinkOn ? const Color(0xFFFF4D4D) : const Color(0xFFFF7A7A))
          : const Color(0xFF66BB6A);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(inset, inset, fillWidth, innerHeight),
          const Radius.circular(999),
        ),
        Paint()..color = fillColor,
      );
    }

    canvas.drawRRect(
      outer,
      Paint()
        ..color = lowHealth && blinkOn
            ? Colors.redAccent
            : const Color(0xFF546E7A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
