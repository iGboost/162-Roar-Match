//
//  Models.swift
//  Roar Match
//
//  Game models for cards, levels, achievements and game state
//

import Foundation

// MARK: - Card Model
struct Card: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    var isFlipped = false
    var isMatched = false
    
    static let symbols = ["🐅", "🪙", "🏮", "🥇", "🧿", "🐉"]
    
    static func createDeck(for level: GameLevel) -> [Card] {
        let pairCount = level.gridSize * level.gridSize / 2
        let selectedSymbols = Array(symbols.prefix(min(pairCount, symbols.count)))
        
        var cards: [Card] = []
        for symbol in selectedSymbols {
            cards.append(Card(symbol: symbol))
            cards.append(Card(symbol: symbol))
        }
        
        // Fill remaining slots if needed
        while cards.count < level.gridSize * level.gridSize {
            let randomSymbol = symbols.randomElement() ?? "🐅"
            cards.append(Card(symbol: randomSymbol))
            cards.append(Card(symbol: randomSymbol))
        }
        
        return cards.shuffled()
    }
}

// MARK: - Game Level
enum GameLevel: String, CaseIterable {
    case easy = "3x3"
    case medium = "4x4"
    case hard = "5x5"
    case expert = "6x6"
    
    var gridSize: Int {
        switch self {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 5
        case .expert: return 6
        }
    }
    
    var displayName: String {
        switch self {
        case .easy: return "Easy (3×3)"
        case .medium: return "Medium (4×4)"
        case .hard: return "Hard (5×5)"
        case .expert: return "Expert (6×6)"
        }
    }
    
    var baseScore: Int {
        switch self {
        case .easy: return 10
        case .medium: return 20
        case .hard: return 30
        case .expert: return 50
        }
    }
}

// MARK: - Game State
enum GameState {
    case menu
    case playing
    case paused
    case completed
    case gameOver
}

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool = false
    var progress: Int = 0
    var target: Int
    
    static let allAchievements = [
        Achievement(
            id: "tiger_eye",
            title: "Tiger Eye",
            description: "Complete a level without mistakes",
            icon: "👁️",
            target: 1
        ),
        Achievement(
            id: "golden_paw",
            title: "Golden Paw",
            description: "Get 5 matches in a row",
            icon: "🐾",
            target: 5
        ),
        Achievement(
            id: "fortune_master",
            title: "Fortune Master",
            description: "Complete 10 levels in a row",
            icon: "👑",
            target: 10
        ),
        Achievement(
            id: "speed_demon",
            title: "Speed Demon",
            description: "Complete a level in under 30 seconds",
            icon: "⚡",
            target: 1
        ),
        Achievement(
            id: "memory_master",
            title: "Memory Master",
            description: "Complete expert level without mistakes",
            icon: "🧠",
            target: 1
        )
    ]
}

// MARK: - Game Statistics
struct GameStatistics: Codable {
    var gamesPlayed: Int = 0
    var gamesWon: Int = 0
    var totalScore: Int = 0
    var bestScore: Int = 0
    var bestTime: TimeInterval = 0
    var averageTime: TimeInterval = 0
    var perfectGames: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalMatches: Int = 0
    var totalMistakes: Int = 0
    
    var winRate: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(gamesWon) / Double(gamesPlayed) * 100
    }
    
    var averageScore: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(totalScore) / Double(gamesPlayed)
    }
    
    var errorRate: Double {
        guard totalMatches > 0 else { return 0 }
        return Double(totalMistakes) / Double(totalMatches + totalMistakes) * 100
    }
    
    mutating func recordGame(score: Int, time: TimeInterval, mistakes: Int, matches: Int) {
        gamesPlayed += 1
        totalScore += score
        totalMatches += matches
        totalMistakes += mistakes
        
        if score > bestScore {
            bestScore = score
        }
        
        if mistakes == 0 {
            perfectGames += 1
            currentStreak += 1
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
        } else {
            currentStreak = 0
        }
        
        if time > 0 {
            if bestTime == 0 || time < bestTime {
                bestTime = time
            }
            
            let totalTime = averageTime * Double(gamesPlayed - 1) + time
            averageTime = totalTime / Double(gamesPlayed)
        }
        
        if score > 0 {
            gamesWon += 1
        }
    }
}

// MARK: - Game Session
struct GameSession {
    let level: GameLevel
    let startTime: Date
    var endTime: Date?
    var score: Int = 0
    var mistakes: Int = 0
    var matches: Int = 0
    var comboCount: Int = 0
    var maxCombo: Int = 0
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    var isComplete: Bool {
        endTime != nil
    }
    
    mutating func recordMatch(isCombo: Bool = false) {
        matches += 1
        score += level.baseScore
        
        if isCombo {
            comboCount += 1
            score += comboCount * 5 // Bonus for combo
            if comboCount > maxCombo {
                maxCombo = comboCount
            }
        } else {
            comboCount = 0
        }
    }
    
    mutating func recordMistake() {
        mistakes += 1
        score = max(0, score - 5) // Penalty for mistake
        comboCount = 0
    }
    
    mutating func complete() {
        endTime = Date()
        
        // Time bonus
        let timeBonus = max(0, 300 - Int(duration)) // Bonus for completing quickly
        score += timeBonus
        
        // Perfect game bonus
        if mistakes == 0 {
            score *= 2
        }
    }
}
