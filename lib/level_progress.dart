import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';
import 'local_profile_database.dart';

// Class for the resume position feature.
class ResumePosition {
  const ResumePosition({required this.x, required this.y, this.updatedAtMs});

  final double x;
  final double y;
  final int? updatedAtMs;
}

// Class for the level progress feature.
class LevelProgress {
  static const _kUnlockAllForTesting = 'hf_unlock_all_for_testing';
  static const _kHighestUnlocked = 'hf_highest_unlocked';
  static const _kHighestCompleted = 'hf_highest_completed';
  static const _kLastPlayedLevel = 'hf_last_played_level';
  static const _kLastPosLevel = 'hf_last_pos_level';
  static const _kLastPosX = 'hf_last_pos_x';
  static const _kLastPosY = 'hf_last_pos_y';
  static const _kCheckpoints = 'hf_level_checkpoints';

  static int _highestUnlockedLevel = 1;
  static int _highestCompletedLevel = 0;
  static int _lastPlayedLevel = 1;
  static bool _unlockAllForTesting = false;
  static int? _lastPositionLevel;
  static double? _lastPositionX;
  static double? _lastPositionY;
  static final Map<int, ResumePosition> _checkpoints = <int, ResumePosition>{};
  static final Map<int, bool> _resumeChoiceForNextLaunch = <int, bool>{};

  static int get highestUnlockedLevel =>
      _unlockAllForTesting ? 5 : _highestUnlockedLevel;
  static int get highestCompletedLevel => _highestCompletedLevel;
  static int get lastPlayedLevel => _lastPlayedLevel;
  static bool get unlockAllForTesting => _unlockAllForTesting;

  // Checks whether is unlocked.
  static bool isUnlocked(int level) =>
      _unlockAllForTesting || level <= _highestUnlockedLevel;

  // Sets unlock all for testing.
  static Future<void> setUnlockAllForTesting(bool enabled) async {
    _unlockAllForTesting = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUnlockAllForTesting, enabled);
  }

  // Sets resume choice for next launch.
  static void setResumeChoiceForNextLaunch({
    required int level,
    required bool useResumePosition,
  }) {
    _resumeChoiceForNextLaunch[level.clamp(1, 5)] = useResumePosition;
  }

  // Uses and clears consume resume choice for launch.
  static bool consumeResumeChoiceForLaunch({required int level}) {
    final clampedLevel = level.clamp(1, 5);
    return _resumeChoiceForNextLaunch.remove(clampedLevel) ?? true;
  }

  // Handles resume position for level.
  static ResumePosition? resumePositionForLevel(int level) {
    final slot = _checkpoints[level];
    if (slot != null) return slot;

    if (_lastPositionLevel != level ||
        _lastPositionX == null ||
        _lastPositionY == null) {
      return null;
    }
    return ResumePosition(x: _lastPositionX!, y: _lastPositionY!);
  }

  // Handles checkpoint area for level.
  static String checkpointAreaForLevel(int level) {
    final checkpoint = resumePositionForLevel(level);
    if (checkpoint == null) return 'No checkpoint';

    final x = checkpoint.x;
    if (x < 450) return 'West Zone';
    if (x < 900) return 'Mid-West Zone';
    if (x < 1350) return 'Mid-East Zone';
    return 'East Zone';
  }

  // Handles checkpoint relative time for level.
  static String checkpointRelativeTimeForLevel(int level) {
    final checkpoint = resumePositionForLevel(level);
    final updatedAtMs = checkpoint?.updatedAtMs;
    if (updatedAtMs == null) return 'No recent activity';

    final now = DateTime.now().millisecondsSinceEpoch;
    final diffMs = (now - updatedAtMs).clamp(0, 1 << 62);
    final diff = Duration(milliseconds: diffMs);

    if (diff.inMinutes < 1) return 'Last played just now';
    if (diff.inHours < 1) return 'Last played ${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'Last played ${diff.inHours}h ago';
    return 'Last played ${diff.inDays}d ago';
  }

  // Loads load for current user.
  static Future<void> loadForCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    _unlockAllForTesting = prefs.getBool(_kUnlockAllForTesting) ?? false;

    _highestUnlockedLevel = 1;
    _highestCompletedLevel = 0;
    _lastPlayedLevel = 1;
    _lastPositionLevel = null;
    _lastPositionX = null;
    _lastPositionY = null;
    _checkpoints.clear();

    final profile = AuthService.currentUser;
    if (profile != null) {
      final progress = await LocalProfileDatabase.instance.getProgress(
        profile.id,
      );
      _applyMap({
        'highestUnlockedLevel': progress.highestUnlockedLevel,
        'highestCompletedLevel': progress.highestCompletedLevel,
        'lastPlayedLevel': progress.lastPlayedLevel,
        'lastPositionLevel': progress.lastPositionLevel,
        'lastPositionX': progress.lastPositionX,
        'lastPositionY': progress.lastPositionY,
        'checkpoints': progress.checkpoints,
      });
      return;
    }

    await _loadLocal();
  }

  // Marks mark completed.
  static void markCompleted(int level) {
    if (level > _highestCompletedLevel) {
      _highestCompletedLevel = level;
    }
    final nextLevel = level + 1;
    if (nextLevel > _highestUnlockedLevel && nextLevel <= 5) {
      _highestUnlockedLevel = nextLevel;
    }
    setLastPlayedLevel(level);
    unawaited(_save());
  }

  // Sets last played level.
  static void setLastPlayedLevel(int level) {
    _lastPlayedLevel = level.clamp(1, 5);
    unawaited(_save());
  }

  // Sets last known position.
  static void setLastKnownPosition({
    required int level,
    required double x,
    required double y,
  }) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    _lastPositionLevel = level.clamp(1, 5);
    _lastPositionX = x;
    _lastPositionY = y;
    _lastPlayedLevel = _lastPositionLevel!;
    _checkpoints[_lastPositionLevel!] = ResumePosition(
      x: x,
      y: y,
      updatedAtMs: nowMs,
    );
    unawaited(_save());
  }

  // Handles clear checkpoint for level.
  static void clearCheckpointForLevel(int level) {
    _checkpoints.remove(level);
    if (_lastPositionLevel == level) {
      _lastPositionLevel = null;
      _lastPositionX = null;
      _lastPositionY = null;
    }
    unawaited(_save());
  }

  // Applies apply map.
  static void _applyMap(Map<String, dynamic> data) {
    _highestUnlockedLevel =
        (data['highestUnlockedLevel'] as num?)?.toInt() ?? 1;
    _highestCompletedLevel =
        (data['highestCompletedLevel'] as num?)?.toInt() ?? 0;
    _lastPlayedLevel = (data['lastPlayedLevel'] as num?)?.toInt() ?? 1;
    _lastPositionLevel = (data['lastPositionLevel'] as num?)?.toInt();
    _lastPositionX = (data['lastPositionX'] as num?)?.toDouble();
    _lastPositionY = (data['lastPositionY'] as num?)?.toDouble();

    _checkpoints.clear();
    final dynamic checkpointsRaw = data['checkpoints'];
    if (checkpointsRaw is Map<String, dynamic>) {
      for (final entry in checkpointsRaw.entries) {
        final level = int.tryParse(entry.key);
        final value = entry.value;
        if (level == null || value is! Map<String, dynamic>) continue;
        final x = (value['x'] as num?)?.toDouble();
        final y = (value['y'] as num?)?.toDouble();
        if (x == null || y == null) continue;
        _checkpoints[level] = ResumePosition(
          x: x,
          y: y,
          updatedAtMs: (value['updatedAtMs'] as num?)?.toInt(),
        );
      }
    }
  }

  // Loads load local.
  static Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    _highestUnlockedLevel = prefs.getInt(_kHighestUnlocked) ?? 1;
    _highestCompletedLevel = prefs.getInt(_kHighestCompleted) ?? 0;
    _lastPlayedLevel = prefs.getInt(_kLastPlayedLevel) ?? 1;
    _lastPositionLevel = prefs.getInt(_kLastPosLevel);
    _lastPositionX = prefs.getDouble(_kLastPosX);
    _lastPositionY = prefs.getDouble(_kLastPosY);

    _checkpoints.clear();
    final checkpointsJson = prefs.getString(_kCheckpoints);
    if (checkpointsJson != null && checkpointsJson.isNotEmpty) {
      final decoded = jsonDecode(checkpointsJson);
      if (decoded is Map<String, dynamic>) {
        for (final entry in decoded.entries) {
          final level = int.tryParse(entry.key);
          final value = entry.value;
          if (level == null || value is! Map<String, dynamic>) continue;
          final x = (value['x'] as num?)?.toDouble();
          final y = (value['y'] as num?)?.toDouble();
          if (x == null || y == null) continue;
          _checkpoints[level] = ResumePosition(
            x: x,
            y: y,
            updatedAtMs: (value['updatedAtMs'] as num?)?.toInt(),
          );
        }
      }
    }

    if (_lastPositionLevel != null &&
        _lastPositionX != null &&
        _lastPositionY != null) {
      _checkpoints[_lastPositionLevel!] = ResumePosition(
        x: _lastPositionX!,
        y: _lastPositionY!,
        updatedAtMs: _checkpoints[_lastPositionLevel!]?.updatedAtMs,
      );
    }
  }

  // Saves save.
  static Future<void> _save() async {
    final data = <String, dynamic>{
      'highestUnlockedLevel': _highestUnlockedLevel,
      'highestCompletedLevel': _highestCompletedLevel,
      'lastPlayedLevel': _lastPlayedLevel,
      'lastPositionLevel': _lastPositionLevel,
      'lastPositionX': _lastPositionX,
      'lastPositionY': _lastPositionY,
      'checkpoints': <String, dynamic>{
        for (final entry in _checkpoints.entries)
          '${entry.key}': {
            'x': entry.value.x,
            'y': entry.value.y,
            'updatedAtMs': entry.value.updatedAtMs,
          },
      },
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHighestUnlocked, _highestUnlockedLevel);
    await prefs.setInt(_kHighestCompleted, _highestCompletedLevel);
    await prefs.setInt(_kLastPlayedLevel, _lastPlayedLevel);
    if (_lastPositionLevel != null) {
      await prefs.setInt(_kLastPosLevel, _lastPositionLevel!);
    }
    if (_lastPositionX != null) {
      await prefs.setDouble(_kLastPosX, _lastPositionX!);
    }
    if (_lastPositionY != null) {
      await prefs.setDouble(_kLastPosY, _lastPositionY!);
    }
    await prefs.setString(_kCheckpoints, jsonEncode(data['checkpoints']));

    final profile = AuthService.currentUser;
    if (profile == null) return;

    await LocalProfileDatabase.instance.saveProgress(
      profileId: profile.id,
      highestUnlockedLevel: _highestUnlockedLevel,
      highestCompletedLevel: _highestCompletedLevel,
      lastPlayedLevel: _lastPlayedLevel,
      lastPositionLevel: _lastPositionLevel,
      lastPositionX: _lastPositionX,
      lastPositionY: _lastPositionY,
      checkpointsJson: jsonEncode(data['checkpoints']),
    );
  }
}
