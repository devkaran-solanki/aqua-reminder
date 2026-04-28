# Implementation Tasks

- `[x]` Phase 1: Storage Layer Migration (SQLite)
  - `[x]` Add `sqflite` and `path_provider` to `pubspec.yaml`
  - `[x]` Create `DatabaseHelper` singleton in `lib/services/database_helper.dart`
  - `[x]` Expand `WaterEntry` model for DB syncing (`id` field, `toMap`, `fromMap`)
  - `[x]` Refactor `WaterProvider` to utilize `DatabaseHelper` instead of `SharedPreferences`
- `[x]` Phase 2: State Management & Rendering Optimizations
  - `[x]` Refactor `HomeScreen` to use localized `Selector`s/`Consumer`s
  - `[x]` Refactor `ReportsScreen` to prevent whole-page rebuilds using `AutomaticKeepAliveClientMixin`
- `[x]` Phase 3: UI/UX Refinements
  - `[x]` Add "Edit Entry" bottom sheet to `HomeScreen` intake list
  - `[x]` Upgrade Empty States across `HomeScreen` and `ReportsScreen`
