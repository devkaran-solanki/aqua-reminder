# Aqua Reminder: Implementation Plan

This document outlines the systematic implementation of the Performance & Architecture Optimizations and UI/UX Refinements identified in the Audit Report, intentionally excluding high-value feature additions like widgets or Apple Health sync for now.

## User Review Required

> [!WARNING]
> **Data Migration Risk:** We are migrating your storage layer from `SharedPreferences` to `sqflite`. If you have existing test data you care deeply about, it will be wiped during this transition unless we write a migration script. For a development environment, wiping old test data is usually acceptable. Let me know if preserving the current mock shared preference data is mandatory!

## Proposed Changes

### Phase 1: Storage Layer Migration (SQLite)
We will transition away from storing massive arrays in `SharedPreferences`.
- **`pubspec.yaml`**: 
  - `[MODIFY]` Add dependencies for `sqflite` and `path_provider`.
- **`lib/services/database_helper.dart`**: 
  - `[NEW]` Create a singleton SQLite instance with a `water_entries` table. Implement fast SQL operations for `insert`, `delete`, `update`, and targeted ranged `select` queries.
- **`lib/providers/water_provider.dart`**:
  - `[MODIFY]` Strip out the JSON array serialization logic.
  - Wire up `loadData`, `addWater`, `removeEntry`, and introduce a new `updateEntry` command to sync directly with `DatabaseHelper`.

---

### Phase 2: State Management & Rendering Optimizations
We will eliminate the massive frame drops caused by wrapping the entire page in `Consumer`.
- **`lib/screens/home_screen.dart`**:
  - `[MODIFY]` Remove the root-level `Consumer`.
  - Wrap **only** the dynamic components (`CircularWaterProgress`, the Notification Box, QuickStats, Intake List) in localized `Selector` or small `Consumer` widgets.
  - The static headers and spacing will never rebuild again.
- **`lib/screens/reports_screen.dart`**:
  - `[MODIFY]` Remove the root `setState` trigger on tab changes.
  - Extract the Chart and Stats UI into a discrete `_ReportsTabView` widget utilizing `AutomaticKeepAliveClientMixin`, so swapping between Day/Week/Month tabs caches the layout instantly instead of violently rebuilding it from memory.

---

### Phase 3: UI/UX Refinements
- **`lib/screens/home_screen.dart`**:
  - `[MODIFY]` Add an `onTap` handler to the `WaterEntry` tiles. 
  - `[NEW]` Introduce a sleek Bottom Sheet that allows users to seamlessly edit the exact `amount` and `timestamp` of a past entry without having to delete and re-enter it.
- **`lib/screens/reports_screen.dart`**:
  - `[MODIFY]` Upgrade the blank slate UI when there is no data for a chosen date range. Replace simple text with an elegant, centered visual (e.g., a faint glass or drop icon with softer "No Hydration Data Yet" typography).

## Open Questions
- Is it acceptable to wipe the current test data from `SharedPreferences` and start fresh with SQLite, or do you require a hard data migration script to carry it over?
- Do you want the "Edit Entry Time" bottom sheet to use the custom time wheel from onboarding, or the native Flutter time picker?

## Verification Plan

### Automated/Code Verification
- Run `flutter analyze` after every phase to ensure no cascading breaks with `sqflite` or provider setups.
- Validate `sqflite` queries correctly group daily/weekly totals without throwing syntax errors.

### Manual Verification
- Tap `+ Drink` and ensure only the progress circle and current list rebuild, not the entire screen interface.
- Swipe between Reports tabs rapidly to verify the elimination of jitter/rebuilds using `KeepAlive`.
- Test editing an entry's amount and ensure the progress circle updates cleanly.
