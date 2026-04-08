import 'dart:async' as async;
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart' hide Text;
import 'package:flutter/material.dart';
import 'package:flame/experimental.dart'; // This provides the Rectangle for Camera bounds
import 'audio_service.dart';
import 'game_settings.dart';
import 'level_progress.dart';
import 'sound_controls_panel.dart';

// States used by the player action logic.
enum PlayerAction { idle, walking, attacking, doorOut, doorIn, dead }

// States used by the pig state logic.
enum PigState { idle, walking, attacking, hit, dead }

// ... LevelOneScene and _LevelOneSceneState remain exactly as you have them ...

class LevelOneScene extends StatefulWidget {
  const LevelOneScene({super.key});
  @override
  // Creates the state object for this widget.
  State<LevelOneScene> createState() => _LevelOneSceneState();
}

// State for the level one scene widget.
class _LevelOneSceneState extends State<LevelOneScene> {
  late KingGame myGame;
  bool _showDifficultyBanner = true;
  bool _isTransitioning = false;
  async.Timer? _difficultyBannerTimer;

  // Level 1 only: tweak these to move the pig kill progress HUD.
  static const double _levelOneKillHudTop = 20;
  static const double _levelOneKillHudRight = 110;

  // Level 1 only: negative moves difficulty banner to the left.
  static const double _levelOneDifficultyBannerOffsetX = -20;

  @override
  // Sets up the state when this widget starts.
  void initState() {
    super.initState();
    myGame = KingGame();
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
    myGame.pauseEngine();
    super.dispose();
  }

  void _pauseGame() {
    AudioService.stopAllSfx();
    myGame.pauseEngine();
  }

  Future<void> _exitLevel() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _pauseGame();
    await GameSettings.playUiTapSound();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _restartLevel() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _pauseGame();
    await GameSettings.playUiTapSound();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LevelOneScene()),
    );
  }

  Future<void> _goToNextLevel() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _pauseGame();
    await GameSettings.playUiTapSound();
    if (!mounted) return;
    Navigator.of(context).pop(2);
  }

  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30), // Match your game's dark theme
      body: Stack(
        children: [
          // The Game Layer
          Positioned.fill(
            child: GameWidget(
              game: myGame,
              overlayBuilderMap: {
                'LevelHint': (context, KingGame game) => _buildLevelHint(game),
                'VictoryMenu': (context, KingGame game) {
                  return Center(
                    child: Container(
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
                            "VICTORY!",
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
                            "You killed the pigs! The King can now escape.",
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
                                  "REPLAY",
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
                                  "NEXT LEVEL",
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
                  );
                },
                'DefeatMenu': (context, KingGame game) {
                  return Center(
                    child: Container(
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
                            "PLAY AGAIN",
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
                            "The pigs took the crown this round. Rise, reload, and reclaim the kingdom.",
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
                                onPressed: () {
                                  game.overlays.remove('DefeatMenu');
                                  game.reset();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  "REPLAY",
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
                                  "BACK",
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
                  );
                },
              },
            ),
          ),
          Positioned(
            top: _levelOneKillHudTop,
            right: _levelOneKillHudRight,
            child: _buildPigKillHud(myGame),
          ),

          // THE UI LAYER: Using SafeArea for notch protection
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Stack(
                // Using Stack inside SafeArea to pin items to opposite corners
                children: [
                  if (_showDifficultyBanner)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Transform.translate(
                        offset: const Offset(
                          _levelOneDifficultyBannerOffsetX,
                          0,
                        ),
                        child: IgnorePointer(
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
                  Align(
                    alignment: Alignment.topLeft,
                    child: BackButton(
                      color: Colors.white,
                      onPressed: _exitLevel,
                    ),
                  ),
                  // 1. MOVEMENT (Bottom Left)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _btn(
                          Icons.arrow_back,
                          () => myGame.king.moveDirection = -1,
                          () => myGame.king.moveDirection = 0,
                        ),
                        const SizedBox(width: 20),
                        _btn(
                          Icons.arrow_forward,
                          () => myGame.king.moveDirection = 1,
                          () => myGame.king.moveDirection = 0,
                        ),
                      ],
                    ),
                  ),

                  // 3. OPTIONS (Top Right)
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTapDown: (_) => _showGameMenu(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _btn(
                          Icons.gavel,
                          () => myGame.king.startAttack(),
                          null,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 20),
                        _btn(
                          Icons.arrow_upward,
                          () => myGame.king.jump(),
                          null,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  // Builds build level hint.
  Widget _buildLevelHint(KingGame game) {
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
                return Container(
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Builds build pig kill hud.
  Widget _buildPigKillHud(KingGame game) {
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
                                'Ceasefire Command: hold the line or return to war.',
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
                                LevelProgress.clearCheckpointForLevel(1);
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

// Main game logic for the king game scene.
class KingGame extends FlameGame with HasCollisionDetection {
  late KingPlayer king;
  late TiledComponent mapComponent;
  double mapHeight = 0;
  int pigKills = 0;
  final int requiredPigKills = 2;
  final ValueNotifier<int> pigKillsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String?> levelHint = ValueNotifier<String?>(null);

  KingGame()
    : super(
        camera: CameraComponent.withFixedResolution(width: 640, height: 360)
          ..viewfinder.anchor = Anchor.center,
      );

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    camera.viewfinder.zoom = 1.2;
    debugMode = false;
    mapComponent = await TiledComponent.load('test_level.tmx', Vector2.all(32));
    add(mapComponent);

    final collisionLayer = mapComponent.tileMap.getLayer<ObjectGroup>(
      'collisions',
    );
    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        add(
          Platform(
            position: Vector2(collision.x, collision.y),
            size: Vector2(collision.width, collision.height),
          ),
        );
      }
    }

    final spawnPointsLayer = mapComponent.tileMap.getLayer<ObjectGroup>(
      'spawnpoints',
    );
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        if (spawnPoint.name == 'king') {
          king = KingPlayer()..position = Vector2(spawnPoint.x, spawnPoint.y);
          king.isHidden = true;
          king.currentAction = PlayerAction.doorOut;
          add(king);
        } else if (spawnPoint.name == 'startdoor') {
          add(StartDoor(position: Vector2(spawnPoint.x, spawnPoint.y)));
        } else if (spawnPoint.name == 'pig') {
          add(PigEnemy(position: Vector2(spawnPoint.x, spawnPoint.y)));
        } else if (spawnPoint.name == 'pig2') {
          add(BoxPig(position: Vector2(spawnPoint.x, spawnPoint.y)));
        } else if (spawnPoint.name == 'enddoor') {
          add(EndDoor(position: Vector2(spawnPoint.x, spawnPoint.y)));
        } else if (spawnPoint.name == 'heart') {
          add(HeartPickupOne(position: Vector2(spawnPoint.x, spawnPoint.y)));
        }
      }
    }

    // determine the size of the map in world pixels (tile count * tile size)
    final mapWidth = (mapComponent.tileMap.map.width * 32).toDouble();
    mapHeight = (mapComponent.tileMap.map.height * 32).toDouble();

    camera.viewfinder.anchor = Anchor.center;
    camera.follow(king);

    // now constrain the camera to the map bounds so it doesn't show void
    camera.setBounds(Rectangle.fromLTWH(0, 0, mapWidth, mapHeight));

    final useResume = LevelProgress.consumeResumeChoiceForLaunch(level: 1);
    final resume = LevelProgress.resumePositionForLevel(1);
    if (useResume && resume != null) {
      king.position.setValues(resume.x, resume.y);
      showLevelHint('Resumed from your last checkpoint.');
    }
    LevelProgress.setLastPlayedLevel(1);
  }

  // Shows show victory message.
  void showVictoryMessage() {
    LevelProgress.markCompleted(1);
    AudioService.playSfx(AudioService.kingDoorOut, volume: 0.95);
    overlays.add('VictoryMenu');
  }

  // Updates progress after a pig is defeated.
  void registerPigKill() {
    pigKills++;
    pigKillsNotifier.value = pigKills;
  }

  // Shows show defeat message.
  void showDefeatMessage() {
    AudioService.playSfx(AudioService.deathPop, volume: 0.9);
    AudioService.playSfx(AudioService.fail, volume: 1.0);
    overlays.add('DefeatMenu');
  }

  // Shows show level hint.
  void showLevelHint(
    String message, {
    Duration duration = const Duration(seconds: 2),
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

  // Resets reset.
  void reset() {
    overlays.remove('VictoryMenu');
    overlays.remove('DefeatMenu');
    pigKills = 0;
    pigKillsNotifier.value = 0;
    levelHint.value = null;
    removeAll(children);
    onLoad();
  }
}

// Game component for the king player object.
class KingPlayer extends SpriteAnimationComponent
    with HasGameReference<KingGame>, CollisionCallbacks {
  double moveDirection = 0;
  double speed = 200;
  PlayerAction currentAction = PlayerAction.idle;
  double attackTimer = 0;
  final double attackDuration = 0.3;
  int health = GameSettings.kingHealthInt(5);
  int maxHealth = GameSettings.kingHealthInt(5);
  double velocityY = 0;
  final double gravity = 1000;
  final double jumpForce = -450;
  bool isOnGround = false;
  bool isHidden = true;

  bool isInvulnerable = false;
  double invulnerableTimer = 0;
  final double invulnerableDuration = 1.0;
  double _progressSaveTimer = 0;

  late SpriteAnimation idleAnimation,
      runAnimation,
      attackAnimation,
      doorOutAnimation,
      doorInAnimation,
      deadAnimation;
  late RectangleHitbox hammerHitbox;

  KingPlayer() : super(anchor: Anchor.center);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    priority = 10;
    idleAnimation = await _loadAnim('01-King Human/Idle (78x58).png', 11);
    runAnimation = await _loadAnim('01-King Human/Run (78x58).png', 8);
    attackAnimation = await _loadAnim(
      '01-King Human/Attack (78x58).png',
      3,
      loop: false,
    );
    doorOutAnimation = await _loadAnim(
      '01-King Human/Door Out (78x58).png',
      8,
      loop: false,
    );
    doorInAnimation = await _loadAnim(
      '01-King Human/Door In (78x58).png',
      8,
      loop: false,
    );
    deadAnimation = await _loadAnim(
      '01-King Human/Dead (78x58).png',
      4,
      loop: false,
    );

    size = Vector2(78, 58);
    scale = Vector2.all(2.0);

    add(RectangleHitbox(size: Vector2(20, 28), position: Vector2(29, 22)));
    hammerHitbox = RectangleHitbox(size: Vector2(60, 60), anchor: Anchor.center)
      ..collisionType = CollisionType.active;
  }

  // Reduces health when this object gets hit.
  void takeDamage() {
    if (currentAction == PlayerAction.dead || isInvulnerable) return;

    health--;
    print("King Hit! Health: $health");

    if (health <= 0) {
      print("KING IS DYING...");

      // 1. Lock everything immediately
      currentAction = PlayerAction.dead;
      moveDirection = 0;
      velocityY = 0;

      // 2. Switch animation and FORCE the ticker to reset
      animation = deadAnimation;
      final ticker = animationTicker;

      if (ticker != null) {
        ticker.reset();
        ticker.completed.then((_) {
          print("Death Animation Finished");
          game.showDefeatMessage();
          // opacity = 0; // Optional: hide him instead of removing
        });
      } else {
        game.showDefeatMessage();
      }

      // 3. Remove hitboxes so no more collisions can happen
      children.whereType<ShapeHitbox>().forEach((h) => h.removeFromParent());
    } else {
      isInvulnerable = true;
      invulnerableTimer = 0;
      paint.color = Colors.red;
    }
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    if (isHidden ||
        currentAction == PlayerAction.dead ||
        currentAction == PlayerAction.doorOut ||
        currentAction == PlayerAction.doorIn) {
      animationTicker?.update(dt);
      return;
    }

    super.update(dt);

    if (isInvulnerable) {
      invulnerableTimer += dt;
      opacity = (invulnerableTimer * 10).toInt() % 2 == 0 ? 0.5 : 1.0;
      if (invulnerableTimer >= invulnerableDuration) {
        isInvulnerable = false;
        paint.color = Colors.white;
        opacity = 1.0;
      }
    }

    if (!isOnGround) velocityY += gravity * dt;
    position.y += velocityY * dt;

    if (currentAction == PlayerAction.attacking ||
        currentAction == PlayerAction.doorOut) {
      return;
    }

    // 1. BLOCK PASSAGE: Stop king from passing if pigs still exist
    bool anyPigsAlive = game.children.whereType<PigEnemy>().isNotEmpty;
    if (anyPigsAlive && position.x > 400) {
      position.x = 400;
    }

    // 2. CHECK FOR DOOR ENTRY: If no pigs left and King is near the EndDoor
    if (!anyPigsAlive) {
      final endDoors = game.children.whereType<EndDoor>().toList();
      if (endDoors.isNotEmpty) {
        final endDoor = endDoors.first;
        if ((position.x - endDoor.position.x).abs() < 10) {
          _enterDoor(endDoor);
          return; // Prevent further movement updates
        }
      }
    }

    if (moveDirection != 0) {
      animation = runAnimation;
      position.x += moveDirection * speed * dt;
      scale.x = moveDirection > 0 ? 2 : -2;
    } else {
      animation = idleAnimation;
    }

    isOnGround = false;

    final mapWidth = game.mapComponent.tileMap.map.width * 32;
    position.x = position.x.clamp(32, mapWidth - 32);

    _progressSaveTimer += dt;
    if (_progressSaveTimer >= 2.0) {
      _progressSaveTimer = 0;
      LevelProgress.setLastKnownPosition(
        level: 1,
        x: position.x,
        y: position.y,
      );
    }

    if (currentAction != PlayerAction.dead &&
        position.y > game.mapHeight + 120) {
      currentAction = PlayerAction.dead;
      game.showDefeatMessage();
    }
  }

  // Handles enter door.
  void _enterDoor(EndDoor door) {
    if (currentAction == PlayerAction.doorIn) return;

    currentAction = PlayerAction.doorIn;
    moveDirection = 0;
    velocityY = 0;

    // Start the animation sequence
    door.openAndTakeKing(this);
  }

  // Makes the player jump.
  void jump() {
    if (isOnGround &&
        currentAction != PlayerAction.doorOut &&
        currentAction != PlayerAction.dead) {
      velocityY = jumpForce;
      isOnGround = false;
      AudioService.playSfx(AudioService.jump, volume: 0.75);
    }
  }

  // Restores some health.
  void heal(int amount) {
    if (currentAction == PlayerAction.dead) return;
    health = (health + amount).clamp(0, maxHealth);
    AudioService.playSfx(AudioService.pickupCoin, volume: 0.85);
    AudioService.playSfx(AudioService.healthRecharge, volume: 0.95);
  }

  // Loads load anim.
  Future<SpriteAnimation> _loadAnim(
    String path,
    int amount, {
    bool loop = true,
  }) async {
    return await game.loadSpriteAnimation(
      path,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.1,
        textureSize: Vector2(78, 58),
        loop: loop,
      ),
    );
  }

  // Starts start attack.
  void startAttack() {
    if (currentAction != PlayerAction.attacking &&
        currentAction != PlayerAction.doorOut &&
        currentAction != PlayerAction.dead) {
      AudioService.playSfx(AudioService.kingAttack, volume: 0.78);
      currentAction = PlayerAction.attacking;
      animation = attackAnimation;
      animationTicker?.reset();
      hammerHitbox.position = Vector2(50, 0);
      add(hammerHitbox);
      animationTicker?.completed.then((_) {
        currentAction = PlayerAction.idle;
        if (hammerHitbox.isMounted) remove(hammerHitbox);
      });
    }
  }

  @override
  // Handles on collision.
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Platform) {
      final collisionArea =
          intersectionPoints.reduce((a, b) => a + b) /
          intersectionPoints.length.toDouble();

      if (collisionArea.y > position.y + (size.y / 4)) {
        if (velocityY >= 0) {
          isOnGround = true;
          velocityY = 0;
          position.y = other.y - (size.y / 2);
        }
      } else {
        if (position.x < other.x) {
          position.x = other.x - (size.x / 4);
        } else {
          position.x = other.x + other.size.x + (size.x / 4);
        }
      }
    }
  }
}

// Game component for the pig enemy object.
class PigEnemy extends SpriteAnimationComponent
    with HasGameReference<KingGame>, CollisionCallbacks {
  PigState state = PigState.idle;
  int health = GameSettings.pigHealthInt(2);
  double velocityY = 0;
  final double gravity = 1000;
  bool isOnGround = false;
  late SpriteAnimation idleAnim, hitAnim, deadAnim;

  PigEnemy({required Vector2 position})
    : super(position: position, size: Vector2(34, 28), anchor: Anchor.center);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    idleAnim = await _loadAnim('03-Pig/Idle (34x28).png', 11);
    hitAnim = await _loadAnim(
      '03-Pig/Hit (34x28).png',
      2,
      loop: false,
      step: 0.2,
    );
    deadAnim = await _loadAnim('03-Pig/Dead (34x28).png', 4, loop: false);
    animation = idleAnim;
    scale = Vector2.all(2.0);
    add(RectangleHitbox()..collisionType = CollisionType.active);
    add(HealthBar());
  }

  // Loads load anim.
  Future<SpriteAnimation> _loadAnim(
    String path,
    int amount, {
    bool loop = true,
    double step = 0.1,
  }) async {
    return await game.loadSpriteAnimation(
      path,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: step,
        textureSize: Vector2(34, 28),
        loop: loop,
      ),
    );
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    if (state == PigState.dead || state == PigState.hit) return;
    if (!isOnGround) velocityY += gravity * dt;
    position.y += velocityY * dt;
    isOnGround = false;
  }

  @override
  // Handles on collision.
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Platform && velocityY >= 0) {
      isOnGround = true;
      velocityY = 0;
      position.y = other.y - 23;
    }
  }

  @override
  // Handles on collision start.
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is KingPlayer && other.currentAction == PlayerAction.attacking) {
      takeDamage();
    }
  }

  // Reduces health when this object gets hit.
  void takeDamage() {
    if (state == PigState.dead) return;
    health--;
    if (health <= 0) {
      AudioService.playSfx(AudioService.deathPop, volume: 0.9);
      state = PigState.dead;
      game.registerPigKill();
      animation = deadAnim;
      animationTicker?.reset();
      animationTicker?.completed.then((_) => removeFromParent());
    } else {
      state = PigState.hit;
      animation = hitAnim;
      animationTicker?.reset();
      animationTicker?.completed.then((_) => state = PigState.idle);
    }
  }
}

// Class for the rage pig feature.
class RagePig extends PigEnemy {
  RagePig({required super.position});
  double chaseSpeed = 130;
  late SpriteAnimation runAnim, attackAnim;

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    await super.onLoad();
    runAnim = await _loadAnim('03-Pig/Run (34x28).png', 6);
    attackAnim = await _loadAnim('03-Pig/Attack (34x28).png', 5, loop: false);
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    if (!game.king.isMounted ||
        game.king.health <= 0 ||
        state == PigState.dead ||
        state == PigState.hit ||
        state == PigState.attacking) {
      return;
    }

    double dist = game.king.position.x - position.x;
    scale.x = dist > 0 ? -2 : 2;

    if (dist.abs() < 55) {
      startAttack();
    } else {
      state = PigState.walking;
      animation = runAnim;
      position.x += (dist > 0 ? 1 : -1) * chaseSpeed * dt;
    }
  }

  // Starts start attack.
  void startAttack() {
    if (state == PigState.attacking) return;
    state = PigState.attacking;
    animation = attackAnim;
    animationTicker?.reset();
    animationTicker?.completed.then((_) {
      if (game.king.isMounted &&
          game.king.health > 0 &&
          (game.king.position.x - position.x).abs() < 70) {
        game.king.takeDamage();
      }
      state = PigState.idle;
    });
  }
}

// Main widget for the movement button section.
class MovementButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTapDown, onTapUp;
  const MovementButton({
    super.key,
    required this.icon,
    required this.onTapDown,
    required this.onTapUp,
  });
  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapUp(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 40),
      ),
    );
  }
}

// Game component for the health bar object.
class HealthBar extends PositionComponent with ParentIsA<PigEnemy> {
  HealthBar() : super(size: Vector2(30, 7), position: Vector2(2, -12));

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
    final double healthPercentage =
        (parent.health / GameSettings.pigHealthInt(2)).clamp(0, 1);
    final bool lowHealth = healthPercentage > 0 && healthPercentage <= 0.5;
    final bool blinkOn = ((_blinkTimer * 6).toInt() % 2 == 0);
    final Color borderColor = lowHealth && blinkOn
        ? Colors.redAccent
        : const Color(0xFF37474F);

    final RRect outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(999),
    );

    final double inset = 1;
    final double innerHeight = size.y - (inset * 2);
    final double fillWidth = (size.x - (inset * 2)) * healthPercentage;
    if (fillWidth > 0) {
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
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}

// Game component for the king health bar object.
class KingHealthBar extends PositionComponent with ParentIsA<KingPlayer> {
  KingHealthBar() : super(size: Vector2(46, 8), position: Vector2(-23, -44));

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
    double healthPercentage = (parent.health / parent.maxHealth).clamp(0, 1);
    final bool lowHealth = healthPercentage > 0 && healthPercentage <= 0.35;
    final bool blinkOn = ((_blinkTimer * 6).toInt() % 2 == 0);
    final Color borderColor = lowHealth && blinkOn
        ? Colors.redAccent
        : const Color(0xFF455A64);

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

      // Subtle top highlight for depth.
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
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }
}

// Game component for the platform object.
class Platform extends PositionComponent with CollisionCallbacks {
  Platform({required Vector2 position, required Vector2 size})
    : super(position: position, size: size) {
    // This allows the King and Pigs to land on this object
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}

// Game component for the start door object.
class StartDoor extends SpriteAnimationComponent
    with HasGameReference<KingGame> {
  late SpriteAnimation idleAnim, openingAnim;

  StartDoor({required Vector2 position})
    : super(
        position: position,
        size: Vector2(46, 56),
        anchor: Anchor.bottomCenter,
      );

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    priority = 5; // Behind the king
    idleAnim = await game.loadSpriteAnimation(
      '11-Door/Idle.png',
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(46, 56),
      ),
    );
    openingAnim = await game.loadSpriteAnimation(
      '11-Door/Opening (46x56).png',
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.1,
        textureSize: Vector2(46, 56),
        loop: false,
      ),
    );

    animation = idleAnim;
    scale = Vector2.all(2.0);
    Future.delayed(const Duration(seconds: 1), startSequence);
  }

  // Starts start sequence.
  void startSequence() {
    animation = openingAnim;
    animationTicker?.reset();

    // Wait for door to be visually open enough
    Future.delayed(const Duration(milliseconds: 300), () {
      // Move king to the door's center position before showing him
      // Add offset to move right from the door center
      game.king.position.x = position.x + 10;

      game.king.isHidden = false;
      game.king.currentAction =
          PlayerAction.doorOut; // This triggers the Lock in update()
      game.king.animation = game.king.doorOutAnimation;

      // Ensure the King's animation starts at frame 0
      final ticker = game.king.animationTicker;
      ticker?.reset();

      ticker?.completed.then((_) {
        // Only transition to Idle if he didn't somehow die instantly
        if (game.king.currentAction == PlayerAction.doorOut) {
          game.king.currentAction = PlayerAction.idle;
          game.king.animation = game.king.idleAnimation;
          // Add health bar now that the king is visible and in idle mode
          game.king.add(KingHealthBar());
          debugPrint("Sequence Complete: King is now Idle");
        }
      });
    });
  }
}

// Game component for the end door object.
class EndDoor extends SpriteAnimationComponent with HasGameReference<KingGame> {
  late SpriteAnimation idleAnim, openingAnim, closingAnim;

  EndDoor({required Vector2 position})
    : super(
        position: position,
        size: Vector2(46, 56),
        anchor: Anchor.bottomCenter,
      );

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    priority = 5;
    idleAnim = await _load('11-Door/Idle.png', 1);
    openingAnim = await _load('11-Door/Opening (46x56).png', 5, loop: false);
    closingAnim = await _load('11-Door/Closiong (46x56).png', 3, loop: false);

    animation = idleAnim;
    scale = Vector2.all(2.0);
  }

  // Opens and take king.
  Future<void> openAndTakeKing(KingPlayer king) async {
    // 1. Open Door
    animation = openingAnim;
    animationTicker?.reset();
    if (animationTicker != null) {
      await animationTicker!.completed;
    }

    // 2. King walks in
    king.animation = king.doorInAnimation;
    king.animationTicker?.reset();
    if (king.animationTicker != null) {
      await king.animationTicker!.completed;
    }
    king.removeFromParent(); // King is inside

    // 3. Close Door
    animation = closingAnim;
    animationTicker?.reset();
    if (animationTicker != null) {
      await animationTicker!.completed;
    }
    animation = idleAnim;

    // 4. Show Victory Message
    game.showVictoryMessage();
  }

  // Loads load.
  Future<SpriteAnimation> _load(
    String path,
    int amount, {
    bool loop = true,
  }) async {
    return await game.loadSpriteAnimation(
      path,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.1,
        textureSize: Vector2(46, 56),
        loop: loop,
      ),
    );
  }
}

// Game component for the box pig object.
class BoxPig extends SpriteAnimationComponent with HasGameReference<KingGame> {
  BoxPig({required Vector2 position})
    : super(position: position, size: Vector2(26, 20), anchor: Anchor.center);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    animation = await game.loadSpriteAnimation(
      '06-Pig Hide in the Box/Looking Out (26x20).png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2(26, 20),
      ),
    );
    scale = Vector2.all(2.0);
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    // When all normal PigEnemies are gone, the box breaks!
    if (game.children.whereType<PigEnemy>().isEmpty) breakBox();
  }

  // Handles break box.
  void breakBox() {
    for (int i = 1; i <= 4; i++) {
      game.add(BoxPiece(position: position.clone(), pieceNum: i));
    }
    game.add(RagePig(position: position.clone()));
    removeFromParent();
  }
}

// Game component for the box piece object.
class BoxPiece extends SpriteComponent with HasGameReference<KingGame> {
  int pieceNum;
  Vector2 velocity = Vector2(0, 0);
  BoxPiece({required Vector2 position, required this.pieceNum})
    : super(position: position, size: Vector2(10, 10), anchor: Anchor.center);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    sprite = await game.loadSprite('08-Box/Box Pieces $pieceNum.png');
    velocity = Vector2((pieceNum % 2 == 0 ? 1 : -1) * 120, -250);
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity.y += 900 * dt; // gravity for pieces
    if (position.y > 2000) removeFromParent();
  }
}

// Game component for the heart pickup one object.
class HeartPickupOne extends SpriteComponent
    with HasGameReference<KingGame>, CollisionCallbacks {
  bool consumed = false;
  double pulseTimer = 0;
  double blinkTimer = 0;

  HeartPickupOne({required Vector2 position})
    : super(position: position, size: Vector2(22, 22), anchor: Anchor.center);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    sprite = await game.loadSprite('heart.png');
    add(CircleHitbox(radius: 10));
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);
    pulseTimer += dt;
    blinkTimer += dt;
    final pulse = 0.9 + 0.18 * ((sin(pulseTimer * 4) + 1) / 2);
    scale = Vector2.all(pulse * 2.0);
    opacity = 0.6 + 0.4 * ((sin(blinkTimer * 7) + 1) / 2);
  }

  @override
  // Handles on collision start.
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (consumed) return;
    if (other is KingPlayer) {
      if (other.health >= other.maxHealth) {
        game.showLevelHint('King health is full');
        return;
      }
      consumed = true;
      other.heal(1);
      removeFromParent();
    }
  }
}
