//
//  GameViewModel.swift
//  Roar Match
//
//  ViewModel for game logic and state management
//

import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var gameState: GameState = .menu
    @Published var currentLevel: GameLevel = .easy
    @Published var session: GameSession?
    @Published var flippedCards: [Card] = []
    @Published var showMatchEffect = false
    @Published var showMistakeEffect = false
    @Published var showComboEffect = false
    @Published var comboCount = 0
    
    private let storageManager = StorageManager.shared
    private var gameTimer: Timer?
    private var flipBackTimer: Timer?
    
    // MARK: - Game Setup
    func startGame(level: GameLevel) {
        currentLevel = level
        session = GameSession(level: level, startTime: Date())
        cards = Card.createDeck(for: level)
        gameState = .playing
        comboCount = 0
        
        // Reset card states
        for i in cards.indices {
            cards[i].isFlipped = false
            cards[i].isMatched = false
        }
        
        startGameTimer()
    }
    
    func pauseGame() {
        gameState = .paused
        gameTimer?.invalidate()
    }
    
    func resumeGame() {
        gameState = .playing
        startGameTimer()
    }
    
    func endGame() {
        gameTimer?.invalidate()
        flipBackTimer?.invalidate()
        
        guard var currentSession = session else { return }
        currentSession.complete()
        
        // Play level complete sound
        SoundManager.shared.playLevelComplete()
        
        storageManager.recordGameSession(currentSession)
        session = currentSession
        gameState = .completed
        
        // Trigger achievement effects if any were unlocked
        checkForNewAchievements()
    }
    
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Card Interaction
    func flipCard(_ card: Card) {
        guard gameState == .playing,
              !card.isMatched,
              !card.isFlipped,
              flippedCards.count < 2 else { return }
        
        // Play card flip sound
        SoundManager.shared.playCardFlip()
        
        // Find card index and flip it
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].isFlipped = true
            flippedCards.append(cards[index])
            
            // Check for match when two cards are flipped
            if flippedCards.count == 2 {
                checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        guard flippedCards.count == 2 else { return }
        
        let card1 = flippedCards[0]
        let card2 = flippedCards[1]
        
        if card1.symbol == card2.symbol {
            // Match found!
            handleMatch()
        } else {
            // No match
            handleMismatch()
        }
    }
    
    private func handleMatch() {
        // Mark cards as matched
        for flippedCard in flippedCards {
            if let index = cards.firstIndex(where: { $0.id == flippedCard.id }) {
                cards[index].isMatched = true
            }
        }
        
        // Update session
        session?.recordMatch(isCombo: comboCount > 0)
        comboCount += 1
        
        // Play appropriate sound
        if comboCount > 1 {
            if comboCount >= 5 {
                SoundManager.shared.playTigerRoar() // Big combo!
            } else {
                SoundManager.shared.playCombo()
            }
        } else {
            SoundManager.shared.playMatch()
        }
        
        // Show effects
        showMatchEffect = true
        if comboCount > 1 {
            showComboEffect = true
        }
        
        // Clear flipped cards
        flippedCards.removeAll()
        
        // Check for game completion
        if cards.allSatisfy({ $0.isMatched }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.endGame()
            }
        }
        
        // Hide effects after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showMatchEffect = false
            self.showComboEffect = false
        }
    }
    
    private func handleMismatch() {
        // Record mistake
        session?.recordMistake()
        comboCount = 0
        
        // Play mistake sound
        SoundManager.shared.playMistake()
        
        // Show mistake effect
        showMistakeEffect = true
        
        // Flip cards back after delay
        flipBackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            for flippedCard in self.flippedCards {
                if let index = self.cards.firstIndex(where: { $0.id == flippedCard.id }) {
                    self.cards[index].isFlipped = false
                }
            }
            self.flippedCards.removeAll()
            self.showMistakeEffect = false
        }
    }
    
    // MARK: - Game State Helpers
    var gameProgress: Double {
        let matchedCount = cards.filter { $0.isMatched }.count
        let totalPairs = cards.count / 2
        return totalPairs > 0 ? Double(matchedCount) / Double(totalPairs * 2) : 0
    }
    
    var currentScore: Int {
        session?.score ?? 0
    }
    
    var currentTime: TimeInterval {
        session?.duration ?? 0
    }
    
    var formattedTime: String {
        let time = Int(currentTime)
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Achievements
    private func checkForNewAchievements() {
        // This could trigger special effects or notifications
        // for newly unlocked achievements
        let _ = storageManager.achievements.filter { $0.isUnlocked }
        // Could show celebration animations here
    }
    
    // MARK: - Reset
    func resetGame() {
        gameTimer?.invalidate()
        flipBackTimer?.invalidate()
        
        cards.removeAll()
        flippedCards.removeAll()
        session = nil
        gameState = .menu
        comboCount = 0
        
        showMatchEffect = false
        showMistakeEffect = false
        showComboEffect = false
    }
}

// MARK: - Extensions
extension GameViewModel {
    func canPlayLevel(_ level: GameLevel) -> Bool {
        return storageManager.isLevelUnlocked(level)
    }
    
    func getBestScoreForLevel(_ level: GameLevel) -> Int {
        // Could be extended to track per-level scores
        return storageManager.gameStatistics.bestScore
    }
}
