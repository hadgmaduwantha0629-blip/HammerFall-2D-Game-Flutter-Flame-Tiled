import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_route_observer.dart';
import 'auth_gate.dart';
import 'auth_service.dart';
import 'audio_service.dart';
import 'game_settings.dart';
import 'level_five.dart';
import 'level_four.dart';
import 'level_one.dart';
import 'level_progress.dart';
import 'level_three.dart';
import 'level_two.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'sound_controls_panel.dart';

// Main widget for the main menu section.
class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  // Creates the state object for this widget.
  State<MainMenu> createState() => _MainMenuState();
}

// State for the main menu widget.
class _MainMenuState extends State<MainMenu>
    with RouteAware, SingleTickerProviderStateMixin {
  GameDifficulty selectedDifficulty = GameSettings.difficulty;
  bool _routeSubscribed = false;
  bool _openingLevel = false;
  late final AnimationController _settingsIconController;
  late final Animation<double> _settingsIconTurns;

  @override
  // Sets up the state when this widget starts.
  void initState() {
    super.initState();
    _settingsIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _settingsIconTurns = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _settingsIconController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  // Opens settings dialog.
  Future<void> _openSettingsDialog() async {
    await GameSettings.playUiTapSound();
    await _settingsIconController.forward(from: 0);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        GameDifficulty dialogDifficulty = selectedDifficulty;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 360,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade300, width: 1.5),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2C1F13), Color(0xFF191E2A)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.tune, color: Colors.amber),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Settings',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await GameSettings.playUiTapSound();
                                    if (!dialogContext.mounted) return;
                                    Navigator.of(dialogContext).pop();
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white70,
                                  ),
                                  tooltip: 'Close',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Difficulty',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<GameDifficulty>(
                                  isExpanded: true,
                                  value: dialogDifficulty,
                                  dropdownColor: const Color(0xFF2A2738),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  iconEnabledColor: Colors.amber,
                                  onChanged: (value) async {
                                    if (value == null) return;
                                    setDialogState(() {
                                      dialogDifficulty = value;
                                    });
                                    setState(() {
                                      selectedDifficulty = value;
                                    });
                                    await GameSettings.setDifficulty(value);
                                  },
                                  items: GameDifficulty.values
                                      .map(
                                        (difficulty) =>
                                            DropdownMenuItem<GameDifficulty>(
                                              value: difficulty,
                                              child: Text(
                                                _difficultyText(difficulty),
                                              ),
                                            ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  if (!dialogContext.mounted) return;
                                  Navigator.of(dialogContext).pop();
                                  await Future<void>.delayed(
                                    const Duration(milliseconds: 120),
                                  );
                                  if (!mounted) return;
                                  await _openAvatarPicker();
                                },
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                                icon: const Icon(Icons.face, size: 18),
                                label: const Text('Change Avatar'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  if (!dialogContext.mounted) return;
                                  Navigator.of(dialogContext).pop();
                                  await Future<void>.delayed(
                                    const Duration(milliseconds: 120),
                                  );
                                  if (!mounted) return;
                                  await _openChangeUsernameDialog();
                                },
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                                icon: const Icon(Icons.badge, size: 18),
                                label: const Text('Change Username'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  if (!dialogContext.mounted) return;
                                  Navigator.of(dialogContext).pop();
                                  await Future<void>.delayed(
                                    const Duration(milliseconds: 120),
                                  );
                                  if (!mounted) return;
                                  await _openChangePasswordDialog();
                                },
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                                icon: const Icon(Icons.password, size: 18),
                                label: const Text('Change Password'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const SoundControlsPanel(dense: true),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Opens change username dialog.
  Future<void> _openChangeUsernameDialog() async {
    final updated = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => const _SettingsChangeUsernameDialog(),
    );

    if (updated == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Username updated.')));
    }
  }

  // Opens change password dialog.
  Future<void> _openChangePasswordDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => const _SettingsChangePasswordDialog(),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password updated.')));
    }
  }

  @override
  // Updates state that depends on inherited widgets.
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!_routeSubscribed && route != null) {
      appRouteObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  // Cleans up resources before this widget is removed.
  void dispose() {
    if (_routeSubscribed) {
      appRouteObserver.unsubscribe(this);
      _routeSubscribed = false;
    }
    _settingsIconController.dispose();
    super.dispose();
  }

  @override
  // Runs when this route becomes visible.
  void didPush() {
    AudioService.stopAllSfx();
    AudioService.playMenuLoop();
  }

  @override
  // Runs when the user returns to this route.
  void didPopNext() {
    AudioService.stopAllSfx();
    AudioService.playMenuLoop();
  }

  @override
  // Runs when another route covers this one.
  void didPushNext() {
    AudioService.stopMenuLoop();
  }

  // Returns the label for the selected difficulty.
  String _difficultyText(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.medium:
        return 'Medium';
      case GameDifficulty.hard:
        return 'Hard';
    }
  }

  // Opens map.
  Future<void> _openMap() async {
    await GameSettings.playUiTapSound();
    if (!mounted) return;
    AudioService.stopMenuLoop();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
    if (!mounted) return;
    AudioService.playMenuLoop();
  }

  // Opens profile.
  Future<void> _openProfile() async {
    await GameSettings.playUiTapSound();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    if (!mounted) return;
    setState(() {});
  }

  // Opens game help.
  Future<void> _openGameHelp() async {
    await GameSettings.playUiTapSound();
    if (!mounted) return;

    const levelPigTargets = <int, int>{1: 2, 2: 5, 3: 15, 4: 25, 5: 20};

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191E2A),
          title: const Text('Game Help'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How to complete levels',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Kill pigs to fill the Pig Hunt bar.\n'
                  '2. Reach the target for your current level.\n'
                  '3. Go to the end door to finish the level.',
                  style: TextStyle(color: Colors.white70, height: 1.35),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Minimum pigs required per level',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...levelPigTargets.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Level ${entry.key}: ${entry.value} pigs',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Opens avatar picker.
  Future<void> _openAvatarPicker() async {
    final highestUnlocked = LevelProgress.highestUnlockedLevel.clamp(1, 5);
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191E2A),
          title: const Text('Choose Avatar'),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List<Widget>.generate(
              AuthService.avatarAssetPaths.length,
              (index) {
                final unlocked = AuthService.isAvatarUnlocked(
                  avatarId: index,
                  highestUnlockedLevel: highestUnlocked,
                );
                final selected = AuthService.avatarId == index;

                return GestureDetector(
                  onTap: unlocked
                      ? () => Navigator.pop(dialogContext, index)
                      : null,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.amber : Colors.white24,
                            width: selected ? 2.5 : 1,
                          ),
                          image: DecorationImage(
                            image: AssetImage(
                              AuthService.avatarAssetPaths[index],
                            ),
                            fit: BoxFit.cover,
                            colorFilter: unlocked
                                ? null
                                : ColorFilter.mode(
                                    Colors.black.withValues(alpha: 0.6),
                                    BlendMode.darken,
                                  ),
                          ),
                        ),
                      ),
                      if (!unlocked)
                        Text(
                          'L${AuthService.avatarRequiredLevel(index)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (selected == null) return;
    await GameSettings.playUiTapSound();
    await AuthService.updateAvatar(selected);
    if (!mounted) return;
    setState(() {});
  }

  // Returns the scene for scene for level.
  Widget _sceneForLevel(int level) {
    return switch (level) {
      1 => const LevelOneScene(),
      2 => const LevelTwoScene(),
      3 => const LevelThreeScene(),
      4 => const LevelFourScene(),
      5 => const LevelFiveScene(),
      _ => const LevelOneScene(),
    };
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
    if (_openingLevel) return;
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
    await GameSettings.playUiTapSound();
    if (!mounted) return;
    LevelProgress.setLastPlayedLevel(level);
    AudioService.stopMenuLoop();
    final nextLevel = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => _sceneForLevel(level)),
    );
    if (!mounted) return;
    if (nextLevel != null && LevelProgress.isUnlocked(nextLevel)) {
      _openingLevel = false;
      await _openLevel(nextLevel);
      return;
    }
    _openingLevel = false;
    if (!mounted) return;
    AudioService.playMenuLoop();
  }

  // Handles continue last progress.
  Future<void> _continueLastProgress() async {
    final level = LevelProgress.lastPlayedLevel;
    final openLevel = LevelProgress.isUnlocked(level) ? level : 1;
    await _openLevel(openLevel);
  }

  // Signs out the current player.
  Future<void> _signOut() async {
    await GameSettings.playUiTapSound();
    await AudioService.stopMenuLoop();
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  // Switches back to the sign-in flow.
  Future<void> _switchAccount() async {
    await GameSettings.playUiTapSound();
    await AudioService.stopMenuLoop();
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  // Turns unlock all test mode on or off.
  Future<void> _toggleUnlockAllTestMode() async {
    await GameSettings.playUiTapSound();
    final nextValue = !LevelProgress.unlockAllForTesting;
    await LevelProgress.setUnlockAllForTesting(nextValue);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nextValue
              ? 'Test mode ON: all levels unlocked.'
              : 'Test mode OFF: normal level locks restored.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Closes the game app.
  Future<void> _exitGame() async {
    await GameSettings.playUiTapSound();
    await AudioService.stopMenuLoop();
    if (!mounted) return;
    await SystemNavigator.pop();
  }

  // Builds one main menu action button.
  Widget _menuActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required String backgroundAsset,
    required double size,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage(backgroundAsset),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Colors.white24, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, color: Colors.black87, size: 26),
                    const SizedBox.shrink(),
                    Icon(icon, color: Colors.white, size: 22),
                  ],
                ),
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 2,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/main_menu_bg.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 430;
                    final logoWidth = 320.0;
                    final tileSize = compact ? 125.0 : 145.0;
                    final spacing = compact ? 10.0 : 12.0;

                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        12,
                        compact ? 52 : 60,
                        12,
                        compact ? 6 : 12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logoText.png',
                            width: logoWidth,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: compact ? 14 : 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _menuActionButton(
                                  label: 'Map',
                                  icon: Icons.map,
                                  onPressed: _openMap,
                                  backgroundAsset:
                                      'assets/images/MM_BTNS/MAP_BTN.png',
                                  size: tileSize,
                                ),
                                SizedBox(width: spacing),
                                _menuActionButton(
                                  label: 'Quick Start',
                                  icon: Icons.flash_on,
                                  onPressed: () => _openLevel(1),
                                  backgroundAsset:
                                      'assets/images/MM_BTNS/QS_BTN.png',
                                  size: tileSize,
                                ),
                                SizedBox(width: spacing),
                                _menuActionButton(
                                  label: 'Continue',
                                  icon: Icons.play_arrow,
                                  onPressed: _continueLastProgress,
                                  backgroundAsset:
                                      'assets/images/MM_BTNS/CONT_BTN.png',
                                  size: tileSize,
                                ),
                                SizedBox(width: spacing),
                                _menuActionButton(
                                  label: 'Profile',
                                  icon: Icons.account_circle,
                                  onPressed: _openProfile,
                                  backgroundAsset:
                                      'assets/images/MM_BTNS/PROF_BTN.png',
                                  size: tileSize,
                                ),
                                SizedBox(width: spacing),
                                _menuActionButton(
                                  label: 'Exit',
                                  icon: Icons.exit_to_app,
                                  onPressed: _exitGame,
                                  backgroundAsset:
                                      'assets/images/MM_BTNS/EX_BTN.png',
                                  size: tileSize,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundImage: AssetImage(
                          AuthService.avatarAssetPath,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AuthService.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (AuthService.isSignedIn) ...[
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          tooltip: 'Account',
                          color: const Color(0xFF222226),
                          onSelected: (value) {
                            if (value == 'avatar') {
                              _openAvatarPicker();
                            } else if (value == 'switch') {
                              _switchAccount();
                            } else if (value == 'logout') {
                              _signOut();
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem<String>(
                              value: 'avatar',
                              child: Text('Change Avatar'),
                            ),
                            PopupMenuItem<String>(
                              value: 'switch',
                              child: Text('Switch Account'),
                            ),
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: Text('Sign Out'),
                            ),
                          ],
                          child: const Icon(
                            Icons.manage_accounts,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  tooltip: 'Settings',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.amber,
                  ),
                  onPressed: _openSettingsDialog,
                  icon: RotationTransition(
                    turns: _settingsIconTurns,
                    child: const Icon(Icons.settings),
                  ),
                ),
              ),
              Positioned(
                top: 58,
                right: 8,
                child: IconButton(
                  tooltip: 'Game Help',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.lightBlueAccent,
                  ),
                  onPressed: _openGameHelp,
                  icon: const Icon(Icons.help_outline),
                ),
              ),
              Positioned(
                top: 108,
                right: 8,
                child: ElevatedButton.icon(
                  onPressed: _toggleUnlockAllTestMode,
                  icon: Icon(
                    LevelProgress.unlockAllForTesting
                        ? Icons.lock_open
                        : Icons.lock,
                    size: 18,
                  ),
                  label: Text(
                    LevelProgress.unlockAllForTesting
                        ? 'TEST: Unlock All ON'
                        : 'TEST: Normal Locks ON',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ); // End of Scaffold
  }
}

// Main widget for the settings change username dialog section.
class _SettingsChangeUsernameDialog extends StatefulWidget {
  const _SettingsChangeUsernameDialog();

  @override
  // Creates the state object for this widget.
  State<_SettingsChangeUsernameDialog> createState() =>
      _SettingsChangeUsernameDialogState();
}

// Class for the settings change username dialog feature.
class _SettingsChangeUsernameDialogState
    extends State<_SettingsChangeUsernameDialog> {
  late String _username;
  String? _error;
  bool _isSaving = false;
  bool _isClosing = false;

  @override
  // Sets up the state when this widget starts.
  void initState() {
    super.initState();
    _username = AuthService.displayName;
  }

  // Closes close dialog.
  Future<void> _closeDialog(bool result) async {
    if (_isClosing) return;
    _isClosing = true;

    FocusManager.instance.primaryFocus?.unfocus();
    for (var i = 0; i < 25; i++) {
      if (!mounted) return;
      if (MediaQuery.viewInsetsOf(context).bottom == 0) break;
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    await Future<void>.delayed(const Duration(milliseconds: 16));
    if (!mounted) return;
    Navigator.pop(context, result);
  }

  // Cancels the current action.
  Future<void> _cancel() async {
    if (_isSaving || _isClosing) return;
    await _closeDialog(false);
  }

  // Saves save username.
  Future<void> _saveUsername() async {
    if (_isSaving || _isClosing) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await AuthService.changeUsername(_username);
      if (!mounted) return;
      await _closeDialog(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isSaving = false;
      });
    }
  }

  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = mediaQuery.size.height * 0.82;

    return Dialog(
      backgroundColor: const Color(0xFF191E2A),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: availableHeight < 220 ? 220 : availableHeight,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Username',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: AuthService.displayName,
                enabled: !_isSaving,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onChanged: (value) => _username = value,
                decoration: const InputDecoration(
                  labelText: 'New Username',
                  helperText: 'Include at least one number, e.g. player01',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : _cancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSaving ? null : _saveUsername,
                    child: Text(_isSaving ? 'Saving...' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main widget for the settings change password dialog section.
class _SettingsChangePasswordDialog extends StatefulWidget {
  const _SettingsChangePasswordDialog();

  @override
  // Creates the state object for this widget.
  State<_SettingsChangePasswordDialog> createState() =>
      _SettingsChangePasswordDialogState();
}

// Class for the settings change password dialog feature.
class _SettingsChangePasswordDialogState
    extends State<_SettingsChangePasswordDialog> {
  String _currentPassword = '';
  String _newPassword = '';
  String? _error;
  bool _isSaving = false;
  bool _isClosing = false;

  // Closes close dialog.
  Future<void> _closeDialog(bool result) async {
    if (_isClosing) return;
    _isClosing = true;

    FocusManager.instance.primaryFocus?.unfocus();
    for (var i = 0; i < 25; i++) {
      if (!mounted) return;
      if (MediaQuery.viewInsetsOf(context).bottom == 0) break;
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    await Future<void>.delayed(const Duration(milliseconds: 16));
    if (!mounted) return;
    Navigator.pop(context, result);
  }

  // Cancels the current action.
  Future<void> _cancel() async {
    if (_isSaving || _isClosing) return;
    await _closeDialog(false);
  }

  // Saves save password.
  Future<void> _savePassword() async {
    if (_isSaving || _isClosing) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await AuthService.changePassword(
        currentPassword: _currentPassword,
        newPassword: _newPassword,
      );
      if (!mounted) return;
      await _closeDialog(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isSaving = false;
      });
    }
  }

  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = mediaQuery.size.height * 0.82;

    return Dialog(
      backgroundColor: const Color(0xFF191E2A),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: availableHeight < 220 ? 220 : availableHeight,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              TextField(
                obscureText: true,
                enabled: !_isSaving,
                textInputAction: TextInputAction.next,
                onChanged: (value) => _currentPassword = value,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: true,
                enabled: !_isSaving,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onChanged: (value) => _newPassword = value,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  helperText:
                      'Use 8+ chars with uppercase, lowercase, number, and symbol.',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : _cancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSaving ? null : _savePassword,
                    child: Text(_isSaving ? 'Saving...' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
