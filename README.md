# Task Manager

A polished Flutter task management app with local Hive persistence, task metadata, animated navigation, and filtering.

## Overview

Task Manager helps users create, edit, complete, and delete tasks with priority, category, due date, and optional description. The app uses Hive for offline persistence and Provider for state management, with a clean Material 3 UI.

## Features

- Add, edit, and delete tasks
- Mark tasks complete or incomplete
- Persistent Hive storage across app launches
- Task metadata: title, description, due date, priority, category
- Search, filter, and sort tasks
- Smooth animated transitions and task card effects
- Inline validation and feedback for task input
- Cross-platform support for Android, iOS, web, Linux, macOS, and Windows

## Getting Started

### Prerequisites

- Flutter SDK installed
- An editor such as Visual Studio Code or Android Studio
- A connected device, emulator, or browser for web

### Run the app

From the project root:

```bash
flutter pub get
flutter run
```

To run tests:

```bash
flutter test
```

## Project Structure

- `lib/main.dart` — App entrypoint and route configuration
- `lib/models/task.dart` — Task data model and Hive adapter
- `lib/state/task_provider.dart` — Task state management and persistence
- `lib/pages/task_list_page.dart` — Main task list UI and filtering
- `lib/pages/task_form_page.dart` — Add/edit task form
- `lib/utils/theme_constants.dart` — Theme constants and colors
- `web/manifest.json` — Web app metadata and icons

## App Icon & Branding

The app is configured with a friendly title and platform metadata for Android, iOS, and web. Launcher icons are included in platform-specific asset directories and the web icon set.

## Notes

- The package is intentionally marked `publish_to: none` in `pubspec.yaml`.
- The app uses `hive_flutter` for local persistence and `provider` for reactive UI updates.
