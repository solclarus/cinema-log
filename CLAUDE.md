# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CinemaLog is an iOS movie viewing record management app built with SwiftUI and SwiftData. The app allows users to search for movies via TMDB API, record viewing experiences, and view statistics of their movie watching habits.

## Architecture & Technology Stack

- **Framework**: SwiftUI (iOS 16.0+)
- **Data Persistence**: SwiftData with CloudKit integration
- **Architecture Pattern**: MVVM with ObservableObject state management
- **External API**: TMDB (The Movie Database) API
- **Deployment Target**: iOS 18.5 (based on project configuration)

## Build & Development Commands

Since this is an iOS project using Xcode, the standard Xcode build process applies:

- **Build**: Use Xcode (`Cmd+B`) or `xcodebuild` command
- **Run Tests**: Use Xcode Test Navigator or `xcodebuild test`
- **Run App**: Use Xcode (`Cmd+R`) or iOS Simulator
- **Archive**: Product → Archive in Xcode

## Project Structure

```
CinemaLog/
├── CinemaLogApp.swift          # Main app entry point with SwiftData configuration
├── ContentView.swift           # Main tab navigation view
├── Item.swift                  # Basic SwiftData model (to be replaced with movie models)
├── Models/                     # Data models (planned)
├── Views/
│   ├── Discover/
│   │   └── DiscoverView.swift  # Movie discovery and search
│   ├── Records/
│   │   └── RecordsView.swift   # Viewing record management
│   ├── Statistics/
│   │   └── StatisticsView.swift # Statistics display
│   ├── Settings/
│   │   └── SettingsView.swift  # App settings
│   ├── MovieDetail/
│   │   └── MovieDetailView.swift # Movie detail views
│   └── ViewingRecord/
│       └── ViewingRecordView.swift # Viewing record forms
└── Claude/                     # Project documentation
    ├── PROJECT_DESIGN.md       # Comprehensive design specification
    ├── FEATURES_SPECIFICATION.md # Detailed feature requirements
    └── IMPLEMENTATION_GUIDE.md # Step-by-step implementation guide
```

## Data Models (Planned Architecture)

Based on the design documents, the app will implement these main SwiftData models:

- **Movie**: Core movie data (TMDB ID, title, poster, genres, etc.)
- **ViewingRecord**: Individual viewing sessions with ratings and notes
- **WatchlistItem**: Movies to watch with priorities
- **UserStreamingService**: User's streaming service preferences

## Key Implementation Details

### TMDB API Integration
- API Key: Configured for The Movie Database
- Base URL: `https://api.themoviedb.org/3`
- Image Base URL: `https://image.tmdb.org/t/p`
- Language support: Japanese (primary) and English

### SwiftData Configuration
- CloudKit integration enabled for data sync
- Schema defined in `CinemaLogApp.swift`
- Currently uses basic `Item` model (placeholder)

### UI Structure
- Tab-based navigation with 4 main sections:
  - Discover: Movie search and discovery
  - Records: Viewing history management  
  - Statistics: Analytics and insights
  - Settings: App configuration

## Development Guidelines

### Code Organization
- Follow the existing view structure under `Views/` with feature-based folders
- Use SwiftUI best practices with `@State`, `@ObservedObject`, and `@EnvironmentObject`
- Implement proper error handling for API calls
- Use async/await for network operations

### Internationalization
- Primary language: Japanese
- Secondary language: English
- Localization keys defined in design documents

### Testing
- Unit tests: `CinemaLogTests/`
- UI tests: `CinemaLogUITests/`
- Test target configured for main app

## Important Notes

- The project is currently in initial state with placeholder views
- Comprehensive implementation plan available in `Claude/IMPLEMENTATION_GUIDE.md`
- Feature specifications detailed in `Claude/FEATURES_SPECIFICATION.md`
- Full architecture design in `Claude/PROJECT_DESIGN.md`
- Development team ID configured: `QZV692V4J3`
- Bundle identifier: `me.solclarus.CinemaLog`

## Next Development Steps

Based on the implementation guide, the recommended development order is:
1. Implement SwiftData models (Movie, ViewingRecord, etc.)
2. Create TMDB API service layer
3. Build core UI components
4. Implement movie search and detail views
5. Add viewing record functionality
6. Develop statistics and analytics features