# 🎮 HammerFall

A 2D action-adventure mobile game built using Flutter and the Flame engine.

🚀 **Play the game:** [Download APK](https://github.com/hadgmaduwantha0629-blip/HammerFall-2D-Game-Flutter-Flame-Tiled/releases/download/v1.0/HammerFall.Game.apk)
📂 **Source Code:** Available in this repository

---

## 🎥 Gameplay Video

👉 https://www.youtube.com/watch?v=YOUR_VIDEO_ID

---

## ✨ Key Features

* 🎯 5 Levels with increasing difficulty
* 🤖 Enemy AI and combat system
* 💾 Save & Resume gameplay
* 🗺️ Tiled-based world map system
* 🔊 Audio system with volume and mute controls
* 👤 Local authentication and player profiles

---

## 🛠️ Tech Stack

* Flutter
* Flame Engine
* Dart
* SQLite (native platforms)
* SharedPreferences (web)
* Tiled (.tmx maps)

---

## 📸 Screenshots


![Assets Loading UI](screenshots/Assets%20Loading%20UI.png)

![Game Login UI](screenshots/Game%20Login%20UI.png)

![Game Sign up UI](screenshots/Game%20Sign%20up%20UI.png)

![Main Menu UI](screenshots/Main%20Menu%20UI.png)

![Settings UI](screenshots/Settings%20UI.png)

![Locked Map UI](screenshots/Locked%20Map%20UI.png)

![Unlocked Map UI](screenshots/Unlocked%20Map%20UI.png)

![Level Options UI](screenshots/Level%20Options%20UI.png)

![Level 01 UI](screenshots/Level%2001%20UI.png)

![Level Scenario 1 UI](screenshots/Level%20Scenario%201%20UI.png)

![Level Scenario 2 UI](screenshots/Level%20Scenario%202%20UI.png)

![Level Scenario 3 UI](screenshots/Level%20Scenario%203%20UI.png)

![Level Scenario 4 UI](screenshots/Level%20Scenario%20%204%20UI.png)

![Level Scenario 5 UI](screenshots/Level%20Scenario%205%20UI.png)

---

## 🚧 Future Improvements

* Refactor large level files into reusable classes
* Improve game balancing (enemy count, health)
* Enhance UI/UX and animations
* Add more levels and boss mechanics

---

## 📂 Project Summary

* Framework: Flutter
* Game engine: Flame
* Map system: Tiled `.tmx` maps using `flame_tiled`
* Audio: `audioplayers`
* Persistence: SQLite + SharedPreferences
* Platforms: Android, iOS, Linux, macOS, Windows, Web

---

# 📚 Detailed Documentation

## Runtime Flow

1. App starts in `lib/main.dart`.
2. Global settings and auth state are initialized.
3. `lib/auth_gate.dart` decides whether to show sign-in or continue.
4. `lib/loading_screen.dart` preloads assets and progress.
5. `lib/main_menu.dart` acts as the main hub.
6. Player navigates to map, profile, or levels.
7. Gameplay runs inside level scene files.
8. Progress and settings are saved through services and database.

---

## Main Folder Structure

| Path                             | Purpose                            |
| -------------------------------- | ---------------------------------- |
| `lib/`                           | Main application and gameplay code |
| `assets/images/`                 | Characters, enemies, UI            |
| `assets/audios/`                 | Music and sound effects            |
| `assets/tiles/`                  | Tiled `.tmx` maps                  |
| `android/`, `ios/`, `web/`, etc. | Platform-specific code             |
| `pubspec.yaml`                   | Dependencies and config            |

---

## Gameplay & Architecture Overview

* Player uses multiple states: idle, walking, attacking, door transitions, death
* Enemy AI includes chasing, attacking, and death logic
* Hitbox-based collision system using Flame
* Health system with visual feedback
* Checkpoint-based save & resume system

---

## Tiled Map System

* World map defined in `assets/tiles/map.tmx`
* Level layouts handled via `.tmx` files
* Object layers define:

  * Spawn points
  * Enemies
  * Collisions
  * Interactive objects

👉 This allows level design without modifying code

---

## Database Design

### SQLite Tables

**profiles**

* User accounts and authentication

**profile_progress**

* Level progress and checkpoints

### Features

* Save/load player progress
* Resume from last position
* Unlock levels dynamically

---

## Assets Overview

* 🎨 Sprites: Characters, enemies, UI
* 🔊 Audio: Background music & effects
* 🗺️ Tiles: Map and level design

---

## How to Run

```bash
flutter pub get
flutter run
```

---

## 👨‍💻 Author

Developed by *Your Name*

---

## ⭐ Final Note

This project combines Flutter UI development with Flame game architecture, demonstrating:

* Game development principles
* Modular system design
* Data persistence
* Real-time interaction handling

---

⭐ If you like this project, feel free to give it a star!
