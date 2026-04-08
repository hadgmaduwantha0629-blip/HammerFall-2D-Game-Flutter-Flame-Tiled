import 'package:flutter/material.dart';

import 'audio_service.dart';
import 'auth_gate.dart';
import 'auth_service.dart';
import 'game_settings.dart';
import 'level_five.dart';
import 'level_four.dart';
import 'level_one.dart';
import 'level_progress.dart';
import 'level_three.dart';
import 'level_two.dart';

// Main widget for the profile screen section.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // Creates the state object for this widget.
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// State for the profile screen widget.
class _ProfileScreenState extends State<ProfileScreen> {
  bool _openingLevel = false;

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

  // Opens level.
  Future<void> _openLevel(int level, {required bool startFresh}) async {
    if (!LevelProgress.isUnlocked(level) || _openingLevel) return;
    _openingLevel = true;

    await GameSettings.playUiTapSound();
    LevelProgress.setResumeChoiceForNextLaunch(
      level: level,
      useResumePosition: !startFresh,
    );
    LevelProgress.setLastPlayedLevel(level);
    await AudioService.stopMenuLoop();

    if (!mounted) return;
    final nextLevel = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => _sceneForLevel(level)),
    );

    if (!mounted) return;
    if (nextLevel != null && LevelProgress.isUnlocked(nextLevel)) {
      _openingLevel = false;
      await _openLevel(nextLevel, startFresh: false);
      return;
    }
    _openingLevel = false;
    await AudioService.playMenuLoop();
    setState(() {});
  }

  // Lets the user pick pick avatar.
  Future<void> _pickAvatar() async {
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

  // Changes password.
  Future<void> _changePassword() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _ChangePasswordDialog(),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password updated.')));
    }
  }

  // Deletes profile.
  Future<void> _deleteProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191E2A),
          title: const Text('Delete Profile'),
          content: const Text(
            'This will remove the local profile and all saved progress on this device. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await GameSettings.playUiTapSound();
    await AuthService.deleteCurrentProfile();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    final highestUnlocked = LevelProgress.highestUnlockedLevel.clamp(1, 5);
    final bottomInset = MediaQuery.of(context).padding.bottom;

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await GameSettings.playUiTapSound();
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: bottomInset + 48),
                    children: [
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PROFILE',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundImage: AssetImage(
                                    AuthService.avatarAssetPath,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AuthService.displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        AuthService.email,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Unlocked: ${LevelProgress.highestUnlockedLevel}/5  |  Completed: ${LevelProgress.highestCompletedLevel}/5',
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      tooltip: 'Change avatar',
                                      onPressed: _pickAvatar,
                                      constraints:
                                          const BoxConstraints.tightFor(
                                            width: 34,
                                            height: 34,
                                          ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.face,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Change password',
                                      onPressed: _changePassword,
                                      constraints:
                                          const BoxConstraints.tightFor(
                                            width: 34,
                                            height: 34,
                                          ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.password,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete profile',
                                      onPressed: _deleteProfile,
                                      constraints:
                                          const BoxConstraints.tightFor(
                                            width: 34,
                                            height: 34,
                                          ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.delete_forever,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List<Widget>.generate(highestUnlocked, (index) {
                        final level = index + 1;
                        final checkpoint = LevelProgress.resumePositionForLevel(
                          level,
                        );
                        final completed =
                            level <= LevelProgress.highestCompletedLevel;
                        final areaLabel = LevelProgress.checkpointAreaForLevel(
                          level,
                        );
                        final lastPlayed =
                            LevelProgress.checkpointRelativeTimeForLevel(level);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: completed
                                    ? Colors.greenAccent
                                    : Colors.white24,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 110,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/images/level$level.png',
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Level $level',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_pin,
                                                size: 16,
                                                color: checkpoint != null
                                                    ? Colors.amber
                                                    : Colors.white54,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                areaLabel,
                                                style: TextStyle(
                                                  color: checkpoint != null
                                                      ? Colors.amber
                                                      : Colors.white54,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            checkpoint != null
                                                ? lastPlayed
                                                : (completed
                                                      ? 'Completed'
                                                      : 'Start level'),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            _openLevel(level, startFresh: true),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Colors.white38,
                                          ),
                                        ),
                                        child: const Text('Start Fresh'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: checkpoint != null
                                            ? () => _openLevel(
                                                level,
                                                startFresh: false,
                                              )
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2D9CDB,
                                          ),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Continue'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Main widget for the change password dialog section.
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  // Creates the state object for this widget.
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

// State for the change password dialog widget.
class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  String _currentPassword = '';
  String _newPassword = '';
  String? _error;
  bool _isSaving = false;
  bool _isClosing = false;

  @override
  // Cleans up resources before this widget is removed.
  void dispose() {
    super.dispose();
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
      return;
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
                onChanged: (value) => _currentPassword = value,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                obscureText: true,
                enabled: !_isSaving,
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
