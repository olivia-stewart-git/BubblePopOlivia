# BubblePop

A SwiftUI-based iOS casual game where players pop coloured bubbles to earn points.

## Project Structure

```
BubblePop/
├── BubblePopApp.swift          # App entry point
├── Models/
│   ├── Bubble.swift            # Bubble model with colour, position, probability
│   ├── GameSettings.swift      # Constants and defaults for app settings
│   └── PlayerScore.swift       # High score entry model
├── ViewModels/
│   └── GameViewModel.swift     # Core game logic: timer, scoring, combo, movement
├── Views/
│   ├── HomeView.swift          # Landing screen with name entry & navigation
│   ├── SettingsView.swift      # Adjustable game time & max bubbles
│   ├── GameView.swift          # Gameplay screen with bubbles & HUD
│   ├── HighScoreView.swift     # Ranked high score list
│   └── CountdownOverlay.swift  # 3-2-1 countdown before gameplay
├── Utilities/
│   └── ScoreManager.swift      # Persistent JSON-based high score storage
└── Assets.xcassets/            # Asset catalog (colours, app icon)
```

## Setup on Mac

1. Open `BubblePop.xcodeproj` in Xcode 15+.
2. If the project file doesn't load correctly, create a new **iOS App** project in Xcode:
   - Product Name: **BubblePop**
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Delete the auto-generated `ContentView.swift`
   - Drag all `.swift` files from the `BubblePop/` folder into the project navigator
   - Ensure `Assets.xcassets` is included
3. Build and run on any iOS 17+ simulator or device.

## Features Implemented

### Core Functionalities
1. **Player name entry** – required before starting a game
2. **Countdown timer** – counts down in 1-second intervals
3. **Live score display** – updates on each bubble pop
4. **Adjustable game time** – default 60s, range 10–120s via Settings
5. **Adjustable max bubbles** – default 15, range 1–30 via Settings
6. **Random bubble count & colour** – weighted by probability table
7. **Non-overlapping, on-screen placement** – validated positioning
8. **Tap to pop with combo scoring** – 1.5× for consecutive same-colour pops
9. **Auto-refresh every second** – random removal & replacement of bubbles
10. **Persistent high scores** – saved to documents directory JSON file
11. **High score board** – ranked display after game ends

### Extended Functionalities
1. **Moving bubbles** – drift across screen, speed increases over time
2. **Animations** – 3-2-1 countdown, spring-in on appear, scale-up on tap, floating "+X" score labels, combo indicators
3. **All-time high score in HUD** – shown during gameplay
4. **Extra polish** – gradient backgrounds, bubble gradient fills, point values on bubbles, red timer warning under 10s

## Requirements
- Xcode 15+
- iOS 17.0+
- Swift 5.9+
