# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ivy League Fantasy Swimming League - an iOS app for fantasy swimming competitions across Ivy League schools. Built with SwiftUI targeting iOS 15+.

## Build Commands

```bash
# Build the iOS app
xcodebuild -project IvySwimFantasy.xcodeproj -scheme IvySwimFantasy -configuration Debug

# Build for simulator
xcodebuild -project IvySwimFantasy.xcodeproj -scheme IvySwimFantasy -configuration Debug -destination 'generic/platform=iOS Simulator'

# Open in Xcode (then ⌘R to run)
open IvySwimFantasy.xcodeproj
```

**Python scraper** (in `scraper/` directory):
```bash
cd scraper
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python swimcloud_scraper.py --school harvard --season 2024-2025
```

## Architecture

```
UI Layer (SwiftUI Views)
    ↓ @Published properties
Service Layer (DataService singleton)
    ↓ uses
Model Layer (Swimmer, Team, Meet structs)
```

**DataService** (`Services/DataService.swift`): Central ObservableObject that manages all app state. Currently loads from MockData; has placeholder methods for future API integration.

**Theme System** (`Models/Theme.swift`): Centralized AppTheme struct with dark theme colors. School-specific colors are in IvySchool enum.

**Navigation**: Custom tab bar in ContentView.swift with TeamsView, StandingsView, ResultsView, RosterView tabs.

## Key Files

| Purpose | File |
|---------|------|
| App entry point | `IvySwimFantasyApp.swift` |
| Tab navigation | `ContentView.swift` |
| State management | `Services/DataService.swift` |
| Theme/styling | `Models/Theme.swift` |
| Core data models | `Models/Swimmer.swift`, `Models/Team.swift`, `Models/Meet.swift` |
| Mock data (~39KB) | `Models/MockData.swift` |
| Swimmer times (~116KB) | `Models/SwimmerTimesData.swift` |

## Conventions

- SwiftUI Views use `@State`, `@Published`, `ObservableObject` for state
- Computed properties for filtered/sorted view data
- `#Preview` blocks for SwiftUI canvas testing
- Custom ViewModifiers: `.cardStyle()`, `AccentButtonStyle`
- Enums have associated computed properties (`.color`, `.shortName`, `.displayName`)

## Domain Enums

- `IvySchool`: Harvard, Yale, Princeton, Columbia, Penn, Brown, Cornell, Dartmouth
- `SwimEvent`: 14 events (Free 50-1650, Back, Breast, Fly, IM)
- `ClassYear`: Fr., So., Jr., Sr.
- `SwimCourse`: SCY (yards), SCM, LCM

## Testing

No test target currently configured. Use `#Preview` blocks and MockData for development testing.

## Scraper

The `scraper/` directory contains Python tools to fetch swimmer data from SwimCloud.com:
- `swimcloud_scraper.py` - Main scraper for rosters and times
- `generate_swift_data.py` - Converts JSON output to Swift code
- Output JSON files are per-school (e.g., `harvard_swimmers.json`)
