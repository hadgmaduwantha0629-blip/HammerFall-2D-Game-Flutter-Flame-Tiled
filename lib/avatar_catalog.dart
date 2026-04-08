// Class for the avatar catalog feature.
class AvatarCatalog {
  AvatarCatalog._();

  static const List<String> avatarAssetPaths = <String>[
    'assets/images/avatar/avatar1.png',
    'assets/images/avatar/avatar2.png',
    'assets/images/avatar/avatar3.png',
    'assets/images/avatar/avatar4.png',
    'assets/images/avatar/avatar5.png',
    'assets/images/avatar/avatar6.png',
    'assets/images/avatar/avatar7.png',
    'assets/images/avatar/avatar8.png',
  ];

  // First two avatars are always unlocked. Others unlock by level progress.
  static const List<int> requiredLevelByAvatar = <int>[1, 1, 2, 2, 3, 3, 4, 5];

  // Cleans up sanitize avatar id.
  static int sanitizeAvatarId(int avatarId) {
    if (avatarId < 0) return 0;
    if (avatarId >= avatarAssetPaths.length) return 0;
    return avatarId;
  }

  // Checks whether is unlocked.
  static bool isUnlocked(int avatarId, int highestUnlockedLevel) {
    final id = sanitizeAvatarId(avatarId);
    final required = requiredLevelByAvatar[id];
    return highestUnlockedLevel >= required;
  }
}
