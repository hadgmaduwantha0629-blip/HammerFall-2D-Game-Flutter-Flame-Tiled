import 'dart:async' as async;
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart' hide Text;
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'audio_service.dart';
import 'game_settings.dart';
import 'level_progress.dart';
import 'sound_controls_panel.dart';

// --- 1. THE UI LAYER ---
class LevelTwoScene extends StatefulWidget {
  const LevelTwoScene({super.key});

  @override
  // Creates the state object for this widget.
  State<LevelTwoScene> createState() => _LevelTwoSceneState();
}

// State for the level two scene widget.
class _LevelTwoSceneState extends State<LevelTwoScene> {
  late final LevelTwoGame game;
  bool _showDifficultyBanner = true;
  bool _isTransitioning = false;
  async.Timer? _difficultyBannerTimer;

  @override
  // Sets up the state when this widget starts.
  void initState() {
    super.initState();
    game = LevelTwoGame();
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
      MaterialPageRoute(builder: (_) => const LevelTwoScene()),
    );
  }

  Future<void> _goToNextLevel() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _clearTransientOverlays();
    _pauseGame();
    await GameSettings.playUiTapSound();
    if (!mounted) return;
    Navigator.of(context).pop(3);
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
                'LevelHint': (context, LevelTwoGame game) =>
                    _buildLevelHint(game),
                'VictoryMenu': (context, LevelTwoGame game) => _overlayCard(
                  title: 'Victory!',
                  message:
                      'Hammerfall complete. The King crushed ${game.requiredPigKills} pigs and escaped the fortress.',
                  context: context,
                ),
                'DefeatMenu': (context, LevelTwoGame game) => _overlayCard(
                  title: 'Play Again',
                  message: game.defeatMessage,
                  context: context,
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
            bottom: 50,
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
            bottom: 50,
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

  // Handles overlay card.
  Widget _overlayCard({
    required String title,
    required String message,
    required BuildContext context,
  }) {
    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.yellow, width: 3),
          image: DecorationImage(
            image: AssetImage(
              title == 'Victory!'
                  ? 'assets/images/king_win_bg.png'
                  : 'assets/images/king_fail_bg.png',
            ),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
              Color(0x99101827),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                shadows: [Shadow(color: Colors.black, blurRadius: 12)],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFF5F7FF),
                fontSize: 18,
                height: 1.35,
                shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
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
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Builds build level hint.
  Widget _buildLevelHint(LevelTwoGame game) {
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
  Widget _buildPigKillHud(LevelTwoGame game) {
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
                                'War room active. Issue ceasefire or continue the assault.',
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
                                LevelProgress.clearCheckpointForLevel(2);
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

// --- 2. THE GAME ENGINE ---
class LevelTwoGame extends FlameGame with HasCollisionDetection {
  static const double levelZoom = 1.8;
  static final Anchor cameraFollowAnchor = Anchor(0.5, 0.85);
  late PlayerTwo player;
  EndDoor? endDoor;
  List<Rect> groundRects = [];
  double mapWidth = 0;
  double mapHeight = 0;
  int pigKills = 0;
  final int requiredPigKills = 5;
  final ValueNotifier<int> pigKillsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String?> levelHint = ValueNotifier<String?>(null);
  bool endDoorUnlocked = false;
  bool endSequenceStarted = false;
  bool gameEnded = false;
  String defeatMessage = '';

  LevelTwoGame()
    : super(
        camera: CameraComponent()
          ..viewfinder.anchor = cameraFollowAnchor
          ..viewfinder.zoom = levelZoom,
      );

  bool get shouldFreezeEnemies =>
      gameEnded || endSequenceStarted || player.isDead || player.isEnteringDoor;

  final List<String> _defeatMessages = const [
    'The pigs own this castle today. Grab the hammer and take your crown back.',
    'The royal hammer slipped. Pigs are laughing in the throne room.',
    'No king, no kingdom. Smash 5 pigs and reclaim the door.',
    'The pigs wrote history this round. Time to rewrite it with steel.',
  ];

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    // debugMode = true; // Uncomment to see hitboxesr
    camera.viewfinder.zoom = levelZoom;

    final level = await TiledComponent.load('level_02.tmx', Vector2.all(32));
    world.add(level);

    mapWidth = (level.tileMap.map.width * 32).toDouble();
    mapHeight = (level.tileMap.map.height * 32).toDouble();
    camera.viewfinder.anchor = cameraFollowAnchor;

    final groundLayer = level.tileMap.getLayer<ObjectGroup>('g&w');
    if (groundLayer != null) {
      for (final obj in groundLayer.objects) {
        if (obj.name == 'ground') {
          groundRects.add(Rect.fromLTWH(obj.x, obj.y, obj.width, obj.height));
        }
      }
    }

    final spawns = level.tileMap.getLayer<ObjectGroup>('spawnpoints');
    if (spawns != null) {
      for (final obj in spawns.objects) {
        if (obj.name == 'king') {
          player = PlayerTwo(position: Vector2(obj.x, obj.y));
          world.add(player);
        }
      }

      final useResume = LevelProgress.consumeResumeChoiceForLaunch(level: 2);
      final resume = LevelProgress.resumePositionForLevel(2);
      if (useResume && resume != null) {
        player.position.setValues(resume.x, resume.y);
        showLevelHint('Resumed from your last checkpoint.');
      }
      LevelProgress.setLastPlayedLevel(2);

      for (final obj in spawns.objects) {
        if (obj.name == 'startdoor') {
          world.add(
            Door(
              position: Vector2(obj.x, obj.y),
              onOpened: () => player.spawnFromDoor(),
            ),
          );
        } else if (obj.name == 'enddoor') {
          endDoor = EndDoor(position: Vector2(obj.x, obj.y));
          world.add(endDoor!);
        } else if (obj.name == 'bombing_pig') {
          world.add(BombingPig(position: Vector2(obj.x, obj.y)));
        } else if (obj.name == 'box_pig') {
          world.add(BoxPig(position: Vector2(obj.x, obj.y)));
        } else if (obj.name == 'heart') {
          world.add(HeartPickupTwo(position: Vector2(obj.x, obj.y)));
        }
      }

      List<Cannon> cannons = [];
      for (final obj in spawns.objects) {
        if (obj.name == 'cannon') {
          final c = Cannon(position: Vector2(obj.x, obj.y));
          cannons.add(c);
          world.add(c);
        }
      }

      for (final obj in spawns.objects) {
        if (obj.name == 'cannon_fire_pig') {
          final pigPos = Vector2(obj.x, obj.y);
          if (cannons.isNotEmpty) {
            final nearest = cannons.reduce(
              (a, b) =>
                  (a.position - pigPos).length < (b.position - pigPos).length
                  ? a
                  : b,
            );
            world.add(CannonPig(position: pigPos, cannon: nearest));
          }
        }
      }
    }

    camera.follow(player, snap: false, maxSpeed: 1400);
    camera.setBounds(Rectangle.fromLTWH(0, 0, mapWidth, mapHeight));
    camera.viewfinder.zoom = levelZoom;
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    super.update(dt);

    if (gameEnded ||
        !endDoorUnlocked ||
        endSequenceStarted ||
        endDoor == null) {
      return;
    }
    if (player.isDead || player.isEntering || player.isEnteringDoor) return;

    final closeToDoorX = (player.position.x - endDoor!.position.x).abs() < 16;
    final closeToDoorY = (player.position.y - endDoor!.position.y).abs() < 26;
    if (closeToDoorX && closeToDoorY) {
      endSequenceStarted = true;
      player.enterDoor(endDoor!);
    }
  }

  // Updates progress after a pig is defeated.
  void registerPigKill() {
    if (gameEnded) return;
    pigKills++;
    pigKillsNotifier.value = pigKills;
    AudioService.playSfx(AudioService.deathPop, volume: 0.9);
    if (pigKills >= requiredPigKills && !endDoorUnlocked) {
      endDoorUnlocked = true;
      endDoor?.unlock();
    }
  }

  // Shows the victory flow for this level.
  void showVictory() {
    if (gameEnded) return;
    gameEnded = true;
    LevelProgress.markCompleted(2);
    AudioService.playSfx(AudioService.kingDoorOut, volume: 0.95);
    overlays.add('VictoryMenu');
  }

  // Handles the defeat flow when the king is defeated.
  void onKingDead() {
    if (gameEnded) return;
    gameEnded = true;
    endSequenceStarted = true;
    AudioService.playSfx(AudioService.deathPop, volume: 0.9);
    AudioService.playSfx(AudioService.fail, volume: 1.0);
    defeatMessage = _defeatMessages[Random().nextInt(_defeatMessages.length)];
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
}

// --- 3. THE PLAYER (KING) ---
class PlayerTwo extends SpriteAnimationComponent
    with HasGameRef<LevelTwoGame>, CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  double moveSpeed = 180, gravity = 1100, jumpForce = 520;
  bool isGrounded = false, isAttacking = false, isEntering = true;
  bool isEnteringDoor = false;
  bool isDead = false;
  bool isTakingHit = false;
  bool hasDealtDamage = false;
  int facingDirection = 1;
  int horizontalMovement = 0;
  late RectangleHitbox playerHitbox;

  int health = GameSettings.kingHealthInt(5);
  final int maxHealth = GameSettings.kingHealthInt(5);
  bool isInvulnerable = false;
  double invulnerableTimer = 0;
  double _progressSaveTimer = 0;

  late SpriteAnimation idleAnim,
      runAnim,
      attackAnim,
      doorOutAnim,
      doorInAnim,
      hitAnim,
      deadAnim;

  PlayerTwo({super.position})
    : super(size: Vector2(78, 58), anchor: Anchor.bottomCenter, priority: 10);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    playerHitbox = RectangleHitbox(
      size: Vector2(24, 40),
      position: Vector2(27, 10),
    );
    add(playerHitbox);
    idleAnim = await _l('01-King Human/Idle (78x58).png', 11);
    runAnim = await _l('01-King Human/Run (78x58).png', 8);
    attackAnim = await _l('01-King Human/Attack (78x58).png', 3, loop: false);
    doorOutAnim = await _l(
      '01-King Human/Door Out (78x58).png',
      8,
      loop: false,
    );
    doorInAnim = await _l('01-King Human/Door In (78x58).png', 8, loop: false);
    hitAnim = await _l('01-King Human/Hit (78x58).png', 2, loop: false);
    deadAnim = await _l('01-King Human/Dead (78x58).png', 4, loop: false);

    animation = doorOutAnim;
    opacity = 0;
  }

  // Handles l.
  Future<SpriteAnimation> _l(String p, int a, {bool loop = true}) async =>
      await gameRef.loadSpriteAnimation(
        p,
        SpriteAnimationData.sequenced(
          amount: a,
          stepTime: 0.1,
          textureSize: Vector2(78, 58),
          loop: loop,
        ),
      );

  // Reduces health when this object gets hit.
  void takeDamage() {
    if (isDead || isInvulnerable || isEntering) return;
    health--;
    if (health <= 0) {
      isDead = true;
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
      // Getting hit can interrupt attack animation; clear attack state so hammer can be used again.
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

  // Places the player at the door spawn point.
  void spawnFromDoor() {
    opacity = 1;
    isEntering = true;
    animation = doorOutAnim;
    animationTicker?.reset();
    animationTicker?.onComplete = () {
      isEntering = false;
      animation = idleAnim;
      add(KingHealthBar());
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
  void heal(int amount) {
    if (isDead) return;
    health = (health + amount).clamp(0, maxHealth);
    AudioService.playSfx(AudioService.pickupCoin, volume: 0.85);
    AudioService.playSfx(AudioService.healthRecharge, volume: 0.95);
  }

  // Starts the attack action.
  void attack() {
    if (!isAttacking && !isEntering && !isEnteringDoor && !isDead) {
      AudioService.playSfx(AudioService.kingAttack, volume: 0.78);
      isAttacking = true;
      isTakingHit = false;
      hasDealtDamage = false;

      playerHitbox.size = Vector2(50, 40);
      playerHitbox.position = Vector2(14, 10);

      _tryDealHammerDamage();

      animation = attackAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () {
        isAttacking = false;
        hasDealtDamage = false;
        _resetHitbox();
      };
    }
  }

  // Resets reset hitbox.
  void _resetHitbox() {
    playerHitbox.size = Vector2(24, 40);
    playerHitbox.position = Vector2(27, 10);
  }

  // Handles enter door.
  Future<void> enterDoor(EndDoor door) async {
    if (isDead || isEntering || isEnteringDoor) return;
    isEnteringDoor = true;
    horizontalMovement = 0;
    velocity = Vector2.zero();
    // Snap king to the middle of the end door before the door-in animation.
    position.setValues(door.position.x, door.position.y);
    await door.openAndTakeKing(this);
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
      target.takeDamage();
      if (target is! BombingPig) {
        target.position.x += (target.position.x < position.x) ? -15 : 15;
      }
    }
  }

  @override
  // Updates this object on each frame.
  void update(double dt) {
    if (isDead) {
      super.update(dt);
      return;
    }

    // Safety: Reset hitbox if not attacking
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
        level: 2,
        x: position.x,
        y: position.y,
      );
    }

    // Safety recovery: if attack animation got interrupted by hit/other states,
    // unlock attack so player input works immediately.
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
    double feetOffset = 20;
    double horizontalHitboxWidth = 9;

    for (var rect in gameRef.groundRects) {
      if (nextX + horizontalHitboxWidth > rect.left &&
          nextX - horizontalHitboxWidth < rect.right) {
        if (velocity.y >= 0 &&
            position.y - feetOffset <= rect.top + 5 &&
            nextY - feetOffset >= rect.top) {
          nextY = rect.top + feetOffset;
          velocity.y = 0;
          isGrounded = true;
        }
      }
      if (nextY - feetOffset > rect.top + 10 &&
          nextY - feetOffset < rect.bottom) {
        if (position.x < rect.left &&
            nextX + horizontalHitboxWidth > rect.left) {
          nextX = rect.left - horizontalHitboxWidth;
        } else if (position.x > rect.right &&
            nextX - horizontalHitboxWidth < rect.right) {
          nextX = rect.right + horizontalHitboxWidth;
        }
      }
    }
    position.setValues(nextX, nextY);

    if (!isDead && position.y > gameRef.mapHeight + 120) {
      isDead = true;
      gameRef.onKingDead();
    }
  }
}

// --- 4. BOX PIG SYSTEM ---
abstract class DamageablePig {
  bool get isDead;
  Vector2 get position;
  // Reduces health when this object gets hit.
  void takeDamage();
}

// Game component for the heart pickup two object.
class HeartPickupTwo extends SpriteComponent
    with HasGameRef<LevelTwoGame>, CollisionCallbacks {
  bool consumed = false;
  double pulseTimer = 0;
  double blinkTimer = 0;

  HeartPickupTwo({super.position})
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
    if (other is PlayerTwo) {
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
    with HasGameRef<LevelTwoGame>, CollisionCallbacks
    implements DamageablePig {
  bool triggered = false;
  int health = GameSettings.pigHealthInt(4);
  final int maxHealth = GameSettings.pigHealthInt(4);
  @override
  bool isDead = false;
  late SpriteAnimation deadAnim, hitAnim;

  BoxPig({super.position})
    : super(size: Vector2(26, 20), anchor: Anchor.bottomCenter, priority: 10);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    add(RectangleHitbox());
    add(PigHealthBar(getHealth: () => health, maxHealth: maxHealth));
    hitAnim = await _l2('03-Pig/Hit (34x28).png', 2, loop: false);
    deadAnim = await _l2('03-Pig/Dead (34x28).png', 4, loop: false);
    animation = await gameRef.loadSpriteAnimation(
      '06-Pig Hide in the Box/Looking Out (26x20).png',
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2(26, 20),
      ),
    );
  }

  // Handles l2.
  Future<SpriteAnimation> _l2(String p, int a, {bool loop = true}) async =>
      await gameRef.loadSpriteAnimation(
        p,
        SpriteAnimationData.sequenced(
          amount: a,
          stepTime: 0.1,
          textureSize: Vector2(34, 28),
          loop: loop,
        ),
      );

  @override
  // Reduces health when this object gets hit.
  void takeDamage() {
    if (isDead) return;
    health--;
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
    if (other is PlayerTwo &&
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
class BoxPiece extends SpriteComponent with HasGameRef<LevelTwoGame> {
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
    if (position.y > gameRef.mapHeight) removeFromParent();
  }
}

// Game component for the attacking pig object.
class AttackingPig extends SpriteAnimationComponent
    with HasGameRef<LevelTwoGame>, CollisionCallbacks
    implements DamageablePig {
  int health = GameSettings.pigHealthInt(4);
  final int maxHealth = GameSettings.pigHealthInt(4);
  @override
  bool isDead = false;
  late SpriteAnimation deadAnim, hitAnim;
  double speed = 90, gravity = 1100;
  Vector2 velocity = Vector2(0, -250);

  late SpriteAnimation idleAnim, runAnim, jumpAnim, fallAnim, attackAnim;

  AttackingPig({super.position})
    : super(size: Vector2(34, 28), anchor: Anchor.bottomCenter, priority: 10);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    add(RectangleHitbox());
    add(PigHealthBar(getHealth: () => health, maxHealth: maxHealth));
    hitAnim = await _l('03-Pig/Hit (34x28).png', 2, loop: false);
    deadAnim = await _l('03-Pig/Dead (34x28).png', 4, loop: false);
    idleAnim = await _l('03-Pig/Idle (34x28).png', 11);
    runAnim = await _l('03-Pig/Run (34x28).png', 6);
    jumpAnim = await _l('03-Pig/Jump (34x28).png', 1);
    fallAnim = await _l('03-Pig/Fall (34x28).png', 1);
    attackAnim = await _l('03-Pig/Attack (34x28).png', 5, loop: false);
    animation = jumpAnim;
  }

  // Handles l.
  Future<SpriteAnimation> _l(String p, int a, {bool loop = true}) async =>
      await gameRef.loadSpriteAnimation(
        p,
        SpriteAnimationData.sequenced(
          amount: a,
          stepTime: 0.1,
          textureSize: Vector2(34, 28),
          loop: loop,
        ),
      );

  @override
  // Reduces health when this object gets hit.
  void takeDamage() {
    if (isDead) return;
    health--;
    if (health <= 0) {
      isDead = true;
      gameRef.registerPigKill();
      animation = deadAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () => removeFromParent();
      if (animationTicker == null) removeFromParent();
    } else {
      animation = hitAnim;
      animationTicker?.reset();
    }
  }

  @override
  // Handles on collision.
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is PlayerTwo &&
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

    double dist = (gameRef.player.position - position).length;
    double dir = gameRef.player.position.x < position.x ? -1 : 1;
    double moveX = 0;

    if (dist < 45 && animation != attackAnim) {
      animation = attackAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () {
        if (!gameRef.shouldFreezeEnemies &&
            !gameRef.player.isDead &&
            (gameRef.player.position - position).length < 50) {
          gameRef.player.takeDamage();
        }
        animation = idleAnim;
      };
    } else if (dist < 180 && animation != attackAnim) {
      animation = runAnim;
      moveX = dir * speed;
      scale.x = -dir;
    } else if (dist >= 180 && animation != attackAnim) {
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

// --- 5. CANNON & BOMB SYSTEM ---
class Cannon extends SpriteAnimationComponent with HasGameRef<LevelTwoGame> {
  Cannon({super.position})
    : super(size: Vector2(44, 28), anchor: Anchor.bottomCenter);
  // Fires the current projectile.
  void fire() async {
    if (gameRef.shouldFreezeEnemies) return;
    animation = await gameRef.loadSpriteAnimation(
      '10-Cannon/Shoot (44x28).png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(44, 28),
        loop: false,
      ),
    );
    gameRef.world.add(
      CannonBall(
        position: position - Vector2(10, 15),
        velocity: Vector2(-250, -180),
      ),
    );
    animationTicker?.onComplete = () async =>
        animation = await gameRef.loadSpriteAnimation(
          '10-Cannon/Idle.png',
          SpriteAnimationData.sequenced(
            amount: 1,
            stepTime: 1,
            textureSize: Vector2(44, 28),
          ),
        );
  }
}

// Game component for the cannon ball object.
class CannonBall extends SpriteAnimationComponent
    with HasGameRef<LevelTwoGame>, CollisionCallbacks {
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
    if (other is PlayerTwo) {
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
      for (var r in gameRef.groundRects) {
        if (r.contains(position.toOffset())) explode();
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
    with HasGameRef<LevelTwoGame>, CollisionCallbacks
    implements DamageablePig {
  bool throwing = false;
  bool isTakingHit = false;
  int throwSequenceId = 0;
  int health = GameSettings.pigHealthInt(4);
  final int maxHealth = GameSettings.pigHealthInt(4);
  @override
  bool isDead = false;
  late SpriteAnimation deadAnim, hitAnim;

  BombingPig({super.position})
    : super(size: Vector2(26, 26), anchor: Anchor.bottomCenter, priority: 10);
  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    add(RectangleHitbox());
    add(PigHealthBar(getHealth: () => health, maxHealth: maxHealth));
    hitAnim = await _l2('03-Pig/Hit (34x28).png', 2, loop: false);
    deadAnim = await _l2('03-Pig/Dead (34x28).png', 4, loop: false);
    animation = await gameRef.loadSpriteAnimation(
      '05-Pig Thowing a Bomb/Idle (26x26).png',
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.1,
        textureSize: Vector2(26, 26),
      ),
    );
  }

  // Handles l2.
  Future<SpriteAnimation> _l2(String p, int a, {bool loop = true}) async =>
      await gameRef.loadSpriteAnimation(
        p,
        SpriteAnimationData.sequenced(
          amount: a,
          stepTime: 0.1,
          textureSize: Vector2(34, 28),
          loop: loop,
        ),
      );

  @override
  // Reduces health when this object gets hit.
  void takeDamage() {
    if (isDead) return;
    // Cancel any in-flight throw sequence so hit animation is not overridden.
    throwSequenceId++;
    throwing = false;
    health--;
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
    if (other is PlayerTwo &&
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
    if ((gameRef.player.position - position).length < 300 && !throwing) _th();
    scale.x = gameRef.player.position.x < position.x ? 1 : -1;
  }

  // Handles th.
  void _th() async {
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
    double d = gameRef.player.position.x < position.x ? -1 : 1;
    gameRef.world.add(
      ThrownBomb(
        position: position + Vector2(d * 15, -25),
        velocity: Vector2(d * 220, -280),
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

// Game component for the cannon pig object.
class CannonPig extends SpriteAnimationComponent
    with HasGameRef<LevelTwoGame>, CollisionCallbacks
    implements DamageablePig {
  final Cannon cannon;
  int health = GameSettings.pigHealthInt(4);
  final int maxHealth = GameSettings.pigHealthInt(4);
  @override
  bool isDead = false;
  bool isTakingHit = false;
  late SpriteAnimation deadAnim, hitAnim;

  CannonPig({super.position, required this.cannon})
    : super(size: Vector2(26, 18), anchor: Anchor.bottomCenter, priority: 10);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    add(RectangleHitbox());
    add(PigHealthBar(getHealth: () => health, maxHealth: maxHealth));
    hitAnim = await _l2('03-Pig/Hit (34x28).png', 2, loop: false);
    deadAnim = await _l2('03-Pig/Dead (34x28).png', 4, loop: false);
    _l();
  }

  // Handles l.
  void _l() async {
    if (isDead || gameRef.shouldFreezeEnemies || isTakingHit) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!isDead && !gameRef.shouldFreezeEnemies) {
        _l();
      }
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
      _l();
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
      _l();
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
      _l();
      return;
    }
    cannon.fire();
    await Future.delayed(const Duration(seconds: 3));
    _l();
  }

  // Handles l2.
  Future<SpriteAnimation> _l2(String p, int a, {bool loop = true}) async =>
      await gameRef.loadSpriteAnimation(
        p,
        SpriteAnimationData.sequenced(
          amount: a,
          stepTime: 0.1,
          textureSize: Vector2(34, 28),
          loop: loop,
        ),
      );

  @override
  // Reduces health when this object gets hit.
  void takeDamage() {
    if (isDead) return;
    health--;
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
    if (other is PlayerTwo &&
        other.isAttacking &&
        !other.hasDealtDamage &&
        !isDead) {
      other.hasDealtDamage = true;
      takeDamage();
      position.x += (position.x < other.position.x) ? -6 : 6;
    }
  }
}

// Game component for the door object.
class Door extends SpriteAnimationComponent with HasGameRef<LevelTwoGame> {
  final VoidCallback? onOpened;
  Door({super.position, this.onOpened})
    : super(size: Vector2(78, 58), anchor: Anchor.bottomCenter);
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

// Game component for the end door object.
class EndDoor extends SpriteAnimationComponent with HasGameRef<LevelTwoGame> {
  bool unlocked = false;
  bool entering = false;
  late SpriteAnimation idleAnim, openingAnim;

  EndDoor({super.position})
    : super(size: Vector2(46, 56), anchor: Anchor.bottomCenter, priority: 5);

  @override
  // Loads assets and child components.
  Future<void> onLoad() async {
    idleAnim = await _load('11-Door/Idle.png', 1);
    openingAnim = await _load('11-Door/Opening (46x56).png', 5, loop: false);
    animation = idleAnim;
  }

  // Loads load.
  Future<SpriteAnimation> _load(
    String path,
    int amount, {
    bool loop = true,
  }) async {
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

  // Handles unlock.
  Future<void> unlock() async {
    if (unlocked) return;
    unlocked = true;
    animation = openingAnim;
    animationTicker?.reset();
    animationTicker?.onComplete = () {
      // Keep door visually open after 5 kills.
      animationTicker?.paused = true;
    };
    if (animationTicker != null) {
      await animationTicker!.completed;
    }
  }

  // Opens and take king.
  Future<void> openAndTakeKing(PlayerTwo king) async {
    if (!unlocked || entering) return;
    entering = true;

    if (animation != openingAnim) {
      animation = openingAnim;
      animationTicker?.reset();
      animationTicker?.onComplete = () => animationTicker?.paused = true;
      if (animationTicker != null) {
        await animationTicker!.completed;
      }
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

// Game component for the king health bar object.
class KingHealthBar extends PositionComponent with ParentIsA<PlayerTwo> {
  KingHealthBar() : super(size: Vector2(46, 8), position: Vector2(-23, -64));

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
    final double healthPercentage = (parent.health / parent.maxHealth).clamp(
      0,
      1,
    );
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

// Game component for the pig health bar object.
class PigHealthBar extends PositionComponent with ParentIsA<PositionComponent> {
  final int Function() getHealth;
  final int maxHealth;
  PigHealthBar({required this.getHealth, required this.maxHealth})
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
    final double healthPercentage = (getHealth() / maxHealth).clamp(0, 1);
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
