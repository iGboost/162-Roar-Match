//
//  StorageManager.swift
//  Roar Match
//
//  UserDefaults storage manager for game data persistence
//

import Foundation

class StorageManager: ObservableObject {
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedTheme = "selectedTheme"
        static let gameStatistics = "gameStatistics"
        static let achievements = "achievements"
        static let unlockedLevels = "unlockedLevels"
        static let soundEnabled = "soundEnabled"
        static let hapticEnabled = "hapticEnabled"
    }
    
    private init() {}
    
    // MARK: - Onboarding
    var hasCompletedOnboarding: Bool {
        get { userDefaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { userDefaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }
    
    // MARK: - Theme
    var selectedTheme: AppTheme {
        get {
            let themeString = userDefaults.string(forKey: Keys.selectedTheme) ?? AppTheme.goldenGlow.rawValue
            return AppTheme(rawValue: themeString) ?? .goldenGlow
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.selectedTheme)
        }
    }
    
    // MARK: - Settings
    var soundEnabled: Bool {
        get { userDefaults.object(forKey: Keys.soundEnabled) as? Bool ?? true }
        set { userDefaults.set(newValue, forKey: Keys.soundEnabled) }
    }
    
    var hapticEnabled: Bool {
        get { userDefaults.object(forKey: Keys.hapticEnabled) as? Bool ?? true }
        set { userDefaults.set(newValue, forKey: Keys.hapticEnabled) }
    }
    
    // MARK: - Game Statistics
    var gameStatistics: GameStatistics {
        get {
            guard let data = userDefaults.data(forKey: Keys.gameStatistics),
                  let statistics = try? JSONDecoder().decode(GameStatistics.self, from: data) else {
                return GameStatistics()
            }
            return statistics
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: Keys.gameStatistics)
            }
        }
    }
    
    // MARK: - Achievements
    var achievements: [Achievement] {
        get {
            guard let data = userDefaults.data(forKey: Keys.achievements),
                  let achievements = try? JSONDecoder().decode([Achievement].self, from: data) else {
                return Achievement.allAchievements
            }
            return achievements
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: Keys.achievements)
            }
        }
    }
    
    // MARK: - Unlocked Levels
    var unlockedLevels: Set<String> {
        get {
            let array = userDefaults.array(forKey: Keys.unlockedLevels) as? [String] ?? [GameLevel.easy.rawValue]
            return Set(array)
        }
        set {
            userDefaults.set(Array(newValue), forKey: Keys.unlockedLevels)
        }
    }
    
    // MARK: - Game Management
    func recordGameSession(_ session: GameSession) {
        var stats = gameStatistics
        stats.recordGame(
            score: session.score,
            time: session.duration,
            mistakes: session.mistakes,
            matches: session.matches
        )
        gameStatistics = stats
        
        // Check and update achievements
        updateAchievements(from: session, with: stats)
        
        // Unlock next level if completed successfully
        if session.mistakes <= 3 { // Allow some mistakes to unlock next level
            unlockNextLevel(after: session.level)
        }
    }
    
    private func updateAchievements(from session: GameSession, with stats: GameStatistics) {
        var updatedAchievements = achievements
        
        for i in updatedAchievements.indices {
            switch updatedAchievements[i].id {
            case "tiger_eye":
                if session.mistakes == 0 && !updatedAchievements[i].isUnlocked {
                    updatedAchievements[i].isUnlocked = true
                    updatedAchievements[i].progress = 1
                }
                
            case "golden_paw":
                if session.maxCombo >= 5 && !updatedAchievements[i].isUnlocked {
                    updatedAchievements[i].isUnlocked = true
                    updatedAchievements[i].progress = session.maxCombo
                }
                
            case "fortune_master":
                updatedAchievements[i].progress = stats.longestStreak
                if stats.longestStreak >= 10 && !updatedAchievements[i].isUnlocked {
                    updatedAchievements[i].isUnlocked = true
                }
                
            case "speed_demon":
                if session.duration < 30 && !updatedAchievements[i].isUnlocked {
                    updatedAchievements[i].isUnlocked = true
                    updatedAchievements[i].progress = 1
                }
                
            case "memory_master":
                if session.level == .expert && session.mistakes == 0 && !updatedAchievements[i].isUnlocked {
                    updatedAchievements[i].isUnlocked = true
                    updatedAchievements[i].progress = 1
                }
                
            default:
                break
            }
        }
        
        achievements = updatedAchievements
    }
    
    private func unlockNextLevel(after level: GameLevel) {
        var unlocked = unlockedLevels
        
        switch level {
        case .easy:
            unlocked.insert(GameLevel.medium.rawValue)
        case .medium:
            unlocked.insert(GameLevel.hard.rawValue)
        case .hard:
            unlocked.insert(GameLevel.expert.rawValue)
        case .expert:
            break // Already at max level
        }
        
        unlockedLevels = unlocked
    }
    
    // MARK: - Reset
    func resetAllProgress() {
        userDefaults.removeObject(forKey: Keys.gameStatistics)
        userDefaults.removeObject(forKey: Keys.achievements)
        userDefaults.removeObject(forKey: Keys.unlockedLevels)
        
        // Keep onboarding and settings
        objectWillChange.send()
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}

// MARK: - Convenience Extensions
extension StorageManager {
    func isLevelUnlocked(_ level: GameLevel) -> Bool {
        return unlockedLevels.contains(level.rawValue)
    }
    
    func getAchievement(by id: String) -> Achievement? {
        return achievements.first { $0.id == id }
    }
    
    func unlockedAchievements() -> [Achievement] {
        return achievements.filter { $0.isUnlocked }
    }
    
    func completionPercentage() -> Double {
        let unlockedCount = achievements.filter { $0.isUnlocked }.count
        return Double(unlockedCount) / Double(achievements.count) * 100
    }
}
