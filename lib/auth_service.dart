import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'avatar_catalog.dart';
import 'local_profile_database.dart';

// Class for the auth service feature.
class AuthService {
  AuthService._();

  static const String passwordRequirementsMessage =
      'Password must be at least 8 characters and include uppercase, lowercase, number, and symbol.';

  static const List<String> securityQuestions = <String>[
    "What is your mother's maiden name?",
    'What was the name of your first pet?',
    'What is your birthplace?',
    'What is your favorite subject in school?',
  ];

  static const _kCurrentProfileId = 'hf_current_profile_id';
  static final ValueNotifier<LocalProfile?> currentProfileNotifier =
      ValueNotifier<LocalProfile?>(null);

  static LocalProfile? get currentUser => currentProfileNotifier.value;

  static bool get isSignedIn => currentUser != null;

  static String get displayName => currentUser?.username ?? 'Guest';

  static String get email =>
      isSignedIn ? '${currentUser!.username}@local' : 'guest@local';

  static String? get photoUrl => null;

  static int get avatarId =>
      AvatarCatalog.sanitizeAvatarId(currentUser?.avatarId ?? 0);
  static String get avatarAssetPath => AvatarCatalog.avatarAssetPaths[avatarId];
  static List<String> get avatarAssetPaths => AvatarCatalog.avatarAssetPaths;

  static String? validatePasswordStrength(String password) {
    if (password.length < 8) return passwordRequirementsMessage;
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return passwordRequirementsMessage;
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return passwordRequirementsMessage;
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return passwordRequirementsMessage;
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return passwordRequirementsMessage;
    }
    return null;
  }

  // Initializes the service state.
  static Future<void> initialize() async {
    await LocalProfileDatabase.instance.init();
    final prefs = await SharedPreferences.getInstance();
    final profileId = prefs.getInt(_kCurrentProfileId);
    if (profileId == null) return;

    final profile = await LocalProfileDatabase.instance.getProfileById(
      profileId,
    );
    currentProfileNotifier.value = profile;
  }

  // Returns auth state changes.
  static ValueListenable<LocalProfile?> authStateChanges() =>
      currentProfileNotifier;

  // Lists list profiles.
  static Future<List<LocalProfile>> listProfiles() {
    return LocalProfileDatabase.instance.listProfiles();
  }

  // Handles sign up.
  static Future<LocalProfile> signUp({
    required String username,
    required String password,
    int? avatarId,
    String? recoveryQuestion,
    String? recoveryAnswer,
  }) async {
    final passwordError = validatePasswordStrength(password);
    if (passwordError != null) {
      throw Exception(passwordError);
    }
    final profile = await LocalProfileDatabase.instance.createProfile(
      username: username,
      password: password,
      avatarId: avatarId,
      recoveryQuestion: recoveryQuestion,
      recoveryAnswer: recoveryAnswer,
    );
    await _setCurrentProfile(profile);
    return profile;
  }

  // Handles sign in.
  static Future<LocalProfile> signIn({
    required String username,
    required String password,
  }) async {
    final profile = await LocalProfileDatabase.instance.signIn(
      username: username,
      password: password,
    );
    if (profile == null) {
      throw Exception('Invalid username or password.');
    }
    await _setCurrentProfile(profile);
    return profile;
  }

  // Signs out the current player.
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCurrentProfileId);
    currentProfileNotifier.value = null;
  }

  // Checks whether is avatar unlocked.
  static bool isAvatarUnlocked({
    required int avatarId,
    required int highestUnlockedLevel,
  }) {
    return AvatarCatalog.isUnlocked(avatarId, highestUnlockedLevel);
  }

  // Handles avatar required level.
  static int avatarRequiredLevel(int avatarId) {
    final safeId = AvatarCatalog.sanitizeAvatarId(avatarId);
    return AvatarCatalog.requiredLevelByAvatar[safeId];
  }

  // Handles update avatar.
  static Future<LocalProfile> updateAvatar(int avatarId) async {
    final profile = currentUser;
    if (profile == null) {
      throw Exception('No active profile.');
    }
    final updated = await LocalProfileDatabase.instance.updateAvatarId(
      profileId: profile.id,
      avatarId: avatarId,
    );
    await _setCurrentProfile(updated);
    return updated;
  }

  // Changes password.
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final profile = currentUser;
    if (profile == null) {
      throw Exception('No active profile.');
    }
    if (profile.password != currentPassword) {
      throw Exception('Current password is incorrect.');
    }
    final passwordError = validatePasswordStrength(newPassword);
    if (passwordError != null) {
      throw Exception(passwordError);
    }
    final updated = await LocalProfileDatabase.instance.updatePassword(
      profileId: profile.id,
      newPassword: newPassword,
    );
    await _setCurrentProfile(updated);
  }

  // Changes username.
  static Future<void> changeUsername(String newUsername) async {
    final profile = currentUser;
    if (profile == null) {
      throw Exception('No active profile.');
    }

    final normalized = newUsername.trim();
    if (normalized.length < 3) {
      throw Exception('Username must be at least 3 characters.');
    }

    final hasDigit = RegExp(r'\d').hasMatch(normalized);
    if (!hasDigit) {
      throw Exception('Username must include at least one number.');
    }

    final updated = await LocalProfileDatabase.instance.updateUsername(
      profileId: profile.id,
      newUsername: normalized,
    );
    await _setCurrentProfile(updated);
  }

  // Deletes current profile.
  static Future<void> deleteCurrentProfile() async {
    final profile = currentUser;
    if (profile == null) return;
    await LocalProfileDatabase.instance.deleteProfile(profile.id);
    await signOut();
  }

  // Gets recovery question for username.
  static Future<String?> getRecoveryQuestionForUsername(String username) {
    return LocalProfileDatabase.instance.getRecoveryQuestionForUsername(
      username,
    );
  }

  // Resets reset password with security answer.
  static Future<void> resetPasswordWithSecurityAnswer({
    required String username,
    required String recoveryAnswer,
    required String newPassword,
  }) async {
    final passwordError = validatePasswordStrength(newPassword);
    if (passwordError != null) {
      throw Exception(passwordError);
    }
    await LocalProfileDatabase.instance.resetPasswordWithRecoveryAnswer(
      username: username,
      recoveryAnswer: recoveryAnswer,
      newPassword: newPassword,
    );
  }

  // Sets current profile.
  static Future<void> _setCurrentProfile(LocalProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCurrentProfileId, profile.id);
    currentProfileNotifier.value = profile;
  }
}
