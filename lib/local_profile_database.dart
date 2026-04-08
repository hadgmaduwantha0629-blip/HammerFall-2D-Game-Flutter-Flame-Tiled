import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'avatar_catalog.dart';

// Class for the local profile feature.
class LocalProfile {
  const LocalProfile({
    required this.id,
    required this.username,
    required this.password,
    required this.avatarId,
    required this.createdAtMs,
    required this.lastLoginAtMs,
    this.recoveryQuestion,
    this.recoveryAnswer,
  });

  final int id;
  final String username;
  final String password;
  final int avatarId;
  final int createdAtMs;
  final int lastLoginAtMs;
  final String? recoveryQuestion;
  final String? recoveryAnswer;

  factory LocalProfile.fromMap(Map<String, Object?> map) {
    return LocalProfile(
      id: map['id'] as int,
      username: map['username'] as String,
      password: map['password'] as String,
      avatarId: AvatarCatalog.sanitizeAvatarId(
        ((map['avatar_id'] as num?)?.toInt()) ??
            _migrateLegacyAvatarColorToId(map['avatar_color']),
      ),
      createdAtMs: map['created_at_ms'] as int,
      lastLoginAtMs: map['last_login_at_ms'] as int,
      recoveryQuestion: map['recovery_question'] as String?,
      recoveryAnswer: map['recovery_answer'] as String?,
    );
  }

  // Migrates migrate legacy avatar color to id.
  static int _migrateLegacyAvatarColorToId(Object? legacyColor) {
    if (legacyColor is num) {
      final color = legacyColor.toInt();
      return color.abs() % AvatarCatalog.avatarAssetPaths.length;
    }
    return 0;
  }
}

// Class for the local profile progress feature.
class LocalProfileProgress {
  const LocalProfileProgress({
    required this.profileId,
    required this.highestUnlockedLevel,
    required this.highestCompletedLevel,
    required this.lastPlayedLevel,
    required this.lastPositionLevel,
    required this.lastPositionX,
    required this.lastPositionY,
    required this.checkpointsJson,
  });

  final int profileId;
  final int highestUnlockedLevel;
  final int highestCompletedLevel;
  final int lastPlayedLevel;
  final int? lastPositionLevel;
  final double? lastPositionX;
  final double? lastPositionY;
  final String checkpointsJson;

  // Handles to nullable double.
  static double? _toNullableDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  factory LocalProfileProgress.fromMap(Map<String, Object?> map) {
    return LocalProfileProgress(
      profileId: map['profile_id'] as int,
      highestUnlockedLevel: map['highest_unlocked_level'] as int,
      highestCompletedLevel: map['highest_completed_level'] as int,
      lastPlayedLevel: map['last_played_level'] as int,
      lastPositionLevel: map['last_position_level'] as int?,
      lastPositionX: _toNullableDouble(map['last_position_x']),
      lastPositionY: _toNullableDouble(map['last_position_y']),
      checkpointsJson: (map['checkpoints_json'] as String?) ?? '{}',
    );
  }

  Map<String, dynamic> get checkpoints {
    final decoded = jsonDecode(checkpointsJson);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }
}

// Class for the local profile database feature.
class LocalProfileDatabase {
  LocalProfileDatabase._();

  static final LocalProfileDatabase instance = LocalProfileDatabase._();

  static const String _webProfilesKey = 'hf_profiles';
  static const String _webProgressKey = 'hf_profile_progress';
  static const String _webNextIdKey = 'hf_next_profile_id';

  Database? _db;
  bool _webInitialized = false;

  // Handles init.
  Future<void> init() async {
    if (kIsWeb) {
      if (_webInitialized) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _webProfilesKey,
        prefs.getString(_webProfilesKey) ?? '[]',
      );
      await prefs.setString(
        _webProgressKey,
        prefs.getString(_webProgressKey) ?? '{}',
      );
      await prefs.setInt(_webNextIdKey, prefs.getInt(_webNextIdKey) ?? 1);
      _webInitialized = true;
      return;
    }

    if (_db != null) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, 'hammerfall_profiles.db');
    _db = await openDatabase(
      fullPath,
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE profiles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password TEXT NOT NULL,
            avatar_id INTEGER NOT NULL DEFAULT 0,
            created_at_ms INTEGER NOT NULL,
            last_login_at_ms INTEGER NOT NULL,
            recovery_question TEXT,
            recovery_answer TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE profile_progress (
            profile_id INTEGER PRIMARY KEY,
            highest_unlocked_level INTEGER NOT NULL,
            highest_completed_level INTEGER NOT NULL,
            last_played_level INTEGER NOT NULL,
            last_position_level INTEGER,
            last_position_x REAL,
            last_position_y REAL,
            checkpoints_json TEXT NOT NULL,
            FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute(
              'ALTER TABLE profiles ADD COLUMN recovery_question TEXT',
            );
          } on DatabaseException catch (e) {
            if (!e.toString().contains('duplicate column name')) {
              rethrow;
            }
          }

          try {
            await db.execute(
              'ALTER TABLE profiles ADD COLUMN recovery_answer TEXT',
            );
          } on DatabaseException catch (e) {
            if (!e.toString().contains('duplicate column name')) {
              rethrow;
            }
          }
        }

        if (oldVersion < 3) {
          try {
            await db.execute(
              'ALTER TABLE profiles ADD COLUMN avatar_id INTEGER NOT NULL DEFAULT 0',
            );
          } on DatabaseException catch (e) {
            if (!e.toString().contains('duplicate column name')) {
              rethrow;
            }
          }
        }
      },
    );
  }

  Future<Database> get database async {
    await init();
    return _db!;
  }

  // Handles web prefs.
  Future<SharedPreferences> _webPrefs() async {
    await init();
    return SharedPreferences.getInstance();
  }

  Future<List<Map<String, dynamic>>> _webReadProfiles() async {
    final prefs = await _webPrefs();
    final raw = prefs.getString(_webProfilesKey) ?? '[]';
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <Map<String, dynamic>>[];
    return decoded
        .whereType<Map>()
        .map(
          (entry) => entry.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }

  // Handles web write profiles.
  Future<void> _webWriteProfiles(List<Map<String, dynamic>> profiles) async {
    final prefs = await _webPrefs();
    await prefs.setString(_webProfilesKey, jsonEncode(profiles));
  }

  Future<Map<String, dynamic>> _webReadProgressMap() async {
    final prefs = await _webPrefs();
    final raw = prefs.getString(_webProgressKey) ?? '{}';
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return <String, dynamic>{};
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  }

  // Handles web write progress map.
  Future<void> _webWriteProgressMap(Map<String, dynamic> progressMap) async {
    final prefs = await _webPrefs();
    await prefs.setString(_webProgressKey, jsonEncode(progressMap));
  }

  // Handles default progress map.
  Map<String, dynamic> _defaultProgressMap(int profileId) {
    return <String, dynamic>{
      'profile_id': profileId,
      'highest_unlocked_level': 1,
      'highest_completed_level': 0,
      'last_played_level': 1,
      'last_position_level': null,
      'last_position_x': null,
      'last_position_y': null,
      'checkpoints_json': '{}',
    };
  }

  // Handles create profile.
  Future<LocalProfile> createProfile({
    required String username,
    required String password,
    int? avatarId,
    String? recoveryQuestion,
    String? recoveryAnswer,
  }) async {
    if (kIsWeb) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final normalizedUsername = username.trim();
      final resolvedAvatarId = AvatarCatalog.sanitizeAvatarId(avatarId ?? 0);
      final profiles = await _webReadProfiles();

      final exists = profiles.any(
        (entry) =>
            (entry['username'] as String?)?.toLowerCase() ==
            normalizedUsername.toLowerCase(),
      );
      if (exists) {
        throw Exception('That profile name already exists.');
      }

      final prefs = await _webPrefs();
      final id = prefs.getInt(_webNextIdKey) ?? 1;
      await prefs.setInt(_webNextIdKey, id + 1);

      final profileMap = <String, dynamic>{
        'id': id,
        'username': normalizedUsername,
        'password': password,
        'avatar_id': resolvedAvatarId,
        'created_at_ms': now,
        'last_login_at_ms': now,
        'recovery_question': recoveryQuestion,
        'recovery_answer': recoveryAnswer?.trim().toLowerCase(),
      };
      profiles.add(profileMap);
      await _webWriteProfiles(profiles);

      final progressMap = await _webReadProgressMap();
      progressMap[id.toString()] = _defaultProgressMap(id);
      await _webWriteProgressMap(progressMap);

      return LocalProfile.fromMap(profileMap);
    }

    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final normalizedUsername = username.trim();
    final resolvedAvatarId = AvatarCatalog.sanitizeAvatarId(avatarId ?? 0);

    final existingRows = await db.query(
      'profiles',
      columns: ['id'],
      where: 'lower(username) = lower(?)',
      whereArgs: [normalizedUsername],
      limit: 1,
    );
    if (existingRows.isNotEmpty) {
      throw Exception('That profile name already exists.');
    }

    late final int id;
    try {
      id = await db.insert('profiles', {
        'username': normalizedUsername,
        'password': password,
        'avatar_id': resolvedAvatarId,
        'created_at_ms': now,
        'last_login_at_ms': now,
        'recovery_question': recoveryQuestion,
        'recovery_answer': recoveryAnswer?.trim().toLowerCase(),
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('That profile name already exists.');
      }
      rethrow;
    }

    await db.insert('profile_progress', {
      'profile_id': id,
      'highest_unlocked_level': 1,
      'highest_completed_level': 0,
      'last_played_level': 1,
      'last_position_level': null,
      'last_position_x': null,
      'last_position_y': null,
      'checkpoints_json': '{}',
    });

    return LocalProfile(
      id: id,
      username: normalizedUsername,
      password: password,
      avatarId: resolvedAvatarId,
      createdAtMs: now,
      lastLoginAtMs: now,
      recoveryQuestion: recoveryQuestion,
      recoveryAnswer: recoveryAnswer?.trim().toLowerCase(),
    );
  }

  // Handles sign in.
  Future<LocalProfile?> signIn({
    required String username,
    required String password,
  }) async {
    if (kIsWeb) {
      final profiles = await _webReadProfiles();
      final normalizedUsername = username.trim();
      final index = profiles.indexWhere(
        (entry) =>
            (entry['username'] as String?)?.toLowerCase() ==
                normalizedUsername.toLowerCase() &&
            entry['password'] == password,
      );
      if (index == -1) return null;

      final now = DateTime.now().millisecondsSinceEpoch;
      final updated = Map<String, dynamic>.from(profiles[index]);
      updated['last_login_at_ms'] = now;
      profiles[index] = updated;
      await _webWriteProfiles(profiles);
      return LocalProfile.fromMap(updated);
    }

    final db = await database;
    final rows = await db.query(
      'profiles',
      where: 'lower(username) = lower(?) AND password = ?',
      whereArgs: [username.trim(), password],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final profile = LocalProfile.fromMap(rows.first);
    await db.update(
      'profiles',
      {'last_login_at_ms': now},
      where: 'id = ?',
      whereArgs: [profile.id],
    );

    return LocalProfile(
      id: profile.id,
      username: profile.username,
      password: profile.password,
      avatarId: profile.avatarId,
      createdAtMs: profile.createdAtMs,
      lastLoginAtMs: now,
      recoveryQuestion: profile.recoveryQuestion,
      recoveryAnswer: profile.recoveryAnswer,
    );
  }

  // Gets profile by username.
  Future<LocalProfile?> getProfileByUsername(String username) async {
    final normalizedUsername = username.trim();

    if (kIsWeb) {
      final profiles = await _webReadProfiles();
      final match = profiles.where(
        (entry) =>
            (entry['username'] as String?)?.toLowerCase() ==
            normalizedUsername.toLowerCase(),
      );
      if (match.isEmpty) return null;
      return LocalProfile.fromMap(match.first);
    }

    final db = await database;
    final rows = await db.query(
      'profiles',
      where: 'lower(username) = lower(?)',
      whereArgs: [normalizedUsername],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalProfile.fromMap(rows.first);
  }

  // Gets recovery question for username.
  Future<String?> getRecoveryQuestionForUsername(String username) async {
    final profile = await getProfileByUsername(username);
    return profile?.recoveryQuestion;
  }

  // Resets reset password with recovery answer.
  Future<void> resetPasswordWithRecoveryAnswer({
    required String username,
    required String recoveryAnswer,
    required String newPassword,
  }) async {
    final profile = await getProfileByUsername(username);
    if (profile == null) {
      throw Exception('Profile not found.');
    }

    final expected = profile.recoveryAnswer?.trim().toLowerCase();
    if (expected == null || expected.isEmpty) {
      throw Exception('This profile has no recovery question set.');
    }

    final provided = recoveryAnswer.trim().toLowerCase();
    if (provided != expected) {
      throw Exception('Security answer is incorrect.');
    }

    await updatePassword(profileId: profile.id, newPassword: newPassword);
  }

  // Lists list profiles.
  Future<List<LocalProfile>> listProfiles() async {
    if (kIsWeb) {
      final profiles = await _webReadProfiles();
      profiles.sort(
        (a, b) => ((b['last_login_at_ms'] as num?)?.toInt() ?? 0).compareTo(
          (a['last_login_at_ms'] as num?)?.toInt() ?? 0,
        ),
      );
      return profiles.map((entry) => LocalProfile.fromMap(entry)).toList();
    }

    final db = await database;
    final rows = await db.query('profiles', orderBy: 'last_login_at_ms DESC');
    return rows.map(LocalProfile.fromMap).toList();
  }

  // Gets profile by id.
  Future<LocalProfile?> getProfileById(int id) async {
    if (kIsWeb) {
      final profiles = await _webReadProfiles();
      final match = profiles.where(
        (entry) => (entry['id'] as num?)?.toInt() == id,
      );
      if (match.isEmpty) return null;
      return LocalProfile.fromMap(match.first);
    }

    final db = await database;
    final rows = await db.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalProfile.fromMap(rows.first);
  }

  // Handles update avatar id.
  Future<LocalProfile> updateAvatarId({
    required int profileId,
    required int avatarId,
  }) async {
    final resolvedAvatarId = AvatarCatalog.sanitizeAvatarId(avatarId);

    if (kIsWeb) {
      final profiles = await _webReadProfiles();
      final index = profiles.indexWhere(
        (entry) => (entry['id'] as num?)?.toInt() == profileId,
      );
      if (index == -1) {
        throw Exception('Profile not found.');
      }
      final updated = Map<String, dynamic>.from(profiles[index]);
      updated['avatar_id'] = resolvedAvatarId;
      profiles[index] = updated;
      await _webWriteProfiles(profiles);
      return LocalProfile.fromMap(updated);
    }

    final db = await database;
    await db.update(
      'profiles',
      {'avatar_id': resolvedAvatarId},
      where: 'id = ?',
      whereArgs: [profileId],
    );
    final profile = await getProfileById(profileId);
    if (profile == null) {
      throw Exception('Profile not found.');
    }
    return profile;
  }

  // Handles update password.
  Future<LocalProfile> updatePassword({
    required int profileId,
    required String newPassword,
  }) async {
    if (kIsWeb) {
      final profiles = await _webReadProfiles();
      final index = profiles.indexWhere(
        (entry) => (entry['id'] as num?)?.toInt() == profileId,
      );
      if (index == -1) {
        throw Exception('Profile not found.');
      }
      final updated = Map<String, dynamic>.from(profiles[index]);
      updated['password'] = newPassword;
      profiles[index] = updated;
      await _webWriteProfiles(profiles);
      return LocalProfile.fromMap(updated);
    }

    final db = await database;
    await db.update(
      'profiles',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [profileId],
    );
    final profile = await getProfileById(profileId);
    if (profile == null) {
      throw Exception('Profile not found.');
    }
    return profile;
  }

  // Handles update username.
  Future<LocalProfile> updateUsername({
    required int profileId,
    required String newUsername,
  }) async {
    final normalizedUsername = newUsername.trim();
    if (normalizedUsername.isEmpty) {
      throw Exception('Username cannot be empty.');
    }

    if (kIsWeb) {
      final profiles = await _webReadProfiles();
      final conflict = profiles.any(
        (entry) =>
            (entry['id'] as num?)?.toInt() != profileId &&
            ((entry['username'] as String?)?.toLowerCase() ==
                normalizedUsername.toLowerCase()),
      );
      if (conflict) {
        throw Exception('That profile name already exists.');
      }

      final index = profiles.indexWhere(
        (entry) => (entry['id'] as num?)?.toInt() == profileId,
      );
      if (index == -1) {
        throw Exception('Profile not found.');
      }

      final updated = Map<String, dynamic>.from(profiles[index]);
      updated['username'] = normalizedUsername;
      profiles[index] = updated;
      await _webWriteProfiles(profiles);
      return LocalProfile.fromMap(updated);
    }

    final db = await database;
    final conflictRows = await db.query(
      'profiles',
      columns: ['id'],
      where: 'lower(username) = lower(?) AND id != ?',
      whereArgs: [normalizedUsername, profileId],
      limit: 1,
    );
    if (conflictRows.isNotEmpty) {
      throw Exception('That profile name already exists.');
    }

    await db.update(
      'profiles',
      {'username': normalizedUsername},
      where: 'id = ?',
      whereArgs: [profileId],
    );

    final profile = await getProfileById(profileId);
    if (profile == null) {
      throw Exception('Profile not found.');
    }
    return profile;
  }

  // Deletes profile.
  Future<void> deleteProfile(int profileId) async {
    if (kIsWeb) {
      final profiles = await _webReadProfiles();
      profiles.removeWhere(
        (entry) => (entry['id'] as num?)?.toInt() == profileId,
      );
      await _webWriteProfiles(profiles);

      final progressMap = await _webReadProgressMap();
      progressMap.remove(profileId.toString());
      await _webWriteProgressMap(progressMap);
      return;
    }

    final db = await database;
    await db.delete(
      'profile_progress',
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
    await db.delete('profiles', where: 'id = ?', whereArgs: [profileId]);
  }

  // Gets progress.
  Future<LocalProfileProgress> getProgress(int profileId) async {
    if (kIsWeb) {
      final progressMap = await _webReadProgressMap();
      final key = profileId.toString();
      final existing = progressMap[key];
      if (existing is Map) {
        final normalized = existing.map((k, v) => MapEntry(k.toString(), v));
        return LocalProfileProgress.fromMap(normalized.cast<String, Object?>());
      }

      final created = _defaultProgressMap(profileId);
      progressMap[key] = created;
      await _webWriteProgressMap(progressMap);
      return LocalProfileProgress.fromMap(created);
    }

    final db = await database;
    final rows = await db.query(
      'profile_progress',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      limit: 1,
    );
    if (rows.isEmpty) {
      await db.insert('profile_progress', {
        'profile_id': profileId,
        'highest_unlocked_level': 1,
        'highest_completed_level': 0,
        'last_played_level': 1,
        'last_position_level': null,
        'last_position_x': null,
        'last_position_y': null,
        'checkpoints_json': '{}',
      });
      return getProgress(profileId);
    }
    return LocalProfileProgress.fromMap(rows.first);
  }

  // Saves save progress.
  Future<void> saveProgress({
    required int profileId,
    required int highestUnlockedLevel,
    required int highestCompletedLevel,
    required int lastPlayedLevel,
    required int? lastPositionLevel,
    required double? lastPositionX,
    required double? lastPositionY,
    required String checkpointsJson,
  }) async {
    if (kIsWeb) {
      final progressMap = await _webReadProgressMap();
      progressMap[profileId.toString()] = <String, dynamic>{
        'profile_id': profileId,
        'highest_unlocked_level': highestUnlockedLevel,
        'highest_completed_level': highestCompletedLevel,
        'last_played_level': lastPlayedLevel,
        'last_position_level': lastPositionLevel,
        'last_position_x': lastPositionX,
        'last_position_y': lastPositionY,
        'checkpoints_json': checkpointsJson,
      };
      await _webWriteProgressMap(progressMap);
      return;
    }

    final db = await database;
    await db.insert('profile_progress', {
      'profile_id': profileId,
      'highest_unlocked_level': highestUnlockedLevel,
      'highest_completed_level': highestCompletedLevel,
      'last_played_level': lastPlayedLevel,
      'last_position_level': lastPositionLevel,
      'last_position_x': lastPositionX,
      'last_position_y': lastPositionY,
      'checkpoints_json': checkpointsJson,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
