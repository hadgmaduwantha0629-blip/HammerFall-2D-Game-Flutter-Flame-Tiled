# Hammerfall

Hammerfall is a 2D action game built with Flutter for the app shell and Flame for the gameplay engine. The project includes local authentication, player profiles, save and resume support, a Tiled world map, five gameplay levels, audio settings, and a local persistence layer.

## Project Summary

- Framework: Flutter
- Game engine: Flame
- Map system: Tiled `.tmx` maps through `flame_tiled`
- Audio: `audioplayers`
- Persistence: SQLite on native platforms, SharedPreferences on web
- Platforms: Android, iOS, Linux, macOS, Windows, Web

## Runtime Flow

1. App starts in [lib/main.dart](lib/main.dart).
2. Global settings and auth state are initialized.
3. [lib/auth_gate.dart](lib/auth_gate.dart) decides whether to show sign-in or continue to the game flow.
4. [lib/loading_screen.dart](lib/loading_screen.dart) preloads game images and loads player progress.
5. [lib/main_menu.dart](lib/main_menu.dart) acts as the main hub.
6. The player opens [lib/map_screen.dart](lib/map_screen.dart), [lib/profile_screen.dart](lib/profile_screen.dart), or a level directly.
7. Gameplay runs inside the level scene files.
8. Progress, settings, and account data are written back through the service and database layers.

## Main Folder Structure

| Path | Purpose |
| --- | --- |
| [lib](lib) | Main application and gameplay source code |
| [assets/images](assets/images) | Character, enemy, object, UI, and tileset images |
| [assets/audios](assets/audios) | Music and sound effects |
| [assets/tiles](assets/tiles) | Tiled `.tmx` files for world map and levels |
| [android](android) | Android runner project |
| [ios](ios) | iOS runner project |
| [linux](linux) | Linux desktop runner |
| [macos](macos) | macOS desktop runner |
| [windows](windows) | Windows desktop runner |
| [web](web) | Web runner assets and manifest |
| [docs](docs) | Project documentation, including the presentation outline |
| [pubspec.yaml](pubspec.yaml) | Packages, assets, and Flutter config |
| [analysis_options.yaml](analysis_options.yaml) | Analyzer and lint settings |
| [devtools_options.yaml](devtools_options.yaml) | DevTools configuration |

## Source Code Structure

### Entry and App Shell

#### [lib/main.dart](lib/main.dart)
- Entry point of the application.
- Loads `GameSettings` and `AuthService` before the UI starts.
- Forces landscape orientation and fullscreen mode.
- Starts `MyGameApp`, which creates the root `MaterialApp`.
- Connected to: [lib/auth_gate.dart](lib/auth_gate.dart), [lib/auth_service.dart](lib/auth_service.dart), [lib/app_route_observer.dart](lib/app_route_observer.dart), [lib/game_settings.dart](lib/game_settings.dart).

#### [lib/app_route_observer.dart](lib/app_route_observer.dart)
- Defines a global `RouteObserver`.
- Lets screens react when routes are pushed, popped, covered, or resumed.
- Used mainly for music and lifecycle handling.

### Authentication and Player Accounts

#### [lib/auth_gate.dart](lib/auth_gate.dart)
- Decides whether the player sees the sign-in screen or the loading flow.
- Contains the local sign-in and sign-up UI.
- Reads auth state through a notifier from `AuthService`.
- Connected to: [lib/auth_service.dart](lib/auth_service.dart), [lib/loading_screen.dart](lib/loading_screen.dart), [lib/local_profile_database.dart](lib/local_profile_database.dart).

#### [lib/auth_service.dart](lib/auth_service.dart)
- Central service for authentication and active player management.
- Handles sign-up, sign-in, sign-out, avatar updates, username updates, and password changes.
- Stores the current profile in a reactive notifier.
- Delegates persistence to the local database layer.
- Connected to: [lib/local_profile_database.dart](lib/local_profile_database.dart), [lib/avatar_catalog.dart](lib/avatar_catalog.dart).

#### [lib/avatar_catalog.dart](lib/avatar_catalog.dart)
- Static catalog of avatar image paths and unlock requirements.
- Validates avatar IDs and checks whether an avatar is unlocked.
- Used by auth and profile features.

#### [lib/local_profile_database.dart](lib/local_profile_database.dart)
- Handles all account and progress persistence.
- Uses SQLite on native platforms.
- Uses SharedPreferences JSON storage on web.
- Defines the `LocalProfile` and `LocalProfileProgress` data models.
- Connected to: [lib/auth_service.dart](lib/auth_service.dart), [lib/level_progress.dart](lib/level_progress.dart), [lib/avatar_catalog.dart](lib/avatar_catalog.dart).

### Settings, Audio, and Global Game State

#### [lib/game_settings.dart](lib/game_settings.dart)
- Stores difficulty, audio state, and UI tap sound settings.
- Persists these values through SharedPreferences.
- Exposes helper methods that change king and pig health based on difficulty.
- Connected to: [lib/audio_service.dart](lib/audio_service.dart), menu screens, and all level files.

#### [lib/audio_service.dart](lib/audio_service.dart)
- Manages menu music, map music, and one-shot sound effects.
- Supports mute and master volume scaling.
- Uses separate `AudioPlayer` instances for looping tracks.
- Connected to: [lib/game_settings.dart](lib/game_settings.dart), [lib/main_menu.dart](lib/main_menu.dart), [lib/map_screen.dart](lib/map_screen.dart), [lib/sound_controls_panel.dart](lib/sound_controls_panel.dart), and all level files.

#### [lib/level_progress.dart](lib/level_progress.dart)
- Tracks unlocked levels, completed levels, last played level, checkpoint positions, and resume choices.
- Loads and saves per-player progress through the database layer.
- Also keeps some quick app-level flags in SharedPreferences.
- Connected to: [lib/auth_service.dart](lib/auth_service.dart), [lib/local_profile_database.dart](lib/local_profile_database.dart), map/profile/menu/level files.

### Loading, Menu, Map, and Profile UI

#### [lib/image_preload_list.dart](lib/image_preload_list.dart)
- Contains the list of image assets loaded during startup.
- Keeps asset loading centralized instead of spreading it across screens.
- Used by [lib/loading_screen.dart](lib/loading_screen.dart).

#### [lib/loading_screen.dart](lib/loading_screen.dart)
- Shows loading progress between authentication and the main menu.
- Preloads image assets listed in `image_preload_list.dart`.
- Loads current user progress before entering the menu.
- Connected to: [lib/image_preload_list.dart](lib/image_preload_list.dart), [lib/level_progress.dart](lib/level_progress.dart), [lib/main_menu.dart](lib/main_menu.dart).

#### [lib/main_menu.dart](lib/main_menu.dart)
- Main hub of the application.
- Opens settings, profile, help, map, and level launch flows.
- Contains the settings dialog and embeds the reusable sound controls panel.
- Imports all levels because it can launch them directly.
- Connected to: auth, settings, audio, progress, profile, map, and all level files.

#### [lib/map_screen.dart](lib/map_screen.dart)
- Displays the world map for level selection.
- Parses `assets/tiles/map.tmx` and extracts level marker positions.
- Shows resume or fresh-start choice when checkpoint data exists.
- Starts and stops map music through route lifecycle callbacks.
- Connected to: [lib/app_route_observer.dart](lib/app_route_observer.dart), [lib/audio_service.dart](lib/audio_service.dart), [lib/game_settings.dart](lib/game_settings.dart), [lib/level_progress.dart](lib/level_progress.dart), level scene files.

#### [lib/profile_screen.dart](lib/profile_screen.dart)
- Displays player profile data and level progress.
- Allows avatar changes, password changes, and account deletion.
- Can also launch levels through resume or fresh-start flow.
- Connected to: [lib/auth_service.dart](lib/auth_service.dart), [lib/auth_gate.dart](lib/auth_gate.dart), [lib/avatar_catalog.dart](lib/avatar_catalog.dart), [lib/level_progress.dart](lib/level_progress.dart), level files.

#### [lib/sound_controls_panel.dart](lib/sound_controls_panel.dart)
- Reusable widget for mute toggle, volume slider, and UI tap sound toggle.
- Reads initial values from `AudioService` and `GameSettings`.
- Writes changes back immediately and persists them.
- Used inside settings and gameplay-related UI flows.

### Gameplay Levels

#### [lib/level_one.dart](lib/level_one.dart)
- Base gameplay structure for the first level.
- Creates `KingGame`, the player, enemies, pickups, doors, health bars, and overlays.
- Loads the tiled level map and collision layers.
- Manages player actions such as idle, run, attack, door entry, and death.
- Connected to: [lib/audio_service.dart](lib/audio_service.dart), [lib/game_settings.dart](lib/game_settings.dart), [lib/level_progress.dart](lib/level_progress.dart), [lib/level_two.dart](lib/level_two.dart), [lib/sound_controls_panel.dart](lib/sound_controls_panel.dart).

#### [lib/level_two.dart](lib/level_two.dart)
- Extends the gameplay pattern with more controls and combat flow.
- Includes touch button helpers and pig kill HUD.
- Uses the same general Flame structure as level one.

#### [lib/level_three.dart](lib/level_three.dart)
- Adds a super-power gameplay mechanic and HUD.
- Continues the same scene, overlay, and collision architecture.

#### [lib/level_four.dart](lib/level_four.dart)
- Adds more advanced enemies and interactions while keeping the same level architecture.
- Keeps super-power logic active.

#### [lib/level_five.dart](lib/level_five.dart)
- Final level of the game.
- Handles the end-stage completion flow and final win state.

## How Tiled Maps Work in This Project

### World Map

- The world map is stored in `assets/tiles/map.tmx`.
- [lib/map_screen.dart](lib/map_screen.dart) loads the file as XML text.
- It manually finds the object layer named `level`.
- Each object in that layer contains:
	- `name` as the level number
	- `x` and `y` as the map position
- These coordinates are used to place tappable level markers on the map UI.

### Gameplay Maps

- Gameplay levels are stored as `.tmx` files in `assets/tiles/`.
- The level scene loads a tiled file using `TiledComponent.load(...)`.
- The code reads object layers such as:
	- `collisions`
	- `spawnpoints`
- Based on object names, the code spawns:
	- king/player
	- doors
	- pigs and special enemies
	- heart pickups
	- platforms and collision bodies

### Why this design is useful

- Level layout stays outside the code.
- Designers can change placement visually in Tiled.
- The code only needs to interpret object names and coordinates.

## How Character Actions and Animations Work

The clearest example is in [lib/level_one.dart](lib/level_one.dart).

### Player state flow

- `PlayerAction` controls player behavior.
- Main states are:
	- `idle`
	- `walking`
	- `attacking`
	- `doorOut`
	- `doorIn`
	- `dead`

### Animation process

- Animations are loaded in `onLoad()`.
- Each action has a sprite sheet and `SpriteAnimation`.
- During `update(dt)`:
	- if move direction is zero, idle animation is used
	- if move direction is non-zero, run animation is used
	- if attack starts, attack animation and hammer hitbox are added
	- if entering or leaving a door, door animations control movement lock
	- if health reaches zero, death animation plays and defeat menu opens

### Facing left and right

- The sprite is flipped by changing `scale.x`.
- Positive and negative scale values make the same sprite face opposite directions.

### Enemy behavior

- Pig enemies use `PigState` for idle, hit, attack, and death transitions.
- Some enemies chase the king and attack only at close range.
- Their update logic decides movement, facing, attack timing, and death removal.

## Collision and Combat System

- Flame hitboxes are attached to player, enemies, platforms, and pickups.
- Platform collisions stop falling and keep objects grounded.
- Attack hitboxes are only active during the attack window.
- Pickup collisions heal the king or trigger item effects.
- Health bars are drawn manually and react to low health with blinking color changes.

## Save, Resume, and Progress Logic

- Every level updates the last known player position through `LevelProgress`.
- Resume decisions are stored temporarily before launching a level.
- Completed levels unlock the next progression state.
- Checkpoints are saved by level and restored when the player chooses resume.

## Database Structure

The database is defined in [lib/local_profile_database.dart](lib/local_profile_database.dart).

### Storage modes

- Native platforms: SQLite database file `hammerfall_profiles.db`
- Web: SharedPreferences keys with JSON-encoded content

### SQLite table: `profiles`

| Column | Type | Purpose |
| --- | --- | --- |
| `id` | INTEGER | Primary key |
| `username` | TEXT | Unique username, case-insensitive |
| `password` | TEXT | Stored password |
| `avatar_id` | INTEGER | Selected avatar |
| `created_at_ms` | INTEGER | Account creation time |
| `last_login_at_ms` | INTEGER | Last login time |
| `recovery_question` | TEXT | Password recovery question |
| `recovery_answer` | TEXT | Password recovery answer |

### SQLite table: `profile_progress`

| Column | Type | Purpose |
| --- | --- | --- |
| `profile_id` | INTEGER | One-to-one link to profile |
| `highest_unlocked_level` | INTEGER | Highest available level |
| `highest_completed_level` | INTEGER | Highest completed level |
| `last_played_level` | INTEGER | Most recent level |
| `last_position_level` | INTEGER | Level of saved position |
| `last_position_x` | REAL | Saved x coordinate |
| `last_position_y` | REAL | Saved y coordinate |
| `checkpoints_json` | TEXT | Serialized checkpoint data |

### Relationship

- `profile_progress.profile_id` references `profiles.id`
- `ON DELETE CASCADE` removes progress when a profile is deleted

### Web storage keys

- `hf_profiles`
- `hf_profile_progress`
- `hf_next_profile_id`

## Assets Structure

### Images

- `assets/images/01-King Human/` for king animation sheets
- `assets/images/02-King Pig/` for boss-like pig assets
- `assets/images/03-Pig/` for normal pig animations
- `assets/images/04-Pig Throwing a Box/` and `05-Pig Thowing a Bomb/` for enemy variants
- `assets/images/06-Pig Hide in the Box/` and `08-Box/` for box mechanics
- `assets/images/09-Bomb/`, `10-Cannon/`, `11-Door/` for interactive objects
- `assets/images/12-Live and Coins/` for pickups and UI symbols
- `assets/images/13-Dialogue Boxes/` and `MM_BTNS/` for interface visuals
- `assets/images/14-TileSets/` for map tiles
- `assets/images/avatar/` for player avatars

### Audio

- `assets/audios/` stores menu music, map music, jump, attack, fail, heal, and other sound effects

### Tiles

- `assets/tiles/` stores world map and level TMX files

## Configuration Files

### [pubspec.yaml](pubspec.yaml)
- Declares dependencies such as Flame, flame_tiled, audioplayers, shared_preferences, sqflite, and path.
- Registers all asset folders used by the game.

### [analysis_options.yaml](analysis_options.yaml)
- Enables Flutter lint rules for static analysis.

### [devtools_options.yaml](devtools_options.yaml)
- Stores DevTools preferences for debugging support.

## Platform Folders

- [android](android), [ios](ios), [linux](linux), [macos](macos), [windows](windows), and [web](web) contain the runner projects required to build the Flutter app for each supported platform.
- These folders are mostly framework and platform integration code rather than gameplay logic.

## How to Run the Project

1. Install Flutter and the required platform SDKs.
2. Run `flutter pub get`.
3. Run the app with `flutter run`.
4. Build for a specific platform using the normal Flutter build commands.

## Final Notes

- The project combines normal Flutter UI architecture with Flame game architecture.
- Tiled maps are used to keep layouts and spawn points data-driven.
- Authentication, settings, audio, and progress tracking are separated into dedicated files to keep gameplay code manageable.
- The `lib/` folder is the main place to study the project structure and internal processes.
