# TamaGit

A Flutter-based Tamagotchi-style pet game driven by your GitHub activity.

## Overview

TamaGit turns your development routine into a pet-care loop: commits and repository activity help your Aquatan grow, while inactivity makes it lose stats. The app connects to GitHub, fetches statistics for selected repositories, and maps them to a simple health/happiness/energy system.

## Key Features

- **Aquatan pet** with growth stages and moods
- **GitHub integration** (token-based) to fetch repository activity and stats
- **Stats system** (health, happiness, energy) influenced by your coding activity
- **Streak + progression** tracked over time
- **Garden view** where the sprite can move around freely (UI environment)
- **Statistics dashboard** to visualize activity
- **Persistent storage** of settings and pet state
- **Cross-platform** Flutter app (Android/iOS/Desktop)

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- A GitHub account
- A GitHub Personal Access Token (PAT)

### Installation

```bash
git clone https://github.com/Heriep/tamagit.git
cd tamagit
flutter pub get
flutter run
```

## How It Works

1. **Configure GitHub**: Add a GitHub Personal Access Token in the app settings.
2. **Select repositories**: Choose which repositories you want TamaGit to track.
3. **Code normally**: Your activity is translated into stats and progression.
4. **Watch the pet evolve**: Growth stages and mood reflect your consistency.

## Project Structure

```
lib/
├── main.dart                          # App entry point (providers, MaterialApp)
├── models/                            # Data models
│   ├── aquatan.dart                   # Aquatan state, enums (mood/stage/pose), etc.
│   ├── github_stats.dart              # GitHub related statistics DTOs
│   ├── pet_stats.dart                 # Computed pet stats/progression helpers
│   ├── statistics.dart                # App statistics model(s)
│   └── user_settings.dart             # Stored settings (PAT, selected repos, ...)
├── providers/                         # State management
│   └── pet_provider.dart              # Single source-of-truth for pet state in UI
├── screens/                           # UI screens
│   ├── debug_screen.dart              # Debug controls/presets (dev only)
│   ├── home_screen.dart               # Main screen (garden + pet info)
│   └── statistics_screen.dart         # Stats visualisation screen
├── services/                          # Business logic & integrations
│   ├── aquatan_manager.dart           # Rules engine (decay, mood/stage calc, etc.)
│   ├── github_service.dart            # GitHub API calls
│   ├── stat_calculator.dart           # Stateless formulas (mood/pose/stage/bonuses)
│   ├── statistics_service.dart        # Aggregation / formatting / higher-level stats
│   └── storage_service.dart           # Persistence (settings + pet state)
├── utils/                             # Pure helpers & constants
│   ├── aquatan_generator.dart         # Sprite recolor / palette generation
│   └── game_constants.dart            # Tunable gameplay constants
└── widgets/                           # Reusable UI components
    ├── aquatan_sprite.dart            # Pure sprite renderer (frame + pose)
    ├── garden_environment.dart        # Garden container + free movement
    └── pet_widget.dart                # Pet UI component (used outside garden if needed)
```

## Configuration (GitHub Token)

You’ll need a GitHub Personal Access Token.

- Create a PAT in GitHub settings.
- Paste it in the app **Settings** screen.

Recommended: grant only the scopes required by the requests you make (for public repos, no `repo` scope is needed; for private repos, `repo` may be required).

## Notes

- API rate limits apply (GitHub).
- The exact stat formulas are defined in the services/manager logic and may evolve as gameplay is tuned.

## Acknowledgments

- Inspired by classic Tamagotchi virtual pets
- Built with Flutter
- Uses GitHub APIs for activity tracking