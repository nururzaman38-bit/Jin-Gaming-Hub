# 🎮 Jin Gaming Hub — All-in-One Multi-Game Portal

A native multi-game app built with **Flutter** featuring modular game architecture, Firebase authentication, leaderboard, coin wallet, and a complete gaming experience from login to gameplay.

---

## 📱 Screens & Flow

| # | Screen | Description |
|---|--------|-------------|
| 1 | **Splash** | App logo with fade-in, auto-redirects after 2s based on auth state |
| 2 | **Auth** | Login / Register tabs, Google Sign-In, Forgot Password |
| 3 | **Home** | Dashboard with banner slider, category chips, game grid |
| 4 | **Game Details** | Full preview, high score, Play Now button |
| 5 | **Game Play** | Native game canvas, pause button, score counter |
| 6 | **Game Over** | Final score, high score comparison, Play Again / Share / Home |
| 7 | **Leaderboard** | Global & Daily rankings tabs |
| 8 | **Profile** | User avatar, coins, game history, edit profile, logout |

---

## 🏗️ Architecture

```
lib/
├── main.dart                    # App entry point & Provider setup
├── config/
│   ├── constants.dart           # App-wide constants
│   ├── theme.dart               # Dark/Light theme configuration
│   └── routes.dart              # Named routes & navigation helpers
├── models/
│   ├── user_model.dart          # User data model
│   ├── game_model.dart          # Game data model
│   └── score_model.dart         # Score data model
├── providers/
│   ├── auth_provider.dart       # Auth state management
│   ├── game_provider.dart       # Game catalog & play state
│   └── leaderboard_provider.dart # Leaderboard data
├── screens/
│   ├── splash_screen.dart       # Screen 1: Splash
│   ├── auth_screen.dart         # Screen 2: Login/Signup
│   ├── home_screen.dart         # Screen 3: Dashboard
│   ├── game_details_screen.dart # Screen 4: Game Details
│   ├── game_play_screen.dart    # Screen 5: Gameplay
│   ├── game_over_screen.dart    # Screen 6: Game Over
│   ├── leaderboard_screen.dart  # Screen 7: Leaderboard
│   ├── profile_screen.dart      # Screen 8: Profile
│   └── notification_screen.dart # Notifications
├── widgets/
│   ├── top_bar.dart             # Home top bar (avatar, coins, bell)
│   ├── banner_slider.dart       # Featured games carousel
│   ├── category_chips.dart      # Filter chips
│   ├── game_card.dart           # Game grid card
│   ├── pause_modal.dart         # Pause dialog
│   └── leaderboard_tile.dart    # Leaderboard list item
├── services/
│   ├── auth_service.dart        # Firebase Auth + Google Sign-In
│   ├── database_service.dart    # Hive local database
│   ├── connectivity_service.dart # Network connectivity
│   └── share_service.dart       # Native share sheet
├── games/
│   └── game_engine.dart         # Game engine interface + demo game
└── utils/
    ├── validators.dart          # Form validation
    └── helpers.dart             # Date/number formatting
```

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.22+ |
| State Management | Provider |
| Authentication | Firebase Auth + Google Sign-In |
| Cloud Database | Cloud Firestore |
| Local Database | Hive |
| Game Engine | Flame (ready for integration) |
| Sharing | share_plus |
| Connectivity | connectivity_plus |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.22+ installed
- Android Studio / VS Code
- Firebase project created

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/nururzaman38-bit/Jin-Gaming-Hub.git
   cd Jin-Gaming-Hub
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli

   # Configure your Firebase project
   flutterfire configure
   ```

4. **Add Google Sign-In:**
   - Enable Google Sign-In in Firebase Console → Authentication → Sign-in method
   - Add your SHA-1 fingerprint to the Firebase project

5. **Run the app:**
   ```bash
   flutter run
   ```

### Build APK

```bash
flutter build apk --release
```

---

## 🔄 GitHub Actions (CI/CD)

The workflow file is stored at **`docs/github-actions-workflow.yml`**.

### ⚠️ One-time setup (required):

1. Copy the workflow file to the correct location:
   ```bash
   mkdir -p .github/workflows
   cp docs/github-actions-workflow.yml .github/workflows/build.yml
   git add .github/workflows/build.yml
   git commit -m "ci: add GitHub Actions workflow"
   git push
   ```

### What the workflow does:

- ✅ Triggers on push to `main` or `arena/*` branches
- ✅ Sets up Flutter 3.22 + Java 17
- ✅ Runs `flutter pub get` to install dependencies
- ✅ Builds **release APK**
- ✅ Uploads APK as artifact (30-day retention)
- ✅ Creates a **GitHub Release** with APK on main branch pushes

### To trigger manually:
Go to **Actions** → **Flutter Build APK** → **Run workflow**

---

## 🎯 Adding New Games

To add a new game module:

1. Create a new file in `lib/games/` implementing the `GameEngine` interface:

```dart
import 'game_engine.dart';
import '../models/game_model.dart';

class MyNewGame implements GameEngine {
  @override
  void Function(int score)? onScoreUpdate;
  @override
  VoidCallback? onGameOver;

  @override
  Widget buildWidget({GameModel? game}) {
    // Return your game widget
  }

  @override
  void pause() { /* Pause game logic */ }

  @override
  void resume() { /* Resume game logic */ }

  @override
  void restart() { /* Restart game logic */ }

  @override
  void dispose() { /* Clean up resources */ }
}
```

2. Update `GamePlayScreen` to use your engine instead of `DemoGameEngine`.

3. Add the game document to Firestore `games` collection.

---

## 📦 Firestore Collections

### `users`
| Field | Type | Description |
|-------|------|-------------|
| uid | string | Firebase Auth UID |
| email | string | User email |
| displayName | string | Display name |
| photoUrl | string? | Avatar URL |
| totalCoins | number | Total coins earned |
| gamesPlayed | number | Total games played |
| createdAt | timestamp | Account creation |
| lastLogin | timestamp | Last login time |

### `games`
| Field | Type | Description |
|-------|------|-------------|
| title | string | Game title |
| description | string | Game description |
| category | string | Puzzle/Action/Arcade/Strategy |
| thumbnailUrl | string | Thumbnail image URL |
| bannerUrl | string? | Featured banner URL |
| isFeatured | boolean | Show in banner slider |
| isOnline | boolean | Requires internet |
| playsCount | number | Total plays |
| rating | number | Average rating |
| updatedAt | timestamp | Last update |

### `scores`
| Field | Type | Description |
|-------|------|-------------|
| userId | string | Player UID |
| gameId | string | Game ID |
| gameTitle | string | Game name |
| score | number | Score achieved |
| playedAt | timestamp | When played |

---

## 📄 License

This project is licensed under the MIT License.

---

Built with ❤️ by **Jin Gaming Hub Team**
