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

**Backend API** (FastAPI in `backend/` directory):
```bash
# Run with Docker (recommended)
docker-compose up --build

# Or run directly with Python
cd backend
pip install -r requirements.txt
python main.py

# API available at http://localhost:8000
# API docs at http://localhost:8000/docs
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
iOS App (SwiftUI)
    ↓ HTTP requests
Backend API (FastAPI)
    ↓ reads
JSON Data (scraped)

Within iOS App:
UI Layer (SwiftUI Views)
    ↓ @Published properties
Service Layer (DataService singleton)
    ↓ uses
Model Layer (Swimmer, Team, Meet structs)
```

**Backend API** (`backend/main.py`): FastAPI server that serves scraped swimmer data. Provides REST endpoints for swimmers, schools, and events. Runs in Docker container with mounted data volume.

**DataService** (`Services/DataService.swift`): Central ObservableObject that manages all app state. Currently loads from MockData; has placeholder methods for API integration (update `baseURL` to connect to backend).

**Theme System** (`Models/Theme.swift`): Centralized AppTheme struct with dark theme colors. School-specific colors are in IvySchool enum.

**Navigation**: Custom tab bar in ContentView.swift with TeamsView, StandingsView, ResultsView, RosterView tabs.

## Key Files

| Purpose | File |
|---------|------|
| **iOS App** | |
| App entry point | `IvySwimFantasyApp.swift` |
| Tab navigation | `ContentView.swift` |
| State management | `Services/DataService.swift` |
| Theme/styling | `Models/Theme.swift` |
| Core data models | `Models/Swimmer.swift`, `Models/Team.swift`, `Models/Meet.swift` |
| Mock data (~39KB) | `Models/MockData.swift` |
| Swimmer times (~116KB) | `Models/SwimmerTimesData.swift` |
| **Backend** | |
| API server | `backend/main.py` |
| API dependencies | `backend/requirements.txt` |
| Docker image | `backend/Dockerfile` |
| Local dev compose | `docker-compose.yml` |
| Production compose | `docker-compose.prod.yml` |
| Deployment guide | `DEPLOYMENT.md` |

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

## Backend & Deployment

**Backend API** (`backend/` directory):
- FastAPI server that serves scraped data via REST API
- Endpoints: `/api/swimmers`, `/api/schools`, `/api/events`
- Runs in Docker container with data volume mounted

**Docker Deployment**:
```bash
# Build image
cd backend
docker build -t usaiinc/ivy-swim-backend:latest .

# Push to Docker Hub
docker push usaiinc/ivy-swim-backend:latest

# Deploy to production (copy docker-compose.prod.yml to server)
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for complete deployment instructions and [backend/README.md](backend/README.md) for API documentation.
