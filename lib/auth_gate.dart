import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'loading_screen.dart';
import 'local_profile_database.dart';

// Main widget for the auth gate section.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LocalProfile?>(
      valueListenable: AuthService.authStateChanges(),
      builder: (context, profile, _) {
        if (profile == null) {
          return const _LocalSignInScreen();
        }
        return const LoadingScreen();
      },
    );
  }
}

// Main widget for the local sign in screen section.
class _LocalSignInScreen extends StatefulWidget {
  const _LocalSignInScreen();

  @override
  // Creates the state object for this widget.
  State<_LocalSignInScreen> createState() => _LocalSignInScreenState();
}

// State for the local sign in screen widget.
class _LocalSignInScreenState extends State<_LocalSignInScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _recoveryAnswerController =
      TextEditingController();
  bool _busy = false;
  bool _registerMode = false;
  bool _showUsernameTip = false;
  String? _error;
  List<LocalProfile> _profiles = const [];
  late int _selectedAvatarId;
  late String _selectedRecoveryQuestion;
  late final AnimationController _introController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _panelOpacity;
  late final Animation<Offset> _panelSlide;

  @override
  // Sets up the state when this widget starts.
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoScale = Tween<double>(begin: 1.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );
    _panelOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.52, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _panelSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.52, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _introController.forward();
    _selectedAvatarId = 0;
    _selectedRecoveryQuestion = AuthService.securityQuestions.first;
    _loadProfiles();
  }

  @override
  // Cleans up resources before this widget is removed.
  void dispose() {
    _introController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _recoveryAnswerController.dispose();
    super.dispose();
  }

  // Loads load profiles.
  Future<void> _loadProfiles() async {
    final profiles = await AuthService.listProfiles();
    if (!mounted) return;
    setState(() {
      _profiles = profiles;
    });
  }

  // Submits the current form.
  Future<void> _submit() async {
    if (_busy) return;
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (_registerMode) {
      if (!RegExp(r'\d').hasMatch(username)) {
        setState(() {
          _showUsernameTip = true;
          _error =
              'Username must include at least one number (example: king01).';
        });
        return;
      }

      final existing = await AuthService.getRecoveryQuestionForUsername(
        username,
      );
      if (existing != null) {
        setState(() {
          _showUsernameTip = true;
          _error = 'That profile name already exists.';
        });
        return;
      }
    }

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _showUsernameTip = true;
        _error = 'Enter a username and password.';
      });
      return;
    }

    if (_registerMode) {
      final passwordError = AuthService.validatePasswordStrength(password);
      if (passwordError != null) {
        setState(() {
          _error = passwordError;
        });
        return;
      }
    }

    if (_registerMode && _recoveryAnswerController.text.trim().length < 2) {
      setState(() {
        _error = 'Please provide an answer for the security question.';
      });
      return;
    }

    if (_registerMode &&
        !AuthService.isAvatarUnlocked(
          avatarId: _selectedAvatarId,
          highestUnlockedLevel: 1,
        )) {
      setState(() {
        _error = 'That avatar is locked. Reach higher levels to unlock it.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      if (_registerMode) {
        await AuthService.signUp(
          username: username,
          password: password,
          avatarId: _selectedAvatarId,
          recoveryQuestion: _selectedRecoveryQuestion,
          recoveryAnswer: _recoveryAnswerController.text.trim(),
        );
      } else {
        await AuthService.signIn(username: username, password: password);
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
      await _loadProfiles();
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  // Opens forgot password dialog.
  Future<void> _openForgotPasswordDialog() async {
    final usernameController = TextEditingController(
      text: _usernameController.text.trim(),
    );
    final answerController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    String? question;
    String? dialogError;
    bool loadingQuestion = false;
    bool resetting = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> loadQuestion() async {
              final username = usernameController.text.trim();
              if (username.isEmpty) {
                setDialogState(() {
                  dialogError = 'Enter username first.';
                  question = null;
                });
                return;
              }

              setDialogState(() {
                loadingQuestion = true;
                dialogError = null;
                question = null;
              });

              try {
                final q = await AuthService.getRecoveryQuestionForUsername(
                  username,
                );
                setDialogState(() {
                  question = q;
                  if (q == null || q.isEmpty) {
                    dialogError =
                        'No recovery question found for this profile.';
                  }
                });
              } catch (e) {
                setDialogState(() {
                  dialogError = e.toString().replaceFirst('Exception: ', '');
                });
              } finally {
                setDialogState(() {
                  loadingQuestion = false;
                });
              }
            }

            Future<void> resetPassword() async {
              final username = usernameController.text.trim();
              final answer = answerController.text.trim();
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;

              if (username.isEmpty || answer.isEmpty || newPassword.isEmpty) {
                setDialogState(() {
                  dialogError = 'Fill all required fields.';
                });
                return;
              }
              final passwordError = AuthService.validatePasswordStrength(
                newPassword,
              );
              if (passwordError != null) {
                setDialogState(() {
                  dialogError = passwordError;
                });
                return;
              }
              if (newPassword != confirmPassword) {
                setDialogState(() {
                  dialogError = 'Password confirmation does not match.';
                });
                return;
              }

              setDialogState(() {
                resetting = true;
                dialogError = null;
              });

              try {
                await AuthService.resetPasswordWithSecurityAnswer(
                  username: username,
                  recoveryAnswer: answer,
                  newPassword: newPassword,
                );
                if (!mounted) return;
                _usernameController.text = username;
                _passwordController.clear();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset successful. Please sign in.'),
                  ),
                );
              } catch (e) {
                setDialogState(() {
                  dialogError = e.toString().replaceFirst('Exception: ', '');
                });
              } finally {
                setDialogState(() {
                  resetting = false;
                });
              }
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E24),
              scrollable: true,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              title: const Text(
                'Reset Password',
                style: TextStyle(color: Colors.amber),
              ),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loadingQuestion ? null : loadQuestion,
                        child: Text(
                          loadingQuestion
                              ? 'Checking...'
                              : 'Load Security Question',
                        ),
                      ),
                    ),
                    if (question != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          question!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: answerController,
                        decoration: const InputDecoration(
                          labelText: 'Your Answer',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                          helperText:
                              'Use 8+ chars with uppercase, lowercase, number, and symbol.',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                        ),
                      ),
                    ],
                    if (dialogError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        dialogError!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: (question == null || resetting)
                      ? null
                      : resetPassword,
                  child: Text(resetting ? 'Resetting...' : 'Reset Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  // Builds the UI for this part of the app.
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final cardWidth = 440.0;
    final verticalPad = isLandscape ? 12.0 : 20.0;
    final spacing = isLandscape ? 6.0 : 12.0;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth =
                  (constraints.maxWidth - (isLandscape ? 24.0 : 32.0)).clamp(
                    280.0,
                    460.0,
                  );
              final logoWidth = (contentWidth * 0.75).clamp(220.0, 340.0);

              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 12 : 16,
                    vertical: verticalPad,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _logoOpacity,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Image.asset(
                                'assets/images/logoText.png',
                                width: logoWidth,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: isLandscape ? 10 : 18),
                          FadeTransition(
                            opacity: _panelOpacity,
                            child: SlideTransition(
                              position: _panelSlide,
                              child: Container(
                                width: cardWidth,
                                padding: EdgeInsets.all(verticalPad),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.amber,
                                    width: 1.4,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _registerMode
                                          ? 'Create a local player profile. All progress stays on this device.'
                                          : 'Sign in to a local player profile.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: spacing),
                                    TextField(
                                      controller: _usernameController,
                                      decoration: InputDecoration(
                                        labelText: 'Username',
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                        helperText:
                                            _registerMode && _showUsernameTip
                                            ? 'Use letters plus at least one number.'
                                            : null,
                                        suffixIcon: _registerMode
                                            ? Tooltip(
                                                message:
                                                    'Username must include at least one number.\nExample: player01',
                                                child: const Icon(
                                                  Icons.info_outline,
                                                  size: 18,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    SizedBox(height: spacing),
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                        helperText: _registerMode
                                            ? 'Use 8+ chars with uppercase, lowercase, number, and symbol.'
                                            : null,
                                      ),
                                    ),
                                    if (!_registerMode)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: _busy
                                              ? null
                                              : _openForgotPasswordDialog,
                                          child: const Text('Forgot password?'),
                                        ),
                                      ),
                                    if (_registerMode) ...[
                                      SizedBox(height: spacing),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: DropdownButtonFormField<String>(
                                          initialValue:
                                              _selectedRecoveryQuestion,
                                          decoration: const InputDecoration(
                                            labelText: 'Security Question',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          items: AuthService.securityQuestions
                                              .map(
                                                (question) =>
                                                    DropdownMenuItem<String>(
                                                      value: question,
                                                      child: Text(
                                                        question,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                              )
                                              .toList(),
                                          onChanged: (value) {
                                            if (value == null) return;
                                            setState(() {
                                              _selectedRecoveryQuestion = value;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(height: spacing),
                                      TextField(
                                        controller: _recoveryAnswerController,
                                        decoration: const InputDecoration(
                                          labelText: 'Security Answer',
                                          isDense: true,
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: spacing),
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Choose Avatar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: spacing / 2),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: List<Widget>.generate(
                                          AuthService.avatarAssetPaths.length,
                                          (index) {
                                            final unlocked =
                                                AuthService.isAvatarUnlocked(
                                                  avatarId: index,
                                                  highestUnlockedLevel: 1,
                                                );
                                            final selected =
                                                _selectedAvatarId == index;

                                            return GestureDetector(
                                              onTap: unlocked
                                                  ? () {
                                                      setState(() {
                                                        _selectedAvatarId =
                                                            index;
                                                      });
                                                    }
                                                  : null,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: selected
                                                            ? Colors.white
                                                            : Colors.white24,
                                                        width: selected
                                                            ? 2.5
                                                            : 1,
                                                      ),
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                          AuthService
                                                              .avatarAssetPaths[index],
                                                        ),
                                                        fit: BoxFit.cover,
                                                        colorFilter: unlocked
                                                            ? null
                                                            : ColorFilter.mode(
                                                                Colors.black
                                                                    .withValues(
                                                                      alpha:
                                                                          0.55,
                                                                    ),
                                                                BlendMode
                                                                    .darken,
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (!unlocked)
                                                    const Icon(
                                                      Icons.lock,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: spacing),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _busy ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          foregroundColor: Colors.black,
                                          padding: EdgeInsets.symmetric(
                                            vertical: isLandscape ? 8 : 14,
                                          ),
                                        ),
                                        child: Text(
                                          _busy
                                              ? 'Please wait...'
                                              : (_registerMode
                                                    ? 'Create Profile'
                                                    : 'Sign In'),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _busy
                                          ? null
                                          : () {
                                              setState(() {
                                                _registerMode = !_registerMode;
                                                _error = null;
                                                _showUsernameTip = false;
                                                if (!_registerMode) {
                                                  _recoveryAnswerController
                                                      .clear();
                                                }
                                              });
                                            },
                                      child: Text(
                                        _registerMode
                                            ? 'Already have a profile? Sign in'
                                            : 'Create a new local profile',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    if (_profiles.isNotEmpty) ...[
                                      SizedBox(height: spacing / 2),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _profiles
                                            .map(
                                              (profile) => ActionChip(
                                                avatar: CircleAvatar(
                                                  radius: 10,
                                                  backgroundImage: AssetImage(
                                                    AuthService
                                                        .avatarAssetPaths[profile
                                                        .avatarId],
                                                  ),
                                                ),
                                                label: Text(profile.username),
                                                onPressed: () {
                                                  _usernameController.text =
                                                      profile.username;
                                                },
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                    if (_error != null) ...[
                                      SizedBox(height: spacing),
                                      Text(
                                        _error!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
