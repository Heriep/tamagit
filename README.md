# TamaGit

A Flutter-based Tamagotchi-style pet game integrated with GitHub workflows.

## Overview

TamaGit is a gamified application that turns your GitHub activity into a virtual pet care experience. Your commit frequency, code quality, and repository engagement directly affect your digital pet's health and happiness.

## Features

- **Virtual Pet**: A digital companion that responds to your GitHub activity
- **GitHub Integration**: Automatically tracks your commits, pull requests, and repository interactions via GitHub API
- **Health & Mood System**: Pet's wellbeing and emotional state depend on regular code contributions
- **Statistics Dashboard**: Comprehensive view of your coding patterns and pet's development
- **Visual Feedback**: Watch your pet grow and evolve based on your development habits
- **Persistent Storage**: Your pet's state and statistics are saved locally
- **Customizable Settings**: Configure GitHub repositories and application preferences
- **Cross-platform**: Built with Flutter for iOS, Android, and desktop support

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- GitHub account and personal access token

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Heriep/tamagit.git
cd tamagit
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## How It Works

1. **Connect Your GitHub Account**: Link TamaGit to your GitHub account using a personal access token
2. **Select Repositories**: Choose which repositories to track
3. **Make Commits**: Regular commits keep your pet healthy and happy
4. **Monitor Statistics**: View detailed insights about your coding activity and pet's health
5. **Watch It Grow**: Your pet evolves based on your coding patterns
6. **Stay Consistent**: Maintain streaks for special rewards and achievements

## Project Structure

```
lib/
├── main.dart              # Application entry point
├── config/               # Application configuration
│   └── app_config.dart
├── models/               # Data models
│   ├── github_stats.dart
│   ├── pet.dart
│   ├── statistics.dart
│   └── user_settings.dart
├── providers/            # State management
│   ├── github_provider.dart
│   └── pet_provider.dart
├── screens/              # UI screens
│   ├── home_screen.dart
│   ├── settings_screen.dart
│   ├── statistics_screen.dart
│   └── stats_screen.dart
├── services/             # Business logic & integrations
│   ├── github_service.dart
│   ├── pet_manager.dart
│   ├── statistics_service.dart
│   └── storage_service.dart
├── utils/                # Helper functions
│   ├── constants.dart
│   └── date_helpers.dart
└── widgets/              # Reusable widgets
    ├── mood_indicator.dart
    ├── pet_widget.dart
    └── stats_card.dart
```

## Configuration

To connect your GitHub account, you'll need to:

1. Generate a GitHub personal access token with `repo` scope
2. Configure it in the app's settings screen

## Acknowledgments

- Inspired by the classic Tamagotchi virtual pets
- Built with Flutter framework
- GitHub API integration for activity tracking