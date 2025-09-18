# Roar Match 🐅

A colorful memory matching game with Asian aesthetics built using SwiftUI and MVVM architecture.

## 🎮 Game Features

- **Memory Matching Gameplay**: Find pairs of lucky symbols (tigers, golden coins, lanterns, dragons, amulets)
- **Multiple Difficulty Levels**: 3×3, 4×4, 5×5, and 6×6 grids
- **Achievement System**: Unlock "Tiger Eye", "Golden Paw", "Fortune Master" and more
- **Statistics Tracking**: Monitor your progress, scores, and win rates
- **Theme Customization**: Choose from Day, Night, and Golden Glow themes
- **Offline Play**: Complete privacy - no internet required, all data stored locally

## 🏗️ Technical Architecture

### Tech Stack
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: UserDefaults
- **Minimum Target**: iPhone SE 2022
- **Audio**: System sounds with haptic feedback

### Project Structure

```
Roar Match/
├── Models.swift              # Game data models
├── StorageManager.swift      # UserDefaults persistence
├── GameViewModel.swift       # Game logic and state
├── DesignSystem.swift        # Colors, fonts, UI components
├── SoundManager.swift        # Audio and haptic feedback
├── AnimationHelpers.swift    # Custom animations and effects
├── Views/
│   ├── ContentView.swift     # Main app coordinator
│   ├── MainTabView.swift     # Tab navigation
│   ├── GameView.swift        # Main game interface
│   ├── AchievementsView.swift # Achievements display
│   ├── StatisticsView.swift  # Stats and progress
│   ├── ThemeView.swift       # Theme selection
│   ├── SettingsView.swift    # App settings
│   ├── LoadingView.swift     # Animated loading screen
│   └── OnboardingView.swift  # Tutorial flow
└── Assets.xcassets/          # App icons and assets
```

## 🎯 Key Features Implementation

### Game Mechanics
- **Card Matching**: Flip cards to reveal symbols, find matching pairs
- **Scoring System**: Base points + combo bonuses + time bonuses
- **Mistake Penalty**: Points deduction for wrong matches
- **Progressive Difficulty**: Unlock higher levels by completing previous ones

### Animations & Effects
- **Card Flip Animation**: 3D rotation effect when revealing cards
- **Match Effects**: Golden flash and sparkle animations
- **Combo Effects**: Enhanced particle systems for streaks
- **Tiger Roar**: Special effects for 5+ combos
- **Mistake Shake**: Screen shake effect for wrong matches

### Audio System
- **Card Flip**: Subtle pop sound
- **Match Success**: Chime sound with haptic feedback
- **Combo**: Enhanced sound with stronger haptics
- **Tiger Roar**: Special sound for big combos
- **Level Complete**: Achievement sound
- **Mistakes**: Error sound with haptic feedback

### Achievements
- **Tiger Eye**: Complete level without mistakes
- **Golden Paw**: Get 5 matches in a row
- **Fortune Master**: Complete 10 levels in a row
- **Speed Demon**: Complete level in under 30 seconds
- **Memory Master**: Complete expert level perfectly

## 🎨 Design System

### Color Palette
- **Lucky Gold**: #FFD700 - Primary accent color
- **Fortune Red**: #E60026 - Secondary accent
- **Warm Orange**: #FF7A00 - Tertiary accent
- **Supporting Colors**: Various shades for cards and backgrounds

### Typography
- **San Francisco System Font** with weight variations
- **Large Title**: 34pt Bold for headers
- **Title**: 28pt Bold for sections
- **Body**: 17pt Regular for content
- **Caption**: 14pt Light for details

### Themes
- **Day Theme**: Bright, clean interface
- **Night Theme**: Dark mode for comfortable play
- **Golden Glow**: Warm golden theme with lucky vibes

## 🚀 Getting Started

1. **Open Project**: Open `Roar Match.xcodeproj` in Xcode
2. **Build & Run**: Select target device and run the project
3. **First Launch**: Complete the 3-slide onboarding tutorial
4. **Start Playing**: Choose difficulty level and start matching!

## 📱 App Flow

1. **Loading Screen**: Animated tiger with golden coins
2. **Onboarding**: 3-slide introduction (first launch only)
3. **Main Game**: Tab-based navigation with 5 sections
4. **Game Play**: Card matching with animations and sounds
5. **Progress Tracking**: Achievements and statistics

## 🔒 Privacy

- **No Data Collection**: All data stored locally on device
- **No Internet Required**: Completely offline gameplay
- **UserDefaults Storage**: Game progress, settings, achievements
- **No Analytics**: No tracking or data transmission

## 🏆 Achievement System

The game tracks various player accomplishments:
- Perfect games (no mistakes)
- Combo streaks
- Speed completions
- Level progression
- Overall mastery

## ⚙️ Settings & Customization

- **Sound Effects**: Toggle game sounds on/off
- **Haptic Feedback**: Control vibration feedback
- **Theme Selection**: Choose visual appearance
- **Progress Reset**: Clear all game data
- **Tutorial Reset**: Show onboarding again

## 🎯 Future Enhancements

Potential features for future versions:
- Additional card symbols and themes
- More achievement types
- Daily challenges
- Leaderboards (local)
- Additional difficulty modes

---

**Made with ❤️ using SwiftUI**
*Complete privacy - no data collection - works offline*
