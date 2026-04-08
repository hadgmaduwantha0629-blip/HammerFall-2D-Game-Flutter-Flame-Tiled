import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

// Class for the audio service feature.
class AudioService {
  static final AudioPlayer _menuPlayer = AudioPlayer(playerId: 'menu_bgm');
  static final AudioPlayer _mapPlayer = AudioPlayer(playerId: 'map_bgm');
  static final Set<AudioPlayer> _sfxPlayers = <AudioPlayer>{};
  static bool _isMuted = false;
  static double _masterVolume = 1.0;

  static const String menuLoop =
      'mixkit-medieval-show-fanfare-announcement-226.wav';
  static const String superPowerRise = 'mixkit-arcade-rising-231.wav';
  static const String healthRecharge =
      'mixkit-video-game-health-recharge-2837.wav';
  static const String deathPop = 'mixkit-game-blood-pop-slide-2363.wav';
  static const String jump = 'mixkit-player-jumping-in-a-video-game-2043.wav';
  static const String pickupCoin = 'mixkit-winning-a-coin-video-game-2069.wav';
  static const String levelComplete = 'mixkit-game-level-completed-2059.wav';
  static const String fail = 'mixkit-player-losing-or-failing-2042.wav';
  static const String mapLoop = 'mixkit-game-level-music-689.wav';
  static const String uiTap = 'mixkit-game-ball-tap-2073.wav';
  static const String kingAttack = 'mixkit-mechanical-crate-pick-up-3154.wav';
  static const String kingDoorOut = 'mixkit-completion-of-a-level-2063.wav';

  static bool get isMuted => _isMuted;
  static double get masterVolume => _masterVolume;

  // Handles effective volume.
  static double _effectiveVolume(double requested) {
    if (_isMuted) return 0;
    return (requested * _masterVolume).clamp(0, 1);
  }

  // Sets muted.
  static Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    await _menuPlayer.setVolume(_effectiveVolume(0.6));
    await _mapPlayer.setVolume(_effectiveVolume(0.45));
    if (_isMuted) {
      await stopAllAudio();
    }
  }

  // Sets master volume.
  static Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0, 1);
    await _menuPlayer.setVolume(_effectiveVolume(0.6));
    await _mapPlayer.setVolume(_effectiveVolume(0.45));
  }

  // Handles play menu loop.
  static Future<void> playMenuLoop() async {
    if (_isMuted) {
      await _menuPlayer.stop();
      return;
    }
    await _mapPlayer.stop();
    await _menuPlayer.setReleaseMode(ReleaseMode.loop);
    await _menuPlayer.setVolume(_effectiveVolume(0.6));
    await _menuPlayer.play(AssetSource('audios/$menuLoop'));
  }

  // Handles stop menu loop.
  static Future<void> stopMenuLoop() async {
    await _menuPlayer.stop();
  }

  // Handles play map loop.
  static Future<void> playMapLoop() async {
    if (_isMuted) {
      await _mapPlayer.stop();
      return;
    }
    await _menuPlayer.stop();
    await _mapPlayer.setReleaseMode(ReleaseMode.loop);
    await _mapPlayer.setVolume(_effectiveVolume(0.45));
    await _mapPlayer.play(AssetSource('audios/$mapLoop'));
  }

  // Handles stop map loop.
  static Future<void> stopMapLoop() async {
    await _mapPlayer.stop();
  }

  // Stops all transient gameplay sound effects.
  static Future<void> stopAllSfx() async {
    final players = _sfxPlayers.toList(growable: false);
    _sfxPlayers.clear();

    for (final player in players) {
      try {
        await player.stop();
      } catch (_) {}
      try {
        await player.dispose();
      } catch (_) {}
    }
  }

  // Stops every audio source owned by the game.
  static Future<void> stopAllAudio() async {
    await _menuPlayer.stop();
    await _mapPlayer.stop();
    await stopAllSfx();
  }

  // Handles play sfx.
  static Future<void> playSfx(String file, {double volume = 1.0}) async {
    final effective = _effectiveVolume(volume);
    if (effective <= 0) return;

    final player = AudioPlayer();
    _sfxPlayers.add(player);
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setVolume(effective);
    await player.play(AssetSource('audios/$file'));
    unawaited(
      player.onPlayerComplete.first.then((_) async {
        _sfxPlayers.remove(player);
        await player.dispose();
      }),
    );
  }
}
