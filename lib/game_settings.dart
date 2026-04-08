import 'dart:async';

import 'audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// States used by the game difficulty logic.
enum GameDifficulty { easy, medium, hard }

// Class for the game settings feature.
class GameSettings {
  static const _kDifficulty = 'hf_setting_difficulty';
  static const _kUiTapSoundEnabled = 'hf_setting_ui_tap_enabled';
  static const _kMuted = 'hf_setting_muted';
  static const _kMasterVolume = 'hf_setting_master_volume';

  static GameDifficulty difficulty = GameDifficulty.easy;
  static bool uiTapSoundEnabled = true;

  // Loads load from disk.
  static Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();

    final difficultyIndex = prefs.getInt(_kDifficulty) ?? 0;
    difficulty = GameDifficulty.values[difficultyIndex.clamp(0, 2)];
    uiTapSoundEnabled = prefs.getBool(_kUiTapSoundEnabled) ?? true;

    final muted = prefs.getBool(_kMuted) ?? false;
    final masterVolume = prefs.getDouble(_kMasterVolume) ?? 1.0;
    await AudioService.setMasterVolume(masterVolume);
    await AudioService.setMuted(muted);
  }

  // Sets difficulty.
  static Future<void> setDifficulty(GameDifficulty value) async {
    difficulty = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDifficulty, value.index);
  }

  // Sets ui tap sound enabled.
  static Future<void> setUiTapSoundEnabled(bool enabled) async {
    uiTapSoundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUiTapSoundEnabled, enabled);
  }

  // Handles persist audio settings.
  static Future<void> persistAudioSettings({
    required bool muted,
    required double volume,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMuted, muted);
    await prefs.setDouble(_kMasterVolume, volume.clamp(0, 1));
  }

  // Handles play ui tap sound.
  static Future<void> playUiTapSound() async {
    if (!uiTapSoundEnabled) return;
    unawaited(AudioService.playSfx(AudioService.uiTap, volume: 0.6));
  }

  static String get difficultyLabel {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.medium:
        return 'Medium';
      case GameDifficulty.hard:
        return 'Hard';
    }
  }

  static int get pigHealthBonus {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 0;
      case GameDifficulty.medium:
        return 10;
      case GameDifficulty.hard:
        return 13;
    }
  }

  static int get kingHealthBonus {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 0;
      case GameDifficulty.medium:
        return 8;
      case GameDifficulty.hard:
        return 15;
    }
  }

  // Handles pig health int.
  static int pigHealthInt(int base) => base + pigHealthBonus;

  // Handles pig health double.
  static double pigHealthDouble(double base) => base + pigHealthBonus;

  // Handles king health int.
  static int kingHealthInt(int base) => base + kingHealthBonus;

  // Handles king health double.
  static double kingHealthDouble(double base) => base + kingHealthBonus;
}
